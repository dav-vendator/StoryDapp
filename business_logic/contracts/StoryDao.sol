//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./LockableToken.sol";
import "./SubmissionStruct.sol";
import "./ProposalStruct.sol";

/**
@dev StoryDao is manager of DaoVote:
1. Whitelisted and Blacklisted addresses
2. Setting fee for Whitelisting, Submission as well as YeildFarm
3. Max duration per chapter
4. Max entries per chapter
@notice A chapter is assumed to complete if either it has surpassed
its max duration or has reached maximum number of entries.
@notice Not rigoursly tested. Might be unsafe for prodcution.
*/
contract StoryDao is Ownable{
    using SafeMath for uint256;
    using SafeMath for uint16;

    //1 percent of 100 percent
    uint16 public daofee = 100; 
    uint256 public weiPerToken = 10000;
    uint256 public whitelistfee = 0.01 ether; 
    uint256 public submissionZeroFee = 0.001 ether;
    //Duration for chapter in days
    uint16 public chapterDuration = 21;
    //Max entries a chapter can have
    uint16 public  maxEntriesPerChapter = 1000;
    uint16 public submissionCount = 0;
    uint256 public withdrawDeadline = 5 days; 

    uint256 public ownerBalance = 0;
    uint256 public whitelistCount = 0;
    uint256 public blacklistCount = 0;
    uint16 public imageGap = 0;
    uint16 public minImageGap = 50; //every 50th entry can be an image

    bytes32[] public submissionIndex; //index for submissions map
    //proposals
    Proposal[] public proposals;
    uint256 proposalCount = 0;

    bool public active = true;

    //LockableToken
    LockableToken public token;

    mapping(address => bool) public whitelist;
    mapping(address => bool) public blacklist;
    mapping(bytes32 => Submission) public submissions;
    mapping(address => uint256) public deletions;

    event Whitelisted(address indexed _address, bool _status);
    event Blacklisted(address indexed _address, bool _status);
    event SubmissionCommissionChanged(uint256 _newfees);
    event WhitelistfeeChanged(uint256 _newfees);
    event DaofeePercentChanged(uint16 _newpercent);
    event TokenAddressChanged(address indexed _tokenAddress);

    event SubmissionCreated(uint256 _index, bytes _content, bool _image, address _submitter);
    event SubmissionDeleted(uint256 _index, bytes _content, bool _image, address _submitter);

    event ProposalAdded(uint256 _id, uint8 _typeFlag, bytes32 _hash, string _description, address indexed _submitter);
    event ProposalExecuted(uint256 _id);
    event Voted(address _voter, bool _vote, uint256 _power, string reason);

    event StoryEnded();
    /**
    @dev Constructor for StoryDao
    @param _tokenAddress address of LockableToken
    */
    constructor(address _tokenAddress) public {
        require(_tokenAddress != address(0), "Token address cannot be null-address");
        token = LockableToken(_tokenAddress);
    }

    /**
    @dev Changes fee percent of YieldFarm i.e amount charged for converting
    ethereums to STToken. Can be called only by owner of this contract.
    Emit DaofeePercentChanged.
    @param _fee (uint16)
    @return status (bool)
    */
    function changeDaofeePercent(uint16 _fee) storyActive external onlyOwner returns (bool){
        require(_fee > 0, "Fee must be greater than zero");
        require(_fee < 100, "Fee percent must be less than 100");
        daofee = _fee;
        emit DaofeePercentChanged(daofee);
        return true;
    }

    /**
    @dev Changes fee whitelisting i.e amount that new blacklisted must give
    to become whitelisted. Can be called only by owner of this contract.
    Emit WhitelistfeeChanged.
    @param _fee (uint16)
    @return status (bool)
    */
    function changeWhitelistfee(uint256 _fee) storyActive external onlyOwner returns (bool){
        require(_fee > 0, "Fee must be greater than zero");
        whitelistfee = _fee;
        emit WhitelistfeeChanged(whitelistfee);
        return true;
    }

    /**
    @dev Changes fee for entry submission i.e amount. Can be called only by owner
    of this contract. Emit SubmissionCommissionChanged.
    @param _fee (uint16)
    @return status (bool)
    */
    function changeSubmissionfee(uint256 _fee) storyActive external onlyOwner returns (bool) {
        require(_fee > 0, "Fee must be greater than zero");
        submissionZeroFee = _fee;
        emit SubmissionCommissionChanged(submissionZeroFee);
        return true;
    }

    /**
    @dev Changes chapter duration. Days after which chapter is completed.
    Can be called only by owner of this contract.
    @param _days (uint16)
    @return status (bool)
    */
    function changeChapterDurationDays(uint16 _days) storyActive external onlyOwner returns (bool) {
        require(_days >= 1, "Chapter duration must be at least 1 day");
        chapterDuration = _days;
        return true;
    }
    
    /**
    @dev Changes chapter max entries, after which chapter is said completed.
    Can be called only by owner of this contract.
    @param _entries (uint16)
    @return status (bool)
    */
    function changeMaxEntries(uint16 _entries) storyActive external onlyOwner returns (bool) {
        require(_entries >= 1, "Chapter must have at least 1 entry");
        maxEntriesPerChapter = _entries;
        return true;
    }

    /**
    @dev whitelist the address provided enough ethers are received. If more than required ether
    is provided then rest is spent in tokens
    @param _address (address)
    */
    function whitelistAddress(address _address) storyActive public payable {
        require(_address != address(0));
        require(whitelist[_address] == false, "Candidate is already in whitelist.");
        require(blacklist[_address] == false, "Candidate is blacklisted!");
        require(whitelistfee <= msg.value, "Please send enough ethers for whitelisting fee!");
        whitelist[_address] = true;
        whitelistCount++;
        emit Whitelisted(_address, true);
        if (msg.value > whitelistfee){
            _buyTokenInternal(_address, msg.value.sub(whitelistfee));
        }
    }

    /**
    @dev blacklist the address.
    @param _address (address)
    */
    function blacklistAddress(address _address) storyActive public payable {
        require(_address != address(0));
        blacklist[_address] = true;
        whitelist[_address] = false;
        whitelistCount-=1;
        blacklistCount+=1;
        token.increaseLockedAmount(_address, token.getUnlockedAmount(_address));
        emit Blacklisted(_address, true);
    }

    function unblacklistAddress(address _address) storyActive payable public {
        require(blacklist[_address] == true, "Address is already whitelisted");
        require(msg.value >= 0.05 ether, "Require atleast 0.05 eth.");
        require(_notVoting(_address), "Wait till the execution of proposals that you've voted in");
        ownerBalance = ownerBalance.add(msg.value);
        blacklist[_address] = false;
        token.decreaseLockedAmount(_address, token.balanceOf(_address));
        emit Blacklisted(_address, false);
    }

    function _notVoting(address _address) internal view returns(bool) {
        for (uint256 i=0; i < proposalCount; i++){
            if (!proposals[i].isExecuted && proposals[i].voters[_address]){
                return false;
            }
        }
        return true;
    }

    /**
    @dev Callback function when ether is received.
    */
    receive () external payable {
        if (!whitelist[msg.sender]){
            whitelistAddress(msg.sender); 
        }else{
            //something else
        }
    }

    /**
    @dev Balance of token left in DAO.
    @return balance (uint256)
    */
    function daoTokenBalance() public view returns(uint256){
        return token.balanceOf(address(this));
    }

    /**
    @dev Change token address. Only owner. Emits TokenAddressChanged 
    @param _tokenAddress (address)
    */
    function changeTokenAddress(address _tokenAddress) storyActive onlyOwner public {
        require(_tokenAddress != address(0));
        token = LockableToken(_tokenAddress);
        emit TokenAddressChanged(_tokenAddress);
    }

    /**
    @dev buyTokenThrow. Same as buyToken but throws when balance is not enough.
    @param _buyer (address)
    @param _amountWei (uint256)
    */
    function buyTokenThrow(address _buyer, uint256 _amountWei) storyActive external returns (bool){
        require(_buyer != address(0));
        require(_amountWei > 0);
        require(whitelist[_buyer]);
        require(!blacklist[_buyer]);
        uint256 tokens = _amountWei/weiPerToken;
        uint256 daoBalance = daoTokenBalance();
        require(tokens < daoBalance);
        return token.transfer(_buyer, tokens);
    }

    /**
    @dev buyTokenInternal does not throw if dao has less amount of tokens to sell.
    @param _buyer (address)
    @param _amountWei (uint256)
    */
    function _buyTokenInternal(address _buyer, uint256 _amountWei) internal {
        require(_buyer != address(0));
        require(_amountWei > 0);
        require(whitelist[_buyer]);
        require(!blacklist[_buyer]);
        uint256 tokens = _amountWei/weiPerToken;
        uint256 daoBalance = daoTokenBalance();
        if (daoBalance < tokens)
            msg.sender.transfer(_amountWei);
        else 
            token.transfer(_buyer, tokens);
    }

    /**
    @dev calculate submisison fee required for current submission. It increases as number of 
    submission increase.
    @return submissionFee (uint256)
    */
    function _calculateSubmissionFee() view internal returns (uint256){
        return submissionCount * submissionZeroFee;
    }

    ///TODO: Break this function into smaller chunks
    function createSubmission(bytes memory _content, bool _image) storyActive memberOnly external payable {
        require(token.balanceOf(msg.sender) >= 10 ** token.decimals());
        uint256 fee = _calculateSubmissionFee();
        require(msg.value > fee, "Insufficient fee!");
        if (_image){
            require(imageGap >= minImageGap, "Image can only be submitted after every 50 texts");
            imageGap = 0; 
        } else {
            imageGap += 1;
        }
        bytes32 hashed = keccak256(abi.encode(_content, block.number));
        require(!submissions[hashed].exist, "Submission already exist in the block");
        submissionIndex.push(hashed);
        submissions[hashed] = Submission( _content, _image,
            submissionIndex.length-1,
            msg.sender,
            true
        );
        emit SubmissionCreated(
            submissions[hashed].index,
            submissions[hashed].content,
            submissions[hashed].isImage,
            submissions[hashed].submitter
        );
        submissionCount += 1;
        //--Owner's cut
        ownerBalance += fee.div(daofee);
    }

    /**
    @dev Transfer all of owner's share to owner.
    */
    function withdrawToOwner() public {
        payable(owner()).transfer(ownerBalance);
        ownerBalance = 0;
    }

    /**
    @dev Transfer min{_amount, owner's Balance} to owner.
    @param _amount (uin256)
    */
    function withdrawalAmountToOwner(uint256 _amount) public {
        uint256 withdraw = _amount;
        if (withdraw > ownerBalance)
            withdraw = ownerBalance;
        payable(owner()).transfer(withdraw);
        ownerBalance = ownerBalance.sub(withdraw);
    }

    /**
    @dev Whether submission with _hash already exists or not.
    @param _hash of submission (bytes32)
    */
    function submissionExist(bytes32  _hash) public view returns(bool){
        return submissions[_hash].exist;
    }

    /**
    @dev returns submission by hash
    @param _hash (bytes32)
    @return content (bytes)
    @return image (bool)
    @return submitter (address)
    @notice Assumes: Submission already exist.
    */
    function getSubmission(bytes32  _hash) public view returns (bytes memory content, bool image, address submitter){
        return (submissions[_hash].content, 
            submissions[_hash].isImage, 
            submissions[_hash].submitter);
    }

    /**
    @dev (Utility) Returns all of the submission's hashes.
    @return submissions (bytes32 array)
    */
    function getAllSubmissionHashes() public view returns (bytes32[] memory){
        return submissionIndex;
    }

    /**
    @dev (Utility) Returns submission count.
    @return total count (uint256)
    */
    function getSubmissionCount() public view returns (uint256) {
        return submissionIndex.length;
    }

    /**
    @dev Remove a submission having hash = _hash, provided it already exist.
    @param _hash (bytes32)
    */
    function _deleteSubmission(bytes32  _hash) internal returns(bool) {
        require(submissionExist(_hash), "Submission doesn't exist");
        Submission storage sub = submissions[_hash];
        sub.exist = false;
        deletions[submissions[_hash].submitter] += 1;
        if (deletions[submissions[_hash].submitter] >= 5){
            blacklistAddress(submissions[_hash].submitter);
        }
        emit SubmissionDeleted(sub.index, sub.content, sub.isImage, sub.submitter);
        submissionCount -= 1;
        return true;
    }

    function vote(uint256 _proposalId, bool _vote, string calldata _reason, uint256 _votePower) storyActive tokenHolderOnly public returns(int256){
        require(_votePower > 0, "At least some power must be given to vote.");
        require(uint256(_votePower) <= token.balanceOf(msg.sender), "Voter must have enough token to cover power cost.");
        Proposal storage p = proposals[_proposalId];
        require(!p.isExecuted, "Proposal must not have been executed already.");
        require(p.deadline > now, "Proposal must not have expired.");
        require(!p.voters[msg.sender], "User must not have already voted.");
        Vote memory pVote;
        pVote.inSupport = _vote;
        pVote.reason = _reason;
        pVote.voter = msg.sender;
        pVote.power = _votePower;
        p.votes.push(pVote);
        p.voters[msg.sender] = true;
        p.currentResult = (_vote)? p.currentResult+int256(_votePower) : p.currentResult - int256(_votePower);
        token.increaseLockedAmount(msg.sender, _votePower);
        emit Voted(msg.sender, _vote, _votePower, _reason);
        return p.currentResult;
    }


    function proposeDeletion(bytes32 _hash, string calldata _desc) storyActive memberOnly public{
        require(submissionExist(_hash), "Submission not there.");
        uint256 proposalId = proposals.length+1;
        Proposal storage proposal = proposals[proposalId];
        proposal.description= _desc;
        proposal.isExecuted = false;
        proposal.creationDate = now;
        proposal.submitter = msg.sender;
        proposal.typeFlag = 1; //deletion
        proposal.target = _hash;
        proposal.deadline = now + 2 days;
        emit ProposalAdded(proposalId, 1, _hash, _desc, msg.sender);
        proposalCount += 1;
    }

    function proposeDeletionUrgent(bytes32 _hash, string calldata _desc) storyActive onlyOwner public {
        require(submissionExist(_hash), "Submission not there.");
        uint256 proposalId = proposals.length+1;
        Proposal storage proposal = proposals[proposalId];
        proposal.description = _desc;
        proposal.isExecuted = false;
        proposal.creationDate = now;
        proposal.typeFlag = 1;
        proposal.target = _hash;
        proposal.deadline = now + 4 hours;
        emit ProposalAdded(proposalId, 1, _hash, _desc, msg.sender);
        proposalCount += 1;
    }

    function executeProposal(uint256 _id) storyActive public {
        Proposal storage proposal = proposals[_id];
        require(now >= proposal.deadline && !proposal.isExecuted);
        if (proposal.typeFlag == 1 && proposal.currentResult > 0){
            assert(_deleteSubmission(proposal.target));
        }
        uint256 len = proposal.votes.length;
        for (uint i=0; i < len; i++){ 
            token.decreaseLockedAmount(proposal.votes[i].voter, proposal.votes[i].power);
        }
        proposal.isExecuted = true;
        emit ProposalExecuted(_id);
    }

    function endStory() storyActive external {
        withdrawToOwner();
        active = false;
        emit StoryEnded();
    }

    function withdrawLeftoverTokens() external onlyOwner{
        require(!active, "Cannot be called when story is active.");
        token.transfer(msg.sender, token.balanceOf(address(this)));
        token.transferOwnership(msg.sender);
    }

    function unlockMyTokens() external {
        require(!active, "Cannot be called when story is active.");
        require(token.getLockedAmount(msg.sender) > 0, "Must have some locked amount.");
        token.decreaseLockedAmount(msg.sender, token.getLockedAmount(msg.sender));
    }

    //dividend
    function withdrawDividend() memberOnly external {
        require(!active, "Cannot be called when story is active.");
        uint256 owed = address(this).balance.div(whitelistCount);
        msg.sender.transfer(owed);
        whitelist[msg.sender] = false;
        whitelistCount--;
    }

    function withdrawEverythingPostDeadline() external onlyOwner {
        require(!active, "Cannot be called when story is active.");
        require(now > withdrawDeadline+3 days);
        payable(owner()).transfer(address(this).balance);
    } 
    //---modifier

    modifier storyActive() {
        require(active == true);
        _;
    }

    modifier tokenHolderOnly() {
        require(token.balanceOf(msg.sender) >= 10**token.decimals(),
        "Must have sufficient tokens");
        _;
    }

    modifier memberOnly() {
        require(whitelist[msg.sender], "Must be whitelisted");
        require(!blacklist[msg.sender], "Must not be blacklisted");
        _;
    }

}
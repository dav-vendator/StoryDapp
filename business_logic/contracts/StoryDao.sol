//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./LockableToken.sol";
import "./SubmissionStruct.sol";

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

    uint256 public ownerBalance = 0;
    uint256 public whitelistCount = 0;
    uint256 public blacklistCount = 0;
    uint16 public imageGap = 0;
    uint16 public minImageGap = 50; //every 50th entry can be an image

    bytes32[] public submissionIndex; //index for submissions map
    //LockableToken
    LockableToken public token;

    mapping(address => bool) public
 whitelist;
    mapping(address => bool) public
 blacklist;
    mapping(bytes32 => Submission) public submissions;

    event Whitelisted(address indexed _address, bool _status);
    event Blacklisted(address indexed _address, bool _status);
    event SubmissionCommissionChanged(uint256 _newfees);
    event WhitelistfeeChanged(uint256 _newfees);
    event DaofeePercentChanged(uint16 _newpercent);
    event TokenAddressChanged(address indexed _tokenAddress);

    event SubmissionCreated(uint256 _index, bytes _content, bool _image, address _submitter);
    event SubmissionDeleted(uint256 _index, bytes _content, bool _image, address _submitter);
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
    function changeDaofeePercent(uint16 _fee) external onlyOwner returns (bool){
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
    function changeWhitelistfee(uint256 _fee) external onlyOwner returns (bool){
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
    function changeSubmissionfee(uint256 _fee) external onlyOwner returns (bool) {
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
    function changeChapterDurationDays(uint16 _days) external onlyOwner returns (bool) {
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
    function changeMaxEntries(uint16 _entries) external onlyOwner returns (bool) {
        require(_entries >= 1, "Chapter must have at least 1 entry");
        maxEntriesPerChapter = _entries;
        return true;
    }

    /**
    @dev whitelist the address provided enough ethers are received
    */
    function whitelistAddress(address _address) public payable {
        require(_address != address(0));
        require(!whitelist[_address], "Candidate is already in whitelist.");
        require(blacklist[_address], "Candidate is blacklisted!");
        require(msg.value < whitelistfee, "Please send enough ethers for whitelisting fee!");
        whitelist[_address] = true;
        whitelistCount++;
        emit Whitelisted(_address, true);

        if (msg.value > whitelistfee){
            //buyToken(_address, msg.value.sub(whitelistfee))
        }

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
    function changeTokenAddress(address _tokenAddress) onlyOwner public {
        require(_tokenAddress != address(0));
        token = LockableToken(_tokenAddress);
        emit TokenAddressChanged(_tokenAddress);
    }

    /**
    @dev buyTokenThrow. Same as buyToken but throws when balance is not enough.
    @param _buyer (address)
    @param _amountWei (uint256)
    */
    function buyTokenThrow(address _buyer, uint256 _amountWei) external returns (bool){
        require(_buyer != address(0));
        require(_amountWei > 0);
        require(whitelist[_buyer]);
        require(!blacklist[_buyer]);
        uint256 tokens = _amountWei/weiPerToken;
        uint256 daoBalance = daoTokenBalance();
        require(tokens < daoBalance);
        return token.transfer(_buyer, tokens);
    }

    //Not external callable
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

    function _calculateSubmissionFee() view internal returns (uint256){
        return submissionCount * submissionZeroFee;
    }

    ///TODO: Break this function into smaller chunks
    ///TODO: Owner and Transfer function
    function createSubmission(bytes memory _content, bool _image) external payable{
        require(token.balanceOf(msg.sender) >= 10 ** token.decimals());
        require(whitelist[msg.sender], "Must be whitelisted");
        require(!blacklist[msg.sender], "Must not be blacklisted");
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

    //owner's 
    function withdrawToOwner() public {
        owner.transfer(ownerBalance);
        ownerBalance = 0;
    }

    function withdrawalAmountToOwner(uint256 _amount) public{
        uint256 withdraw = _amount;
        if (withdraw > ownerBalance)
            withdraw = ownerBalance;
        owner.trasfer(withdraw);
        ownerBalance = ownerBalance.sub(withdraw);
    }
}
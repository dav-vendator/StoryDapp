//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./LockableToken.sol";

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
    uint16 private daofee = 100; 
    //0.01 ether
    uint256 private whitelistfee = 10000000000000000; 
    //0.01 ether
    uint256 private submissionfee = 10000000000000000;
    //Duration for chapter in days
    uint16 private chapterDuration = 21;
    //Max entries a chapter can have
    uint16 private  maxEntriesPerChapter = 1000;

    uint256 private whitelistCount;
    uint256 private blacklistCount;
    //LockableToken
    LockableToken public token;

    mapping(address => bool) private whitelist;
    mapping(address => bool) private blacklist;

    event Whitelisted(address indexed _address, bool _status);
    event Blacklisted(address indexed _address, bool _status);
    event SubmissionCommissionChanged(uint256 _newfees);
    event WhitelistfeeChanged(uint256 _newfees);
    event DaofeePercentChanged(uint16 _newpercent);

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
        submissionfee = _fee;
        emit SubmissionCommissionChanged(submissionfee);
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

    function daoTokenBalance() public view returns(uint256){
        return token.balanceOf(address(this));
    }
}
//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0;
import "./VoteStruct.sol";

struct Proposal {
    string description;
    bool isExecuted;
    int256 currentResult;
    uint8 typeFlag; //type of proposal {deletion, increase or decrease etc.}
    bytes32 target; //Target of the propsal {submissions, fee etc.}
    uint256 creationDate;
    uint256 deadline;
    Vote[] votes;
    address submitter;
    mapping(address => bool) voters;
}
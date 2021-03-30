//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0;

struct Submission{
    bytes content;
    bool isImage;
    uint256 index;
    address submitter;
    bool exist;
}
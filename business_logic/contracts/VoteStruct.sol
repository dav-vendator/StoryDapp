//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0;
struct Vote{
    bool inSupport;
    address voter;
    string reason;
    uint256 power;
}
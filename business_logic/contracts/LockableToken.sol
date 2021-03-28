//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0;

import "@openzeppelin/contracts/access/Ownable.sol";

//For ease in Contract to Contract communication
abstract contract LockableToken is Ownable{
    function totalSupply() public virtual view returns (uint256);

    function balanceOf(address _who) public virtual view returns (uint256);
    function allowance(address _owner, address _spender) public virtual view returns (uint256);

    function getLockedAmount(address _owner) public virtual view returns (uint256);
    function getUnlockedAmount(address _owner) public virtual view returns (uint256);

    function transfer(address _recipient, uint256  _amount) public virtual returns (bool);
    function transferFrom(address _sender, address _recipient, uint256 _amount) public virtual returns (bool);

    function increaseLockedAmount(address _owner, uint256 _amount) public virtual returns (uint256);
    function decreaseLockedAmount(address _owner, uint256 _amount) public virtual  returns (uint256);

    function transferAndCall(address _recipient, uint256 _amount, bytes memory  _data) public virtual payable returns (bool);
    function transferFromAndCall(address _owner, address _recipient, uint256 _amount, bytes memory _data) public virtual payable returns (bool);

    function approve(address _thirdparty, uint256 _amount) public virtual returns (bool);
    function approveAndCall(address _spender, uint256 _amount, bytes memory _data) public virtual  returns (bool);

    event Transfer(address indexed _owner, address indexed _spender, uint256 _amount);

    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
}
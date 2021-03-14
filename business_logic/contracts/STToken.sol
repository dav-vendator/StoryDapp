//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract STToken is IERC20, Ownable{
  using SafeMath for uint256;

  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public _totalSupply;

  //Mappings
  mapping (address => uint256) locked;
  mapping (address => uint256) balances;
  mapping (address => mapping(address => uint)) internal allowed;
  
  //Events
  event Locked(address indexed owner, uint256 indexed amount);

  constructor() public {
    name = "STToken";
    symbol = "STT";
    decimals = 18;
    _totalSupply = 100 * 10**(8+6);
    //Creator of contract have full supply
    balances[msg.sender] = _totalSupply;
  }

  function totalSupply() override external view returns (uint256){
    return _totalSupply;
  }

  function balanceOf(address _account) override external view returns (uint256){
    require(_account != address(0));
    return balances[_account];
  }

  function transfer(address _recipient, uint256 _amount) override external returns (bool){
    require(_recipient != address(0)); //address is valid
    require(_amount > 0); //valid amount
    require(balances[msg.sender] - locked[msg.sender] >= _amount); //balance is okay
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_recipient] = balances[_recipient].add(_amount);
    emit Transfer(msg.sender, _recipient, _amount);
    return true;
  }

  //getAllowances
  function allowance(address _owner, address _spender) override external view returns (uint256){
    require(_owner != address(0));
    require(_spender != address(0));

    return allowed[_owner][_spender];
  }

  //approve
  function approve(address _spender, uint256 _amount) override external returns (bool){
    require(_spender !=  address(0));
    require(_amount > 0); 
    //Might wanna check for other allowances
    require(balances[msg.sender] > _amount);
    allowed[msg.sender][_spender] = _amount;
    emit Approval(msg.sender, _spender, _amount);
    return true;
  }

  //transfer from one to another account
  function transferFrom(address _sender, address _recipient,uint256 _amount) override external returns (bool){
    require(_sender != address(0));
    require(_recipient != address(0));
    require(_amount > 0);
    require(balances[_sender] - locked[_sender] >= _amount);
    balances[_sender] = balances[_sender].sub(_amount);
    balances[_recipient] = balances[_recipient].add(_amount);
    emit Transfer(_sender, _recipient, _amount);
    return true;
  }

  //Extras
  function increaseLockedAmount(address _owner, uint256 _amount) public onlyOwner returns (uint256) {
    require(_owner != address(0));
    require(_amount >= 0);
    uint256 lockingAmount = locked[_owner].add(_amount);
    require(this.balanceOf(_owner) > lockingAmount); //Add message
    locked[_owner] = lockingAmount;
    emit Locked(_owner, _amount);
    return locked[_owner];
  }

  //decrease locked amount by _amount
  function decreaseLockedAmount(address _owner, uint256 _amount) public onlyOwner returns (uint256) {
    require(_owner != address(0));
    require(_amount >= 0);
    uint256 amount = locked[_owner];
    if (_amount > amount){
      _amount = amount;
    }
    locked[_owner] = amount.sub(_amount);
    emit Locked(_owner, locked[_owner]);
  }

}

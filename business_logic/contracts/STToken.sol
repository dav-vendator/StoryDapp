//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract STToken is ERC20 {
  constructor() ERC20("Story Token", "STT") public {
    _mint(msg.sender, 100*10**(8+6));
  }
}

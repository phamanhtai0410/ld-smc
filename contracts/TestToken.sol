// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AnimeToken is ERC20 {
    constructor() ERC20("Anime Token", "ANIME") {
        _mint(msg.sender, 1000 * 10 ** 18 * 10 ** 6);
    }
}

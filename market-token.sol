// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

library Address {
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

error FailedToCallTokenReceivedHook();

interface IMarketTokenReceiver {
    function tokensReceived(address from,uint256 amount,bytes calldata data) external;
}

contract MarketToken is ERC20, Ownable {
    using Address for address;
    constructor()
        ERC20("MarketToken", "MT")
        Ownable(msg.sender)
    {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function transferWithCallback(IMarketTokenReceiver to, uint256 amount, bytes calldata data) external returns (bool) {
        address from = msg.sender;
        _transfer(from, address(to), amount);
        if (address(to).isContract()) {
            IMarketTokenReceiver(to).tokensReceived(from, amount, data);
        }
        return true;
    }
}
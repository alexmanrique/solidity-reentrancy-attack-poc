// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {Test} from "../lib/forge-std/src/Test.sol";
import {SimpleBank} from "../src/SimpleBank.sol";
import {Attacker} from "../src/Attacker.sol";

contract AttackerTest is Test {
    address owner = vm.addr(1);
    address maliciousUser = vm.addr(2);
    address randomUser = vm.addr(3);

    uint256 etherToDealBank = 50 ether;
    uint256 etherToDealAttacker = 10 ether;

    SimpleBank bank;
    Attacker attacker;

    function setUp() public {
        vm.startPrank(owner);
        bank = new SimpleBank();
        vm.stopPrank();

        vm.deal(address(bank), etherToDealBank);
        assert(address(bank).balance == etherToDealBank);

        attacker = new Attacker(address(bank));
    }

    function testExecuteAttack() public {
        uint256 bankBalanceBefAttack = address(bank).balance;
        assert(bankBalanceBefAttack == etherToDealBank);

        uint256 attackerBalanceBefAttack = address(attacker).balance;
        assert(attackerBalanceBefAttack == 0);

        attacker.attack{value: etherToDealAttacker}();

        uint256 bankBalanceAftAttack = address(bank).balance;
        assert(bankBalanceAftAttack == 0);

        uint256 attackerBalanceAftAttack = address(attacker).balance;

        assert(attackerBalanceAftAttack == etherToDealBank + etherToDealAttacker);
    }

    function testExecuteAttackWithoutVulnerability() public {
        uint256 bankBalanceBefAttack = address(bank).balance;
        assert(bankBalanceBefAttack == etherToDealBank);

        uint256 attackerBalanceBefAttack = address(attacker).balance;
        assert(attackerBalanceBefAttack == 0);

        vm.expectRevert("Failure");
        attacker.attackWithoutVulnerability{value: etherToDealAttacker}();

        uint256 bankBalanceAftAttack = address(bank).balance;
        // El banco debería mantener sus 50 ether porque el reentrancy está bloqueado
        assert(bankBalanceAftAttack == etherToDealBank);

        uint256 attackerBalanceAftAttack = address(attacker).balance;
        // Cuando la función revierte, todo el estado se revierte, incluyendo el deposit
        assert(attackerBalanceAftAttack == 0);
    }

    function testExecuteAttackWithoutVulnerabilityNotEnoughEther() public {
        uint256 bankBalanceBefAttack = address(bank).balance;
        assert(bankBalanceBefAttack == etherToDealBank);

        uint256 attackerBalanceBefAttack = address(attacker).balance;
        assert(attackerBalanceBefAttack == 0);

        vm.expectRevert("Minimum deposit is 1 ETH");
        attacker.attackWithoutVulnerability{value: 0.5 ether}();

        uint256 bankBalanceAftAttack = address(bank).balance;
        assert(bankBalanceAftAttack == etherToDealBank);

        uint256 attackerBalanceAftAttack = address(attacker).balance;
        assert(attackerBalanceAftAttack == 0);
    }
}

# Solidity Reentrancy Attack - Proof of Concept

This project demonstrates a **reentrancy** vulnerability in a Solidity smart contract using Foundry.

## What is Reentrancy?

Reentrancy is a critical vulnerability where a malicious contract can repeatedly call a function before internal states are updated, allowing it to drain funds from the vulnerable contract.

## Contracts

### SimpleBank (Vulnerable)

A simple banking contract that allows:

- **`deposit()`**: Deposit ETH (minimum 1 ETH)
- **`withdraw()`**: Withdraw user balance
- **`totalBalance()`**: View the contract's total balance

**Vulnerability**: The `withdraw()` function updates the user's balance (`userBalance[msg.sender] = 0`) **after** sending ETH, allowing a malicious contract to repeatedly call `withdraw()` before the state is updated.

### Attacker

A malicious contract that exploits the vulnerability:

- **`attack()`**: Deposits ETH and then withdraws
- **`receive()`**: When receiving ETH, calls `withdraw()` again if the contract still has funds

## How the Attack Works

1. The attacker deposits 1 ETH into `SimpleBank`
2. Calls `withdraw()` to withdraw their balance
3. `SimpleBank` sends 1 ETH to the `Attacker` contract
4. The `Attacker`'s `receive()` function is automatically executed
5. From `receive()`, it calls `withdraw()` again **before** `userBalance` is updated to 0
6. The process repeats until `SimpleBank` runs out of funds

## Solution

Apply the **Checks-Effects-Interactions** pattern:

- **Checks**: Validate conditions
- **Effects**: Update internal states first
- **Interactions**: Perform external calls last

```solidity
function withdraw() public {
    require(userBalance[msg.sender] >= 1 ether, "User has not enough balance");

    uint256 amount = userBalance[msg.sender];
    userBalance[msg.sender] = 0; // Update state BEFORE sending ETH

    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
}
```

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Run Tests

```shell
$ forge test
```

### Run Tests with Verbose Output

```shell
$ forge test -vvv
```

### Format Code

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil (Local Node)

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Deploy.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## ⚠️ Warning

This code is for educational and demonstration purposes only. **DO NOT** use this code in production. Always audit your contracts before deploying them.

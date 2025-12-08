// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

contract SimpleBank {
    mapping(address => uint256) public userBalance;

    function deposit() public payable {
        require(msg.value >= 1 ether, "Minimum deposit is 1 ETH");
        userBalance[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount_) public {
        //Reentrancy attack can be done here
        require(amount_ >= 1 ether, "Min amount 1 ether");
        require(address(this).balance >= amount_);

        uint256 userBalance_ = userBalance[msg.sender];
        require(userBalance_ >= amount_, "User has not enough balance");

        (bool success,) = msg.sender.call{value: amount_}("");
        require(success, "fail");

        userBalance[msg.sender] = userBalance_ - amount_;
    }

    function withdrawWithoutVulnerability(uint256 amount_) public {
        //Reentrancy attack can be done here
        require(amount_ >= 1 ether, "Min amount 1 ether");
        require(address(this).balance >= amount_);

        uint256 userBalance_ = userBalance[msg.sender];
        require(userBalance_ >= amount_, "User has not enough balance");

        userBalance[msg.sender] = userBalance_ - amount_;

        (bool success,) = msg.sender.call{value: amount_}("");
        require(success, "Failure");
    }

    function totalBalance() public view returns (uint256) {
        return address(this).balance;
    }
}


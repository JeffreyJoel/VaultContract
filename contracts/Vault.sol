// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Vault {
    struct Grant {
        uint amount;
        uint claimTime;
        bool claimed;
    }

    mapping(address => Grant) public grants;

    event GrantCreated(address indexed beneficiary, uint amount, uint claimTime);
    event GrantClaimed(address indexed beneficiary, uint amount, uint when);

    constructor() {}

    function offerGrant(address beneficiary, uint amount, uint claimTime) public payable {
        require(beneficiary != address(0), "Beneficiary address cannot be  0");
        require(amount >  0, "Grant amount must be greater than  0");
        require(claimTime > block.timestamp, "Claim time must be in the future");
        // require(msg.value == amount, "Sent value must match the grant amount");

        grants[beneficiary] = Grant(amount, claimTime, false);

        emit GrantCreated(beneficiary, amount, claimTime);
    }

    function claimGrant() public {
        Grant storage grant = grants[msg.sender];

        require(grant.amount >  0, "No grant available for this address");
        require(block.timestamp >= grant.claimTime, "Claim time has not yet been reached");
        require(!grant.claimed, "Grant has already been claimed");

        grant.claimed = true;

        payable(msg.sender).transfer(grant.amount);

        emit GrantClaimed(msg.sender, grant.amount, block.timestamp);
    }
}

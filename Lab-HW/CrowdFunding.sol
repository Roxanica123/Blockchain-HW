// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.9;

contract CrowdFunding {

    address admin;
    uint fundingGoal;
    uint currentFunding;
    bool goalReached;

    
    mapping(address => contributor) contributors;

    struct contributor {
        string name;
        address account;
        uint contributed;
    } 

    constructor(uint goal) {
        admin = msg.sender;
        fundingGoal = goal;
        currentFunding = 0;
        goalReached = false;
    }
    
    function addContributor(string calldata _name) payable external {
        require(msg.value > 0, "You need to contribute with something!");
        require(!goalReached && msg.value + currentFunding <= fundingGoal, "I don't need that much, check the current funding");
        
        uint value = contributors[msg.sender].contributed + msg.value;
        contributors[msg.sender] = contributor(_name, msg.sender, value);
        currentFunding += msg.value;
        if (currentFunding == fundingGoal) {
            goalReached = true;
        }
    }

    function withdrawContribution(uint sum) public {
        require(!goalReached, "The goal has been reached, you cannot withdraw");
        uint contributed = contributors[msg.sender].contributed;
        require(contributed>=sum, "You have hot contributed with that much");
        if(sum == contributed){
            delete contributors[msg.sender];
        }
        else{
            contributors[msg.sender].contributed -= sum;
        }
        
        currentFunding -= sum;
    }

    function getCurrentFunding() view public returns (uint) {
        return currentFunding;
    }

    function getContributor(address _address) view public returns (string memory, uint) {
        contributor memory wantedContributor = contributors[_address];
        return (wantedContributor.name, wantedContributor.contributed);
    }

    function isGoalReached() view public returns (bool) {
        return goalReached;
    }
}
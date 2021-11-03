// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.9;

contract CrowdFunding {
    address admin;
    uint256 fundingGoal;
    uint256 currentFunding;
    uint256 sponsored; 
    bool goalReached;

    mapping(address => contributor) contributors;

    struct contributor {
        string name;
        address account;
        uint256 contributed;
    }

    constructor(uint256 goal) {
        admin = msg.sender;
        fundingGoal = goal;
        currentFunding = 0;
        goalReached = false;
    }

    function addContributor(string calldata _name) external payable {
        require(msg.value > 0, "You need to contribute with something!");
        require(
            !goalReached && msg.value + currentFunding <= fundingGoal,
            "I don't need that much, check the current funding"
        );

        uint256 value = contributors[msg.sender].contributed + msg.value;
        contributors[msg.sender] = contributor(_name, msg.sender, value);
        currentFunding += msg.value;
        if (currentFunding == fundingGoal) {
            goalReached = true;
        }
    }

    function withdrawContribution(uint256 sum) public {
        require(!goalReached, "The goal has been reached, you cannot withdraw");
        uint256 contributed = contributors[msg.sender].contributed;
        require(contributed >= sum, "You have hot contributed with that much");
        if (sum == contributed) {
            delete contributors[msg.sender];
        } else {
            contributors[msg.sender].contributed -= sum;
        }
        payable(msg.sender).transfer(sum);
        currentFunding -= sum;
    }

    function getCurrentFunding() public view returns (uint256) {
        return currentFunding;
    }

    function getContributor(address _address)
        public
        view
        returns (string memory, uint256)
    {
        contributor memory wantedContributor = contributors[_address];
        return (wantedContributor.name, wantedContributor.contributed);
    }

    function isGoalReached() public view returns (bool) {
        return goalReached;
    }
}

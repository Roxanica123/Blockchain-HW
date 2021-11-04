// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.9;

interface ISponsorFunding {

    function reedemPromise() external;
}

interface IDistributeFunding{
    function colectCrowdFundingMoney() payable external;
}

contract CrowdFunding {
    address admin;
    address dfAddress;
    address sponsorAddress;
    
    uint256 fundingGoal;
    uint256 currentFunding;
    uint256 sponsoredAmount;
    
    bool goalReached;
    bool promisedReceived;
    bool sponsorshipReceived;

    mapping(address => contributor) contributors;

    struct contributor {
        string name;
        address account;
        uint256 contributed;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "You don't have the permission");
        _;
    }

    constructor(uint256 goal, address _dfAddress) {
        admin = msg.sender;
        dfAddress = _dfAddress;
        
        fundingGoal = goal;
        currentFunding = 0;
        
        goalReached = false;
        promisedReceived = false;
        sponsorshipReceived = false;
    }

    function addContributor(string calldata _name) external payable {
        //require(promisedReceived, "Sponsorship not ready");
        require(msg.value > 0, "You need to contribute with something!");
        require(
            !goalReached && msg.value + currentFunding + sponsoredAmount <= fundingGoal,
            "I don't need that much, check the current funding"
        );

        uint256 value = contributors[msg.sender].contributed + msg.value;
        contributors[msg.sender] = contributor(_name, msg.sender, value);
        currentFunding += msg.value;
        
        if (currentFunding + sponsoredAmount == fundingGoal) {
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

    function getContributor(address _address) public view
    returns (string memory, uint256)
    {
        contributor memory wantedContributor = contributors[_address];
        return (wantedContributor.name, wantedContributor.contributed);
    }

    function isGoalReached() public view returns (bool) {
        return goalReached;
    }

    function getCurrentFunding() public view returns (uint256) {
        return currentFunding;
    }
    
     function getFundingGoal() public view returns (uint256) {
        return fundingGoal;
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    function promiseFounds(uint _promisedFunds) external {
        require(_promisedFunds + currentFunding <= fundingGoal, "Too much sponsorship");
        promisedReceived = true;
        sponsoredAmount = _promisedFunds;
        sponsorAddress = msg.sender;
    }

    function reedemPromise() onlyAdmin() public {
        ISponsorFunding(sponsorAddress).reedemPromise();
    }

    function receiveSponsorship() public payable{
        require(msg.sender == sponsorAddress);
        require(msg.value == sponsoredAmount);
        sponsorshipReceived = true;
    }

    function sendRaisedFundToDF() public payable  {
        require(
            goalReached && sponsorshipReceived,
            "Not ready, goal not reached or sponsorship not received"
        );

        IDistributeFunding(dfAddress)
        .colectCrowdFundingMoney{value: address(this).balance}
        ();

    }
}

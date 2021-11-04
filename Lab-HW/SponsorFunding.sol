// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.9;

interface ICrowdFunding {

    struct contributor {
        string name;
        address account;
        uint contributed;
    } 

    function addContributor(string calldata _name) payable external;
    
    function giveDonation(address, uint, uint ) payable external returns (bool);
    
    function isGoalReached() view external returns (bool);
    
    function getFundingGoal() view external returns (uint);
    
    function promiseFounds(uint) external;
    
    function receiveSponsorship() external payable;
}


contract SponsorFunding {
    uint  prommisedAmmount;
    
    address public crowdFoundingContractAdr;
    address owner;
    
    bool alreadySentInitialAmmount = false;
    bool alreadyGivePrommisedAmmount = false;
    
    

    constructor(address _crowdFoundingContractAdr , uint _percent) payable{
        require(msg.value > 0, "Pay me!");
        
        uint goal = ICrowdFunding(_crowdFoundingContractAdr).getFundingGoal();

        prommisedAmmount = _percent * goal / 100;
        
        require(prommisedAmmount <= msg.value, "You didn't send the founds required!");
        
        // return the extra money
        payable(msg.sender).transfer(msg.value - (prommisedAmmount) );
        
        crowdFoundingContractAdr = _crowdFoundingContractAdr;
        owner = msg.sender;
    }   


    function checkBalance() external view returns (uint) {
        return address(this).balance;
    }
    
    
    function sendPromise() external {
        ICrowdFunding(crowdFoundingContractAdr).promiseFounds(prommisedAmmount);
    }
    
    
    function reedemPromise() external  {
        require(!alreadyGivePrommisedAmmount,"Already give the prommised ammount!");
        require(msg.sender == crowdFoundingContractAdr || msg.sender == owner);
        
        ICrowdFunding cf =  ICrowdFunding(crowdFoundingContractAdr);
    
        require( msg.sender.balance + prommisedAmmount == cf.getFundingGoal() , "The gol has not been reched!");

        cf.receiveSponsorship{value:prommisedAmmount}();
        
        alreadyGivePrommisedAmmount = true;
    }
    
 
}

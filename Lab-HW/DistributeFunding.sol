// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.9;

contract DistributeFunding {
    bool isMoneyColected = false;
    uint256 money = 0; 

    address admin;

    uint256 index;
    uint256 public remainingPercent;
    mapping(uint256 => recipient) recipients;

    struct recipient {
        string name;
        address account;
        uint256 percent;
        uint256 index;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "You don't have the permission");
        _;
    }

    constructor()  {
        admin = msg.sender;
        index = 0;
        remainingPercent = 100;
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    function addRecipient( string calldata _name, uint256 _percent, address _address)
    external onlyAdmin {
        require(_percent <= remainingPercent, "The percent is too big");
        recipients[index] = recipient(_name, _address, _percent, index);
        index += 1;
        remainingPercent -= _percent;
    }

    function seeRecipient(uint256 _index) public view
    returns (string memory, uint256) 
    {
        recipient memory wantedRecipient = recipients[_index];
        return (wantedRecipient.name, wantedRecipient.percent);
    }

    function distribute() onlyAdmin() public {
        require(remainingPercent == 0, "The are not enough recipients");
        recipient memory r;
        for (uint256 i = 0; i < index; i++) {
            r = recipients[i];
            payable(r.account)
            .transfer( (money * r.percent) / 100);
        }
    }

    function colectCrowdFundingMoney() payable external {
        isMoneyColected = true;
        money = address(this).balance;
        
    }
}

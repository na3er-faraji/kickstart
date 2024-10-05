// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract CampaignFactory {
    Campaign[] public deployedCampains;

    function createCampaign(uint minimum) public {
        Campaign newCampaign = new Campaign(minimum, msg.sender);
        deployedCampains.push(newCampaign);
    }

    function getDeployedCampaign() public view returns (Campaign[] memory) {
        return deployedCampains;
    } 

}

contract Campaign {
    
    struct Request {
        string description;
        uint value;
        address payable recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }

    mapping(uint => Request) public requests;
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public approvers;
    uint numRequests;
    uint approversCount;

    constructor(uint minimum, address creator) {
        manager = creator;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(
            msg.value >= minimumContribution,
            "A minumum contribution is required."
        );

        approvers[msg.sender] = true;
        approversCount++;
    }

  function createRequest(string memory description, uint256 value, address payable recipient) public restricted {
        Request storage r = requests[numRequests++];
        r.description = description;
        r.value = value;
        r.recipient = recipient;
        r.complete = false;
        r.approvalCount = 0;
    }

    function approveRequest(uint index) public {
        Request storage request = requests[index];

      require(
            approvers[msg.sender],
            "Only contributors can approve a specific payment request"
        );
        require(
            !request.approvals[msg.sender],
            "You have already voted to approve this request"
        );

        request.approvals[msg.sender] = true;
        request.approvalCount++;  
        
    }

    function finalizeRequest(uint index) public restricted payable{
        Request storage request = requests[index];

        require(
            request.approvalCount > (approversCount / 2),
            "This request needs more approvals before it can be finalized"
        );

        require(!(request.complete), "This request has already been finalized");

        request.recipient.transfer(request.value);
        request.complete = true;
    }

    modifier restricted() {
        require(
            msg.sender == manager,
            "Only the campaign manager can call this function."
        );
        _;
    }

}
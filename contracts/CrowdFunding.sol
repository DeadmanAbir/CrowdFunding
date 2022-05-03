//SPDX-License-Identifier: UNLICENSED 
pragma solidity >=0.5.0 < 0.9.0;

contract CrowdFunding{
    address manager;
    mapping(address=>uint) public contributors;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    constructor(uint _target, uint _deadline){
        manager=msg.sender;
        target=_target;
        deadline=block.timestamp+_deadline;
        minimumContribution=200 wei;
    }
    modifier onlyOwner(){
        require(manager==msg.sender,"Only manager has access to it");
        _;
    }
    struct Request{
        string description;
        address recipient;
        uint value; 
        bool completed;
        uint noofVoters;
        mapping(address=>bool) voters;
    }
    mapping(uint=>Request) public requests;
    uint public numRequests;
    function pay()public payable{
        require(block.timestamp<deadline,"Deadline has passed");
        require(msg.value>=minimumContribution,"doesn't exceed the minimum contribution!");
        if(contributors[msg.sender]==0){
           noOfContributors++;
        }
         contributors[msg.sender]+=msg.value;
         raisedAmount+=msg.value;
    }
    function balance()public view returns(uint){
        return address(this).balance;
    }
    function refund()public{
        require(block.timestamp>deadline && raisedAmount<target,"You aren't eligible for refund");
        require(contributors[msg.sender]>0,"You haven't done any donation");
        address payable payTo=payable(msg.sender);
        payTo.transfer(contributors[msg.sender]);
        
    }
    function createRequests(string memory _description,address payable _recipient,uint _value) public onlyOwner{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noofVoters=0;
    }
    function voteRequest(uint _requestNo)public{
        require(contributors[msg.sender]>0,"You must be a contributor first!");
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noofVoters++;
    }
    function makePayment(uint _requestNo)public onlyOwner{
        require(raisedAmount>target,"Target didnt fulfilled");
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.completed==false,"Request already processed");
        require(thisRequest.noofVoters>noOfContributors/2,"This request doesn't have majority votes");
        address payable payTo=payable(thisRequest.recipient);
        payTo.transfer(thisRequest.value);
        thisRequest.completed=true;

    }

}
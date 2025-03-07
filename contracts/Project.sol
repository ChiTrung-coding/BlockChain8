//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";


contract Project{

    enum State {
        Fundraising,
        Expired,
        Successful
    }


    struct WithdrawRequest{
        string description;
        uint256 amount;
        uint256 noOfVotes;
        mapping(address => bool) voters;
        bool isCompleted;
        address payable reciptent;
    }

    address payable public creator;
    uint256 public minimumContribution;
    uint256 public deadline;
    uint256 public targetContribution;
    uint public completeAt;
    uint256 public raisedAmount; 
    uint256 public noOfContributers;
    string public projectTitle;
    string public projectDes;
    State public state = State.Fundraising; 

//lưu trong storage
    mapping (address => uint) public contributiors;
    mapping (uint256 => WithdrawRequest) public withdrawRequests;

    uint256 public numOfWithdrawRequests = 0;

  
    modifier isCreator(){
        require(msg.sender == creator,'Khong co quyen thuc hien thao tac nay !');
        _;
    }

    modifier validateExpiry(State _state){
        require(state == _state,'Khong hop le');
        require(block.timestamp < deadline,'Qua han dong gop !');
        _;
    }

    // Events
    event FundingReceived(address contributor, uint amount, uint currentTotal);
    event WithdrawRequestCreated(
        uint256 requestId,
        string description,
        uint256 amount,
        uint256 noOfVotes,
        bool isCompleted,
        address reciptent
    );
    event WithdrawVote(address voter, uint totalVote);
    event AmountWithdrawSuccessful(
        uint256 requestId,
        string description,
        uint256 amount,
        uint256 noOfVotes,
        bool isCompleted,
        address reciptent
    );


   constructor(
       address _creator,
       uint256 _minimumContribution,
       uint256 _deadline,
       uint256 _targetContribution,
       string memory _projectTitle,
       string memory _projectDes
   ) {
       creator = payable(_creator);
       minimumContribution = _minimumContribution;
       deadline = _deadline;
       targetContribution = _targetContribution;
       projectTitle = _projectTitle;
       projectDes = _projectDes;
       raisedAmount = 0;
   }

//muon dong gop
    function contribute(address _contributor) public validateExpiry(State.Fundraising) payable {
        require(msg.value >= minimumContribution,'So tien dong gop qua thap !');
        if(contributiors[_contributor] == 0){
            noOfContributers++;
        }
        contributiors[_contributor] += msg.value;
        raisedAmount += msg.value;
        emit FundingReceived(_contributor,msg.value,raisedAmount);
        checkFundingCompleteOrExpire();
    }
//kiem tra quy du muc tieu chua
    function checkFundingCompleteOrExpire() internal {
        if(raisedAmount >= targetContribution){
            state = State.Successful; 
        }else if(block.timestamp > deadline){
            state = State.Expired; 
        }
        completeAt = block.timestamp;
    }

    function getContractBalance() public view returns(uint256){
        return address(this).balance;
    }
//hoàn tiền nếu k đủ
    function requestRefund() public validateExpiry(State.Expired) returns(bool) {
        require(contributiors[msg.sender] > 0,'Ban khong co so tien dong gop nao !');
        address payable user = payable(msg.sender);
        user.transfer(contributiors[msg.sender]);
        contributiors[msg.sender] = 0;
        return true;
    }
   
   // các trường lưu kiểu memory
    function createWithdrawRequest(string memory _description,uint256 _amount,address payable _reciptent) public isCreator() validateExpiry(State.Successful) {
        WithdrawRequest storage newRequest = withdrawRequests[numOfWithdrawRequests];
        numOfWithdrawRequests++;

        newRequest.description = _description;
        newRequest.amount = _amount;
        newRequest.noOfVotes = 0;
        newRequest.isCompleted = false;
        newRequest.reciptent = _reciptent;

        emit WithdrawRequestCreated(numOfWithdrawRequests,_description, _amount,0,false,_reciptent );
    }

//vote
    function voteWithdrawRequest(uint256 _requestId) public {
        require(contributiors[msg.sender] > 0,'chi co nguoi dong gop moi duoc bo phieu !');
        WithdrawRequest storage requestDetails = withdrawRequests[_requestId];
        require(requestDetails.voters[msg.sender] == false,'ban da bo phieu !');
        requestDetails.voters[msg.sender] = true;
        requestDetails.noOfVotes += 1;
        emit WithdrawVote(msg.sender,requestDetails.noOfVotes);
    }
//rut tien
    function withdrawRequestedAmount(uint256 _requestId) isCreator() validateExpiry(State.Successful) public{
        WithdrawRequest storage requestDetails = withdrawRequests[_requestId];
        require(requestDetails.isCompleted == false,'yeu cau hoan tat');
        require(requestDetails.noOfVotes > noOfContributers/2,'hon 50% so nguoi dong gop can bo phieu cho yeu cau nay');
        requestDetails.reciptent.transfer(requestDetails.amount);
        requestDetails.isCompleted = true;

        emit AmountWithdrawSuccessful(
            _requestId,
            requestDetails.description,
            requestDetails.amount,
            requestDetails.noOfVotes,
            true,
            requestDetails.reciptent
        );

    }

//lay thong tin du an
    function getProjectDetails() public view returns(
    address payable projectStarter,
    uint256 minContribution,
    uint256  projectDeadline,
    uint256 goalAmount, 
    uint completedTime,
    uint256 currentAmount, 
    string memory title,
    string memory desc,
    State currentState,
    uint256 balance
    ){
        projectStarter=creator;
        minContribution=minimumContribution;
        projectDeadline=deadline;
        goalAmount=targetContribution;
        completedTime=completeAt;
        currentAmount=raisedAmount;
        title=projectTitle;
        desc=projectDes;
        currentState=state;
        balance=address(this).balance;
    }

}
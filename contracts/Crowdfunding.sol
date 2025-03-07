//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import './Project.sol';

contract Crowdfunding{

event ProjectStarted(
    address projectContractAddress ,
    address creator,
    uint256 minContribution,
    uint256 projectDeadline,
    uint256 goalAmount,
    uint256 currentAmount,
    uint256 noOfContributors,
    string title,
    string desc,
    uint256 currentState
);

event ContributionReceived(
   address projectAddress,
   uint256 contributedAmount,
   address indexed contributor
);

 Project[] private projects;


//tao project
 function createProject(
    uint256 minimumContribution,
    uint256 deadline,
    uint256 targetContribution,
    string memory projectTitle,
    string memory projectDesc
 ) public {

   deadline = deadline;

   Project newProject = new Project(msg.sender,minimumContribution,deadline,targetContribution,projectTitle,projectDesc);
   projects.push(newProject);
 
 emit ProjectStarted(
    address(newProject) ,
    msg.sender,
    minimumContribution,
    deadline,
    targetContribution,
    0,
    0,
    projectTitle,
    projectDesc,
    0
 );

 }

// lay danh sach du an
function returnAllProjects() external view returns(Project[] memory){
   return projects;
}

// dong gop vao du an
function contribute(address _projectAddress) public payable{

   uint256 minContributionAmount = Project(_projectAddress).minimumContribution();
   Project.State projectState = Project(_projectAddress).state();
   require(projectState == Project.State.Fundraising,'Khong hop le');
   require(msg.value >= minContributionAmount,'So tien dong gop qua tap !');
   // Call function
   Project(_projectAddress).contribute{value:msg.value}(msg.sender);
   // Trigger event 
   emit ContributionReceived(_projectAddress,msg.value,msg.sender);
}

}


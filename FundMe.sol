//Get funds from users
//Withdraw funds
//Set a minimum funding value in USD

//SPDX-License-Identifier: MIT


pragma solidity  ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

contract FundMe{

    using PriceConverter for uint256;

    uint256 public minimumUssd = 2 * 1e18;

    //a list of funders
    address[] public funders;
    
    //a mapping of funders and the amount they sent
    mapping(address funder=> uint256 amountFunded) public addressToAmountFunded;

    address public owner;

    constructor(){
        //set the address of the owner of the contract
        owner = msg.sender;
    }

    function fund() public payable{

    
        require(msg.value.getConversionRate() >= minimumUssd, "didn't send enough ETH");
        //add funder to our funders array
        funders.push(msg.sender);
        
        //add amount sent by funder to array of previously sent funding
        addressToAmountFunded[msg.sender] += msg.value;

    }

    function withdraw() public onlyOwner{

        
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            //reset the amount funded in the mapping after withdrawing and set in to zero
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // reset the funder array by creating a new address array at the zero index
        funders = new address[](0);

        /*Three ways of withdrawing eth:
            1. Transfer 
                payable(msg.sender).transfer(address(this).balance);
            2. Send 
                bool sendSuccess = payable(msg.sender).send(address(this).balance);
                require(sendSuccess, "Send failed");
            3. Call 
                (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
                require(callSuccess, "call failed");
        */
        //Withdraw the eth
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "call failed");
    }

   modifier onlyOwner(){
        require(msg.sender == owner, "Sender is not owner");
        _;
   }
    
}
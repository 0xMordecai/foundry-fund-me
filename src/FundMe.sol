// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//program goals :

// Get fund from user
// withdraw funds
// set minimum fund value in USD

/*
            using interfaces => Interfaces allow different contracts to interact seamlessly by ensuring they share a common set of functionalities.
*/
//  non-constant => 880,858 ;constant => 860,497 ;constant & immutable
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import {PriceConverter, MathLib} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;
    address[] private s_funders;
    /*
        storage variables should start with `s_`.
    */
    mapping(address => uint256) private s_addressToAmountFunded;
    mapping(address => uint256) private s_addressToContribution;

    function fund() public payable {
        // Allow users to send $
        // Have a minimum $ sent $5
        // How do we send ETH to this contract ?
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "didn't send enough ETH"
        ); // 1e18 = 1 ETH = 1 * 10**18 wei
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_addressToContribution[msg.sender] += 1;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    //  Owner's Address
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    modifier onlyOwner() {
        //  Auth for withdraw
        // require(msg.sender == i_owner,FundMe__NotOwner());
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLenght = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLenght;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available");
        (bool callSuccess, ) = payable(msg.sender).call{value: balance}("");
        require(callSuccess, "Call failed");
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        //  reset the array
        s_funders = new address[](0);

        // actually withdraw the funds

        // transfer
        //  msg.sender  => type address
        //  payable(msg.sender) =>  type payable
        // payable(msg.sender).transfer(address(this).balance);

        // //  send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"Send failed");

        //  call => Recommaned
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available");
        (bool callSuccess, ) = payable(msg.sender).call{value: balance}("");
        require(callSuccess, "Call failed");
    }

    function contributionCount(address user) public view returns (uint256) {
        return s_addressToContribution[user];
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /** Getter Functions */

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}

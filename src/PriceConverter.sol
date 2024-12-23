// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // Address => 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI

        (
            ,
            /* uint80 roundID */ int answer /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,

        ) = priceFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    function getVersion(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // Address => "0x694AA1769357215DE4FAC081bf1f309aDC325306"
        return priceFeed.version(); // V4
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function getDecimals(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint8) {
        return priceFeed.decimals();
    }
}

library MathLib {
    function Sum(uint256 Pnum, uint256 Snum) internal pure returns (uint256) {
        return Pnum + Snum;
    }
}

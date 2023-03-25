// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface ITokenSupport {
     function addTokenDetails(string memory _tokenName,string memory _tokenSymbol, uint8 _tokenDecimal, address _tokenAggregatorAddress, address _tokenContractAddress) external;

    function deleteTokenDetails(string calldata _tokenSymbol) external;
}
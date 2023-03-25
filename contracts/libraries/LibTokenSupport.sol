// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import { Token, Market, AppStorage, LibAppStorage } from "./LibAppStorage.sol";

library LibTokenSupport {

     function addTokenDetails(string memory _tokenName,string memory _tokenSymbol, uint8 _tokenDecimal, address _tokenAggregatorAddress, address _tokenContractAddress) internal {
        AppStorage storage ds = LibAppStorage.getAppStorage();
        Token storage token = ds.tokenDetails[_tokenSymbol];
        if (token.aggregratorAddress != address(0)) revert("Token Aggregator already exist");
        token.name = _tokenName;
        token.symbol = _tokenSymbol;
        token.decimal = _tokenDecimal;
        token.aggregratorAddress = _tokenAggregatorAddress;
        token.contractAddress = _tokenContractAddress;
    }

    function deleteTokenDetails(string calldata _tokenSymbol) internal {
        AppStorage storage ds = LibAppStorage.getAppStorage();
        Token storage token = ds.tokenDetails[_tokenSymbol];
        if (token.aggregratorAddress == address(0)) revert("Token Aggregator does not exist");
        token.name = "";
        token.symbol = "";
        token.decimal = 0;
        token.aggregratorAddress = address(0);
        token.contractAddress = address(0);
    }

}
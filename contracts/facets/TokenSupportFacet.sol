// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";
import { LibTokenSupport } from "../libraries/LibTokenSupport.sol";



contract TokenSupportFacet {

     function addTokenDetails(string memory _tokenName,string memory _tokenSymbol, uint8 _tokenDecimal, address _tokenAggregatorAddress, address _tokenContractAddress) external {
        LibDiamond.enforceIsContractOwner();
        LibTokenSupport.addTokenDetails(_tokenName, _tokenSymbol, _tokenDecimal, _tokenAggregatorAddress, _tokenContractAddress);
    }

    function deleteTokenDetails(string calldata _tokenSymbol) external{
        LibDiamond.enforceIsContractOwner();
        LibTokenSupport.deleteTokenDetails(_tokenSymbol);
    }
}
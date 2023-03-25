// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
import { LibBuyWithToken } from "../libraries/LibBuyWithToken.sol";

contract BuyWithTokenFacet {
     function listAsset(address _assetAddress, uint256 _assetID, uint256 _price) external {
        LibBuyWithToken.listAsset(_assetAddress, _assetID, _price);
    }

    function listAsset(address _assetAddress, uint256 _assetID, uint256 _price, string calldata _symbol) external {
        LibBuyWithToken.listAsset(_assetAddress, _assetID, _price, _symbol);
    }

    function buyAssetWithToken(uint256 _itemMarketID, string memory _token) external {
        LibBuyWithToken.buyAssetWithToken(_itemMarketID, _token);
    }
}
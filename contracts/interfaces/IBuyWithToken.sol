// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IBuyWithToken {
     function listAsset(address _assetAddress, uint256 _assetID, uint256 _price) external;

    function listAsset(address _assetAddress, uint256 _assetID, uint256 _price, string calldata _symbol) external;

    function buyAssetWithToken(uint256 _itemMarketID, string memory _token) external;
}
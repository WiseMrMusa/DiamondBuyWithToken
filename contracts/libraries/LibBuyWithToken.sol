// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import { Token, Market, AppStorage, LibAppStorage } from "./LibAppStorage.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../interfaces/AggregatorV3Interface.sol";

library LibBuyWithToken {

     function listAsset(address _assetAddress, uint256 _assetID, uint256 _price) internal {
    AppStorage storage ds = LibAppStorage.getAppStorage();
        ds.itemID++;
        Market storage listNFT = ds.listedAsset[ds.itemID];
        listNFT.assetAddress = _assetAddress;
        listNFT.assetID = _assetID;
        listNFT.price = _price;
        listNFT.currency = "ETH";
        listNFT.seller = msg.sender;
        IERC721(_assetAddress).transferFrom(msg.sender, address(this),_assetID);
    }

    function listAsset(address _assetAddress, uint256 _assetID, uint256 _price, string calldata _symbol) internal {
    AppStorage storage ds = LibAppStorage.getAppStorage();
        ds.itemID++;
        Market storage listNFT = ds.listedAsset[ds.itemID];
        listNFT.assetAddress = _assetAddress;
        listNFT.assetID = _assetID;
        listNFT.price = _price;
        listNFT.currency = _symbol;
        listNFT.seller = msg.sender;
        IERC721(_assetAddress).transferFrom(msg.sender, address(this),_assetID);

    }

    function buyAssetWithToken(uint256 itemMarketID, string memory _token) internal {
        AppStorage storage ds = LibAppStorage.getAppStorage();
        Market memory item = ds.listedAsset[itemMarketID];

        ( address assetAddress, uint256 assetID, uint256 price, string memory currency , address seller ) = ( item.assetAddress, item.assetID, item.price, item.currency , item.seller);

        address contractAddress = ds.tokenDetails[_token].contractAddress;
        uint256 amount = uint256(getSwapTokenPrice(currency,_token,int256(price)));
        IERC20(contractAddress).transferFrom(msg.sender,seller,amount);
        IERC721(assetAddress).transferFrom(address(this),msg.sender,assetID);
    }

       function getDerivedPrice(
        string memory _from,
        string memory _to,
        uint8 _decimals
    ) internal view returns (int256) {
        AppStorage storage ds = LibAppStorage.getAppStorage();
        require(
            _decimals > uint8(0) && _decimals <= uint8(18),
            "Invalid _decimals"
        );
        int256 decimals = int256(10 ** uint256(_decimals));
        (, int256 fromPrice, , , ) = AggregatorV3Interface(ds.tokenDetails[_from].aggregratorAddress).latestRoundData();
        uint8 fromDecimals = AggregatorV3Interface(ds.tokenDetails[_from].aggregratorAddress).decimals();
        fromPrice = scalePrice(fromPrice , fromDecimals, _decimals);

        (, int256 toPrice, , , ) = AggregatorV3Interface(ds.tokenDetails[_to].aggregratorAddress)
            .latestRoundData();
        uint8 toDecimals = AggregatorV3Interface(ds.tokenDetails[_to].aggregratorAddress).decimals();
        toPrice = scalePrice(toPrice, toDecimals, _decimals);

        return (fromPrice * decimals) / toPrice;
    }

    function getDerivedPriceBase(
        string calldata _from,
        string calldata _to,
        uint8 _decimals
    ) internal view returns (int256) {
        AppStorage storage ds = LibAppStorage.getAppStorage();
        require(
            _decimals > uint8(0) && _decimals <= uint8(18),
            "Invalid _decimals"
        );
        int256 decimals = int256(10 ** uint256(_decimals));
        (, int256 fromPrice, , , ) = AggregatorV3Interface(ds.tokenDetails[_from].aggregratorAddress)
            .latestRoundData();
        uint8 fromDecimals = AggregatorV3Interface(ds.tokenDetails[_from].aggregratorAddress).decimals();
        fromPrice = scalePrice(fromPrice, fromDecimals, _decimals);

        (, int256 toPrice, , , ) = AggregatorV3Interface(ds.tokenDetails[_to].aggregratorAddress)
            .latestRoundData();
        uint8 toDecimals = AggregatorV3Interface(ds.tokenDetails[_to].aggregratorAddress).decimals();
        toPrice = scalePrice(toPrice, toDecimals, _decimals);

        return (fromPrice * decimals) / toPrice;
    }

     function factorPrice(
        int256 _price,
        uint8 _priceDecimals,
        uint8 _decimals
    ) internal pure returns (int256) {
        if (_priceDecimals < _decimals) {
            return _price * int256(10 ** uint256(_decimals - _priceDecimals));
        } else if (_priceDecimals > _decimals) {
            return _price / int256(10 ** uint256(_priceDecimals - _decimals));
        }
        return _price;
    }

    function scalePrice(
        int256 _price,
        uint8 _priceDecimals,
        uint8 _decimals
    ) internal pure returns (int256) {
        if (_priceDecimals < _decimals) {
            return _price * int256(10 ** uint256(_decimals - _priceDecimals));
        } else if (_priceDecimals > _decimals) {
            return _price / int256(10 ** uint256(_priceDecimals - _decimals));
        }
        return _price;
    }

        function getSwapTokenPrice(
        string memory _fromToken, 
        string memory _toToken,
        // uint8 _decimals,
        int256 _amount
    ) internal view returns (int256) {
        AppStorage storage ds = LibAppStorage.getAppStorage();
        return _amount * getDerivedPrice(
            _fromToken,
             _toToken,
            ds.tokenDetails[_toToken].decimal);
    }

}
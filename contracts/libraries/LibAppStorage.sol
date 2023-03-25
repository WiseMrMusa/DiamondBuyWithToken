// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

    struct Token {
    string name;
    string symbol;
    uint8 decimal;
    address aggregratorAddress;
    address contractAddress;
    }

    struct Market {
    address assetAddress;
    uint256 assetID;
    uint256 price;
    string currency;
    address seller;
    }

    struct AppStorage {
    /// @dev This maps the token address to the aggregator's address
    uint256 itemID;
    mapping (string => address) aggregrator;
    mapping (string => Token) tokenDetails;
    mapping (uint256 => Market) listedAsset;
    }
    library LibAppStorage {

        function getAppStorage() internal pure returns (AppStorage storage ds) {
            assembly {
                ds.slot := 0
            }
        }
    }
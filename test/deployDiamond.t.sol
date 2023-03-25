// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/interfaces/IBuyWithToken.sol";
import "../contracts/interfaces/ITokenSupport.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../../lib/forge-std/src/Test.sol";
import "../contracts/Diamond.sol";

import "../contracts/facets/BuyWithTokenFacet.sol";
import "../contracts/facets/TokenSupportFacet.sol";
import "../contracts/upgradeInitializers/DiamondInit.sol";

import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract DiamondDeployer is Test, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    BuyWithTokenFacet bToken;
    TokenSupportFacet tSupport;
    DiamondInit dInit;

    function setUp() public {
        uint256 mainnet = vm.createFork("https://eth-mainnet.g.alchemy.com/v2/Bpgb9sxlII8NJjFOZCcMlnqzsK5dKk0L", 16890919);
        vm.selectFork(mainnet);
    }


    function testDeployDiamond() public {
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        bToken = new BuyWithTokenFacet();
        tSupport = new TokenSupportFacet();
        dInit = new DiamondInit();

        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](4);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            FacetCut({
                facetAddress: address(bToken),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("BuyWithTokenFacet")
            })
        );
        cut[3] = (
            FacetCut({
                facetAddress: address(tSupport),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("TokenSupportFacet")
            })
        );

        //upgrade diamond
        // vm.prank(address(0x0));
        // dCutFacet.diamondCut([],address(dInit),"0xe1c7392a");
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");
        // IDiamondCut(address(diamond)).diamondCut( , address(dInit), "e1c7392a");
        //call a function
        // DiamondLoupeFacet(address(diamond)).facetAddresses();
    }
    function testAddTokenDetails() public {
        testDeployDiamond();
        ITokenSupport(address(diamond)).addTokenDetails(
            "Ethereum","ETH",18,
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419,
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
        );
        ITokenSupport(address(diamond)).addTokenDetails(
            "Tether USD","USDT",8,
            0x3E7d1eAB13ad0104d2750B8863b489D65364e32D,
            0xdAC17F958D2ee523a2206206994597C13D831ec7
        );
        ITokenSupport(address(diamond)).addTokenDetails(
            "Uniswap","UNI",8,
            0x553303d460EE0afB37EdFf9bE42922D8FF63220e,
            0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984
        );
    }

        function testListAsset() public {
        testAddTokenDetails();
        vm.startPrank(0xC8E04d79c9b84ccE230b7495B57b25F8c59A27be);
        IERC721(0x6B5d28442aF2444F66F8f2883Df30089E3fb840E).approve(address(diamond),31);
        IBuyWithToken(address(diamond)).listAsset(0x6B5d28442aF2444F66F8f2883Df30089E3fb840E,31,20);
        // assertEq(IERC721(0x6B5d28442aF2444F66F8f2883Df30089E3fb840E).ownerOf(31),address(diamond));
        vm.stopPrank();
    }

    function testBuyAssetWithToken() public {
        testListAsset();
        vm.deal(0x748dE14197922c4Ae258c7939C7739f3ff1db573,10000000 ether);
        vm.startPrank(0x748dE14197922c4Ae258c7939C7739f3ff1db573);
        IERC20(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984).approve(address(diamond), 100000000000000000000000000);
        IBuyWithToken(address(diamond)).buyAssetWithToken(1, "UNI");    
    }

    function generateSelectors(string memory _facetName)
        internal
        returns (bytes4[] memory selectors)
    {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}

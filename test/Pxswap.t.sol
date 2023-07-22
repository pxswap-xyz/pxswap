// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/Pxswap.sol";
import {DeployPxswap} from "script/DeployPxswap.s.sol";
import "./mock/mockNFT.sol";

contract PxswapTest is Test, DeployPxswap {
    address deployer;
    address alice;
    address bob;
    address carol;

    uint256 mainnetFork;

    mockNFT milady;
    mockNFT monke;
    mockNFT butt;
    mockNFT bird;
    mockNFT cat;

    function setUp() public {
        mainnetFork = vm.createSelectFork(vm.rpcUrl("mainnet"));

        deployer = makeAddr("Deployer");
        alice = makeAddr("Alice");
        bob = makeAddr("Bob");
        carol = makeAddr("Carol");

        vm.deal(deployer, 999 ether);
        vm.deal(alice, 999 ether);
        vm.deal(bob, 999 ether);
        vm.deal(carol, 999 ether);

        milady = new mockNFT("MockMilady", "MLADY");
        monke = new mockNFT("MockMonke", "MONKE");
        butt = new mockNFT("MockButt", "BUTT");
        bird = new mockNFT("MockBird", "BIRD");
        cat = new mockNFT("MockCat", "CAT");

        vm.startPrank(alice);
        milady.mintTo(alice);
        monke.mintTo(alice);
        butt.mintTo(alice);
        bird.mintTo(alice);
        cat.mintTo(alice);
        vm.stopPrank();

        vm.startPrank(bob);
        milady.mintTo(bob);
        monke.mintTo(bob);
        butt.mintTo(bob);
        bird.mintTo(bob);
        cat.mintTo(bob);
        vm.stopPrank();

        vm.startPrank(carol);
        milady.mintTo(carol);
        monke.mintTo(carol);
        butt.mintTo(carol);
        bird.mintTo(carol);
        cat.mintTo(carol);
        vm.stopPrank();

        DeployPxswap.run();
    }
}

///////////////////////////////////////////
//               openTrade
///////////////////////////////////////////

contract openTrade is PxswapTest {
    function testSuccess_OpenTrade_SingleNft_ZeroAmount() public {
        assertEq(milady.balanceOf(address(pxswap)), 0);
        assertEq(milady.balanceOf(alice), 1);

        address[] memory nfts = new address[](1);
        nfts[0] = address(milady);

        uint256[] memory nftIds = new uint256[](1);
        nftIds[0] = 1;

        vm.startPrank(alice);
        milady.approve(address(pxswap), 1);
        pxswap.openTrade(nfts, nftIds);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 1);
        assertEq(milady.balanceOf(alice), 0);
    }

    function testSuccess_OpenTrade_SingleNft_NonZeroAmount(uint256 ethAmount) public {
        vm.assume(ethAmount < 999 ether);
        vm.assume(ethAmount != 0);

        assertEq(milady.balanceOf(address(pxswap)), 0);
        assertEq(milady.balanceOf(alice), 1);

        address[] memory nfts = new address[](1);
        nfts[0] = address(milady);

        uint256[] memory nftIds = new uint256[](1);
        nftIds[0] = 1;

        vm.startPrank(alice);
        milady.approve(address(pxswap), 1);
        pxswap.openTrade(nfts, nftIds);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 1);
        assertEq(milady.balanceOf(alice), 0);
    }

    function testSuccess_OpenTrade_MultipleNfts_ZeroAmount() public {
        assertEq(milady.balanceOf(address(pxswap)), 0);
        assertEq(monke.balanceOf(address(pxswap)), 0);
        assertEq(butt.balanceOf(address(pxswap)), 0);
        assertEq(milady.balanceOf(alice), 1);
        assertEq(monke.balanceOf(alice), 1);
        assertEq(butt.balanceOf(alice), 1);

        address[] memory nfts = new address[](3);
        nfts[0] = address(milady);
        nfts[1] = address(monke);
        nfts[2] = address(butt);

        uint256[] memory nftIds = new uint256[](3);
        nftIds[0] = 1;
        nftIds[1] = 1;
        nftIds[2] = 1;

        vm.startPrank(alice);
        milady.approve(address(pxswap), 1);
        monke.approve(address(pxswap), 1);
        butt.approve(address(pxswap), 1);
        pxswap.openTrade(nfts, nftIds);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 1);
        assertEq(monke.balanceOf(address(pxswap)), 1);
        assertEq(butt.balanceOf(address(pxswap)), 1);
        assertEq(milady.balanceOf(alice), 0);
        assertEq(monke.balanceOf(alice), 0);
        assertEq(butt.balanceOf(alice), 0);
    }
}
///////////////////////////////////////////
//               cancelTrade
///////////////////////////////////////////

contract cancelTrade is PxswapTest {
    function testSuccess_CancelTrade_SingleNft_ZeroAmount() public {
        assertEq(milady.balanceOf(address(pxswap)), 0);
        assertEq(milady.balanceOf(alice), 1);

        address[] memory nfts = new address[](1);
        nfts[0] = address(milady);

        uint256[] memory nftIds = new uint256[](1);
        nftIds[0] = 1;

        vm.startPrank(alice);
        milady.approve(address(pxswap), 1);
        pxswap.openTrade(nfts, nftIds);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 1);
        assertEq(milady.balanceOf(alice), 0);

        uint256[] memory nftIds2 = new uint256[](1);
        nftIds2[0] = 2;

        vm.startPrank(bob);
        milady.approve(address(pxswap), 2);
        pxswap.offerTrade(0, nfts, nftIds2, 0);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 2);
        assertEq(milady.balanceOf(bob), 0);

        vm.startPrank(alice);
        pxswap.cancelTrade(0);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 0);
        assertEq(milady.balanceOf(alice), 1);
        assertEq(milady.balanceOf(bob), 1);
    }

    function testSuccess_CancelTrade_MultipleNfts_ZeroAmount() public {
        assertEq(milady.balanceOf(address(pxswap)), 0);
        assertEq(monke.balanceOf(address(pxswap)), 0);
        assertEq(butt.balanceOf(address(pxswap)), 0);
        assertEq(milady.balanceOf(alice), 1);
        assertEq(monke.balanceOf(alice), 1);
        assertEq(butt.balanceOf(alice), 1);

        address[] memory nfts = new address[](3);
        nfts[0] = address(milady);
        nfts[1] = address(monke);
        nfts[2] = address(butt);

        uint256[] memory nftIds = new uint256[](3);
        nftIds[0] = 1;
        nftIds[1] = 1;
        nftIds[2] = 1;

        vm.startPrank(alice);
        milady.approve(address(pxswap), 1);
        monke.approve(address(pxswap), 1);
        butt.approve(address(pxswap), 1);
        pxswap.openTrade(nfts, nftIds);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 1);
        assertEq(monke.balanceOf(address(pxswap)), 1);
        assertEq(butt.balanceOf(address(pxswap)), 1);
        assertEq(milady.balanceOf(alice), 0);
        assertEq(monke.balanceOf(alice), 0);
        assertEq(butt.balanceOf(alice), 0);

        address[] memory nfts2 = new address[](3);
        nfts2[0] = address(milady);
        nfts2[1] = address(monke);
        nfts2[2] = address(butt);

        uint256[] memory nftIds2 = new uint256[](3);
        nftIds2[0] = 2;
        nftIds2[1] = 2;
        nftIds2[2] = 2;

        vm.startPrank(bob);
        milady.approve(address(pxswap), 2);
        monke.approve(address(pxswap), 2);
        butt.approve(address(pxswap), 2);
        pxswap.offerTrade(0, nfts2, nftIds2, 0);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 2);
        assertEq(monke.balanceOf(address(pxswap)), 2);
        assertEq(butt.balanceOf(address(pxswap)), 2);
        assertEq(milady.balanceOf(bob), 0);
        assertEq(monke.balanceOf(bob), 0);
        assertEq(butt.balanceOf(bob), 0);

        vm.startPrank(alice);
        pxswap.cancelTrade(0);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 0);
        assertEq(monke.balanceOf(address(pxswap)), 0);
        assertEq(butt.balanceOf(address(pxswap)), 0);
        assertEq(milady.balanceOf(alice), 1);
        assertEq(monke.balanceOf(alice), 1);
        assertEq(butt.balanceOf(alice), 1);
        assertEq(milady.balanceOf(bob), 1);
        assertEq(monke.balanceOf(bob), 1);
        assertEq(butt.balanceOf(bob), 1);
    }
}

///////////////////////////////////////////
//               offerTrade
///////////////////////////////////////////

contract offerTrade is PxswapTest {
    function testSuccess_OfferTrade_SingleNft_ZeroAmount() public {
        assertEq(milady.balanceOf(address(pxswap)), 0);
        assertEq(milady.balanceOf(alice), 1);

        address[] memory nfts = new address[](1);
        nfts[0] = address(milady);

        uint256[] memory nftIds = new uint256[](1);
        nftIds[0] = 1;

        vm.startPrank(alice);
        milady.approve(address(pxswap), 1);
        pxswap.openTrade(nfts, nftIds);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 1);
        assertEq(milady.balanceOf(alice), 0);

        uint256[] memory nftIds2 = new uint256[](1);
        nftIds2[0] = 2;

        vm.startPrank(bob);
        milady.approve(address(pxswap), 2);
        pxswap.offerTrade(0, nfts, nftIds2, 0);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 2);
        assertEq(milady.balanceOf(bob), 0);
    }
}

///////////////////////////////////////////
//              acceptOffer
///////////////////////////////////////////

contract acceptOffer is PxswapTest {
    function testSuccess_AcceptOffer_SingleNft_ZeroAmount() public {
        assertEq(milady.balanceOf(address(pxswap)), 0);
        assertEq(milady.balanceOf(alice), 1);

        address[] memory nfts = new address[](1);
        nfts[0] = address(milady);

        uint256[] memory nftIds = new uint256[](1);
        nftIds[0] = 1;

        vm.startPrank(alice);
        milady.approve(address(pxswap), 1);
        pxswap.openTrade(nfts, nftIds);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 1);
        assertEq(milady.balanceOf(alice), 0);

        uint256[] memory nftIds2 = new uint256[](1);
        nftIds2[0] = 2;

        vm.startPrank(bob);
        milady.approve(address(pxswap), 2);
        pxswap.offerTrade(0, nfts, nftIds2, 0);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 2);
        assertEq(milady.balanceOf(bob), 0);

        vm.startPrank(alice);
        pxswap.acceptOffer(0, 0);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 0);
        assertEq(milady.balanceOf(alice), 1);
        assertEq(milady.balanceOf(bob), 1);
    }
}

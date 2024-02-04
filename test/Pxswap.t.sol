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
    address zeroAddr;

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
        zeroAddr = address(0);

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
    function testSuccess_OpenTrade_SingleNft() public {
        assertEq(milady.balanceOf(address(pxswap)), 0);
        assertEq(milady.balanceOf(alice), 1);

        address[] memory nfts = new address[](1);
        nfts[0] = address(milady);

        uint256[] memory nftIds = new uint256[](1);
        nftIds[0] = 1;

        address[] memory reqNfts = new address[](1);
        reqNfts[0] = address(butt);

        vm.startPrank(alice);
        milady.approve(address(pxswap), 1);
        pxswap.openTrade(nfts, nftIds, reqNfts, zeroAddr);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 1);
        assertEq(milady.balanceOf(alice), 0);
    }

    function testSuccess_OpenTrade_MultipleNfts() public {
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

        address[] memory reqNfts = new address[](3);
        reqNfts[0] = address(milady);
        reqNfts[1] = address(monke);
        reqNfts[2] = address(butt);

        vm.startPrank(alice);
        milady.approve(address(pxswap), 1);
        monke.approve(address(pxswap), 1);
        butt.approve(address(pxswap), 1);
        pxswap.openTrade(nfts, nftIds, reqNfts, zeroAddr);
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
    function testSuccess_CancelTrade_SingleNft() public {
        assertEq(milady.balanceOf(address(pxswap)), 0);
        assertEq(milady.balanceOf(alice), 1);

        address[] memory nfts = new address[](1);
        nfts[0] = address(milady);

        uint256[] memory nftIds = new uint256[](1);
        nftIds[0] = 1;

        address[] memory reqNfts = new address[](1);
        reqNfts[0] = address(butt);

        vm.startPrank(alice);
        milady.approve(address(pxswap), 1);
        pxswap.openTrade(nfts, nftIds, reqNfts, zeroAddr);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 1);
        assertEq(milady.balanceOf(alice), 0);

        bytes32 tradeHash =
            keccak256(abi.encodePacked(alice, nfts, nftIds, reqNfts, zeroAddr));

        vm.startPrank(alice);
        pxswap.cancelTrade(tradeHash);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 0);
        assertEq(milady.balanceOf(alice), 1);
    }

    function testSuccess_CancelTrade_MultipleNfts() public {
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

        address[] memory reqNfts = new address[](3);
        reqNfts[0] = address(milady);
        reqNfts[1] = address(monke);
        reqNfts[2] = address(butt);

        vm.startPrank(alice);
        milady.approve(address(pxswap), 1);
        monke.approve(address(pxswap), 1);
        butt.approve(address(pxswap), 1);
        pxswap.openTrade(nfts, nftIds, reqNfts, zeroAddr);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 1);
        assertEq(monke.balanceOf(address(pxswap)), 1);
        assertEq(butt.balanceOf(address(pxswap)), 1);
        assertEq(milady.balanceOf(alice), 0);
        assertEq(monke.balanceOf(alice), 0);
        assertEq(butt.balanceOf(alice), 0);

        bytes32 tradeHash =
            keccak256(abi.encodePacked(alice, nfts, nftIds, reqNfts, zeroAddr));

        vm.startPrank(alice);
        pxswap.cancelTrade(tradeHash);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 0);
        assertEq(monke.balanceOf(address(pxswap)), 0);
        assertEq(butt.balanceOf(address(pxswap)), 0);
        assertEq(milady.balanceOf(alice), 1);
        assertEq(monke.balanceOf(alice), 1);
        assertEq(butt.balanceOf(alice), 1);
    }
}

///////////////////////////////////////////
//              acceptTrade
///////////////////////////////////////////

contract acceptTrade is PxswapTest {
    function testSuccess_AcceptTrade_SingleNft() public {
        assertEq(milady.balanceOf(address(pxswap)), 0);
        assertEq(milady.balanceOf(alice), 1);

        address[] memory nfts = new address[](1);
        nfts[0] = address(milady);

        uint256[] memory nftIds = new uint256[](1);
        nftIds[0] = 1;

        address[] memory reqNfts = new address[](1);
        reqNfts[0] = address(butt);

        vm.startPrank(alice);
        milady.approve(address(pxswap), 1);
        pxswap.openTrade(nfts, nftIds, reqNfts, zeroAddr);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 1);
        assertEq(milady.balanceOf(alice), 0);

        uint256[] memory ids = new uint256[](1);
        ids[0] = 2;

        bytes32 tradeHash =
            keccak256(abi.encodePacked(alice, nfts, nftIds, reqNfts, zeroAddr));

        vm.startPrank(bob);
        butt.approve(address(pxswap), 2);
        pxswap.acceptTrade(tradeHash, ids);
        vm.stopPrank();

        assertEq(milady.balanceOf(address(pxswap)), 0);
        assertEq(butt.balanceOf(alice), 2);
        assertEq(butt.balanceOf(bob), 0);
        assertEq(milady.balanceOf(alice), 0);
        assertEq(milady.balanceOf(bob), 2);
    }
}

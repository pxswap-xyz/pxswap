// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "lib/forge-std/src/Test.sol";
import {Deploy} from "script/Deploy.s.sol";
import "../src/Pxswap.sol";
import "./mock/mockERC721.sol";
import "./mock/mockERC20.sol";

contract PxswapTest is Test {
    Pxswap px;

    MockERC721 bayc;
    MockERC721 punk;
    MockERC721 butt;

    MockERC20 doge;
    MockERC20 elon;
    MockERC20 shiba;

    address creator = address(1);
    address seller1 = address(2);
    address seller2 = address(3);
    address seller3 = address(4);
    address buyer1 = address(5);
    address buyer2 = address(6);
    address buyer3 = address(7);
    address hacker = address(9);
    address protocol = address(32);

    function setUp() public {
        vm.startPrank(creator);

        // deploy pxswap
        px = new Pxswap();
        px.setProtocol(address(protocol));

        // deploy mock nfts
        bayc = new MockERC721("MockBayc", "BAYC");
        punk = new MockERC721("MockPunk", "PUNK");
        butt = new MockERC721("MockButt", "BUTT");

        //deploy mock tokens
        doge = new MockERC20("Doge coin", "DOGE");
        elon = new MockERC20("Elon coin", "ELON");
        shiba = new MockERC20("Shiba coin", "SHIBA");

        vm.stopPrank();

        //top up accounts with ether
        vm.deal(seller1, 999 ether);
        vm.deal(seller2, 999 ether);
        vm.deal(seller3, 999 ether);
        vm.deal(buyer1, 999 ether);
        vm.deal(buyer2, 999 ether);
        vm.deal(buyer3, 999 ether);
        vm.deal(hacker, 9999 ether);

        //top up accounts mock nfts
        vm.startPrank(seller1);
        bayc.mintTo(seller1);
        bayc.mintTo(seller1);
        bayc.mintTo(seller1);
        punk.mintTo(seller1);
        punk.mintTo(seller1);
        punk.mintTo(seller1);
        butt.mintTo(seller1);
        butt.mintTo(seller1);
        butt.mintTo(seller1);
        vm.stopPrank();

        vm.startPrank(seller2);
        bayc.mintTo(seller2);
        punk.mintTo(seller2);
        butt.mintTo(seller2);
        vm.stopPrank();

        vm.startPrank(seller3);
        bayc.mintTo(seller3);
        punk.mintTo(seller3);
        butt.mintTo(seller3);
        vm.stopPrank();

        //top up accounts mock tokens
        vm.startPrank(seller1);
        doge.mint(seller1);
        elon.mint(seller1);
        shiba.mint(seller1);
        vm.stopPrank();

        vm.startPrank(seller2);
        doge.mint(seller2);
        elon.mint(seller2);
        shiba.mint(seller2);
        vm.stopPrank();

        vm.startPrank(seller3);
        doge.mint(seller3);
        elon.mint(seller3);
        shiba.mint(seller3);
        vm.stopPrank();
    }

    /////////////////////////////////////////////
    //                 Swap
    /////////////////////////////////////////////

    /////////////////////////////////////////////
    //               putSwap
    /////////////////////////////////////////////

    // Multiple nfts given, multiple nfts wanted, Token and Eth wanted
    function testSuccess_putSwap_MultipleGiveWant(uint256 amount, uint256 ethAmount, address tokenWanted) public {
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(tokenWanted != address(0));
        vm.assume(amount != 0);
        vm.assume(ethAmount != 0);

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](3);
        nftsWanted[0] = address(bayc);
        nftsWanted[1] = address(punk);
        nftsWanted[2] = address(butt);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](3);
        idsWanted[0] = 5;
        idsWanted[1] = 5;
        idsWanted[2] = 5;

        address buyer = address(0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, buyer, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);
    }

    // Multiple nfts given, multiple nfts wanted without ids, Token and Eth wanted
    function testSuccess_putSwap_MultipleGiveWantNoId(uint256 amount, uint256 ethAmount, address tokenWanted) public {
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(tokenWanted != address(0));
        vm.assume(amount != 0);
        vm.assume(ethAmount != 0);

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](3);
        nftsWanted[0] = address(bayc);
        nftsWanted[1] = address(punk);
        nftsWanted[2] = address(butt);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        address buyer = address(0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, buyer, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);
    }

    // Multiple nfts given, Single nft wanted, Token and Eth wanted
    function testSuccess_putSwap_MultipleGiveSingleWant(uint256 amount, uint256 ethAmount, address tokenWanted)
        public
    {
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(tokenWanted != address(0));
        vm.assume(amount != 0);
        vm.assume(ethAmount != 0);

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](1);
        nftsWanted[0] = address(bayc);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](1);
        idsWanted[0] = 5;

        address buyer = address(0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, buyer, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);
    }

    // Single nft given, Single nft wanted, Token and Eth wanted
    function testSuccess_putSwap_SingleGiveWant(uint256 amount, uint256 ethAmount, address tokenWanted) public {
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(tokenWanted != address(0));
        vm.assume(amount != 0);
        vm.assume(ethAmount != 0);

        assertEq(bayc.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](1);
        nftsGiven[0] = address(bayc);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](1);
        idsGiven[0] = 1;
        //approve nfts
        bayc.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](1);
        nftsWanted[0] = address(bayc);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](1);
        idsWanted[0] = 5;

        address buyer = address(0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, buyer, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
    }

    // Single nft given, multiple nfts wanted, Token and Eth wanted
    function testSuccess_putSwap_SingleGiveMultipleWant(uint256 amount, uint256 ethAmount, address tokenWanted)
        public
    {
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(tokenWanted != address(0));
        vm.assume(amount != 0);
        vm.assume(ethAmount != 0);

        assertEq(bayc.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](1);
        nftsGiven[0] = address(bayc);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](1);
        idsGiven[0] = 1;

        //approve nfts
        bayc.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](3);
        nftsWanted[0] = address(bayc);
        nftsWanted[1] = address(punk);
        nftsWanted[2] = address(butt);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](3);
        idsWanted[0] = 5;
        idsWanted[1] = 5;
        idsWanted[2] = 5;

        address buyer = address(0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, buyer, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
    }

    // Single nft given, Token and Eth wanted
    function testSuccess_putSwap_SingleGiveTokenEthWant(uint256 amount, uint256 ethAmount, address tokenWanted)
        public
    {
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(tokenWanted != address(0));
        vm.assume(amount != 0);
        vm.assume(ethAmount != 0);

        assertEq(bayc.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](1);
        nftsGiven[0] = address(bayc);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](1);
        idsGiven[0] = 1;

        //approve nfts
        bayc.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        address buyer = address(0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, buyer, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
    }

    // Multiple nfts given, Token and Eth wanted
    function testSuccess_putSwap_MultipleGiveTokenEthWant(uint256 amount, uint256 ethAmount, address tokenWanted)
        public
    {
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(tokenWanted != address(0));
        vm.assume(amount != 0);
        vm.assume(ethAmount != 0);

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        address buyer = address(0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, buyer, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);
    }

    // Multiple nfts given, Token wanted
    function testSuccess_putSwap_MultipleGiveTokenWant(uint256 amount, address tokenWanted) public {
        vm.assume(amount < 99 ether);
        vm.assume(tokenWanted != address(0));
        vm.assume(amount != 0);

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        uint256 ethAmount = 0;

        address buyer = address(0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, buyer, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);
    }

    // Multiple nfts given, Eth wanted
    function testSuccess_putSwap_MultipleGiveEthWant(uint256 ethAmount) public {
        vm.assume(ethAmount < 999 ether);
        vm.assume(ethAmount != 0);

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        address tokenWanted = address(0);

        address buyer = address(0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, 0, buyer, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);
    }

    /////////////////////////////////////////////
    //               cancelSwap
    /////////////////////////////////////////////

    function testSuccess_cancelSwap(uint256 amount, uint256 ethAmount, address tokenWanted) public {
        // Initialize a swap
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(tokenWanted != address(0));
        vm.assume(amount != 0);
        vm.assume(ethAmount != 0);

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        assertEq(bayc.balanceOf(seller1), 3);
        assertEq(punk.balanceOf(seller1), 3);
        assertEq(butt.balanceOf(seller1), 3);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](3);
        nftsWanted[0] = address(bayc);
        nftsWanted[1] = address(punk);
        nftsWanted[2] = address(butt);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](3);
        idsWanted[0] = 5;
        idsWanted[1] = 5;
        idsWanted[2] = 5;

        address buyer = address(0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, buyer, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);

        assertEq(bayc.balanceOf(seller1), 2);
        assertEq(punk.balanceOf(seller1), 2);
        assertEq(butt.balanceOf(seller1), 2);

        vm.startPrank(seller1);
        px.cancelSwap(0);
        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        assertEq(bayc.balanceOf(seller1), 3);
        assertEq(punk.balanceOf(seller1), 3);
        assertEq(butt.balanceOf(seller1), 3);
    }

    function testSuccess_cancelSwap_EmptySwap() public {
        // Initialize an empty swap
        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](0);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](0);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        address tokenWanted = address(0);

        uint256 amount = 0;

        uint256 ethAmount = 0;

        address buyer = address(0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, buyer, ethAmount);

        vm.stopPrank();

        vm.startPrank(seller1);
        px.cancelSwap(0);
        vm.stopPrank();
    }

    function testRevert_cancelSwap_Unauthorized(
        uint256 amount,
        uint256 ethAmount,
        address tokenWanted,
        address unauthorizedAddress
    ) public {
        // Initialize an empty swap
        vm.assume(amount < 900 ether);
        vm.assume(ethAmount < 100 ether);
        vm.assume(tokenWanted != address(0));
        vm.assume(unauthorizedAddress != address(seller1));

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](0);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](0);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, address(0), ethAmount);

        vm.stopPrank();

        vm.startPrank(unauthorizedAddress);
        vm.expectRevert("Unauthorized call, cant cancel swap!");
        px.cancelSwap(0);
        vm.stopPrank();
    }

    function testRevert_cancelSwap_Deactive(uint256 amount, uint256 ethAmount, address tokenWanted) public {
        // Initialize an empty swap
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(tokenWanted != address(0));
        vm.assume(amount != 0);
        vm.assume(ethAmount != 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](0);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](0);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        address buyer = address(0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, buyer, ethAmount);
        px.cancelSwap(0);

        vm.stopPrank();

        vm.startPrank(seller1);
        vm.expectRevert("Swap is not active!");
        px.cancelSwap(0);
        vm.stopPrank();
    }

    /////////////////////////////////////////////
    //               acceptSwap
    /////////////////////////////////////////////

    // Multiple nfts given, multiple nfts wanted, Token and Eth wanted
    function testSuccess_acceptSwap_MultipleGiveWant(uint256 amount, uint256 ethAmount) public {
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(amount != 0);
        vm.assume(ethAmount != 0);

        // checks
        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        assertEq(bayc.balanceOf(seller1), 3);
        assertEq(punk.balanceOf(seller1), 3);
        assertEq(butt.balanceOf(seller1), 3);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](3);
        nftsWanted[0] = address(bayc);
        nftsWanted[1] = address(punk);
        nftsWanted[2] = address(butt);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](3);
        idsWanted[0] = 5;
        idsWanted[1] = 5;
        idsWanted[2] = 5;

        address buyer = address(0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, address(doge), amount, buyer, ethAmount);

        vm.stopPrank();

        // checks
        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);

        assertEq(bayc.balanceOf(seller1), 2);
        assertEq(punk.balanceOf(seller1), 2);
        assertEq(butt.balanceOf(seller1), 2);

        assertEq(bayc.balanceOf(seller3), 1);
        assertEq(punk.balanceOf(seller3), 1);
        assertEq(butt.balanceOf(seller3), 1);

        assertEq(doge.balanceOf(seller3), 100 ether);

        assertEq(address(seller3).balance, 999 ether);
        assertEq(address(seller1).balance, 999 ether);

        assertEq(address(protocol).balance, 0);

        vm.startPrank(seller3);

        //approve
        bayc.approve(address(px), 5);
        punk.approve(address(px), 5);
        butt.approve(address(px), 5);

        doge.approve(address(px), amount);
        /* doge.increaseAllowance(address(px), amount); */

        uint256[] memory tokenIds = new uint256[](0);

        px.acceptSwap{value: ethAmount}(0, tokenIds);

        vm.stopPrank();

        uint256 sellersPie = ethAmount - (ethAmount / px.fee());

        // checks
        assertEq(doge.balanceOf(seller3), 100 ether - amount);
        assertEq(doge.balanceOf(address(protocol)), amount / px.fee());

        assertEq(address(seller3).balance, 999 ether - ethAmount);
        assertEq(address(seller1).balance, 999 ether + sellersPie);
        assertEq(address(protocol).balance, ethAmount / px.fee());
        assertEq(address(px).balance, 0);

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        assertEq(bayc.balanceOf(seller1), 3);
        assertEq(punk.balanceOf(seller1), 3);
        assertEq(butt.balanceOf(seller1), 3);

        assertEq(bayc.balanceOf(seller3), 1);
        assertEq(punk.balanceOf(seller3), 1);
        assertEq(butt.balanceOf(seller3), 1);
    }

    // Multiple nfts given, multiple nfts wanted without ids, Token and Eth wanted
    function testSuccess_acceptSwap_MultipleGiveWantNoId(uint256 amount, uint256 ethAmount) public {
        vm.assume(amount < 100 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(amount != 0);
        vm.assume(ethAmount != 0);

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        assertEq(shiba.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](3);
        nftsWanted[0] = address(bayc);
        nftsWanted[1] = address(punk);
        nftsWanted[2] = address(butt);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        address tokenWanted = address(shiba);

        address buyer = address(0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, buyer, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);

        assertEq(shiba.balanceOf(address(seller1)), 100 ether);
        assertEq(shiba.balanceOf(address(protocol)), 0);
        assertEq(shiba.balanceOf(address(seller3)), 100 ether);
        assertEq(shiba.balanceOf(address(px)), 0);

        assertEq(address(seller1).balance, 999 ether);
        assertEq(address(protocol).balance, 0);
        assertEq(address(seller3).balance, 999 ether);
        assertEq(address(px).balance, 0);

        vm.startPrank(seller3);

        //approve
        bayc.approve(address(px), 5);
        punk.approve(address(px), 5);
        butt.approve(address(px), 5);

        shiba.approve(address(px), amount);

        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 5;
        tokenIds[1] = 5;
        tokenIds[2] = 5;

        px.acceptSwap{value: ethAmount}(0, tokenIds);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        assertEq(bayc.balanceOf(seller1), 3);
        assertEq(punk.balanceOf(seller1), 3);
        assertEq(butt.balanceOf(seller1), 3);

        assertEq(bayc.balanceOf(seller3), 1);
        assertEq(punk.balanceOf(seller3), 1);
        assertEq(butt.balanceOf(seller3), 1);

        // fee calculation
        uint256 protocolEthFee = ethAmount / px.fee();
        uint256 finalEthAmount = ethAmount - protocolEthFee;

        assertEq(address(seller1).balance, 999 ether + finalEthAmount);
        assertEq(address(protocol).balance, protocolEthFee);
        assertEq(address(seller3).balance, 999 ether - ethAmount);
        assertEq(address(px).balance, 0);

        // fee calculation
        uint256 protocolTokenFee = amount / px.fee();
        uint256 finalTokenAmount = amount - protocolTokenFee;

        assertEq(shiba.balanceOf(address(seller1)), 100 ether + finalTokenAmount);
        assertEq(shiba.balanceOf(address(protocol)), protocolTokenFee);
        assertEq(shiba.balanceOf(address(seller3)), 100 ether - amount);
        assertEq(shiba.balanceOf(address(px)), 0);
    }

    // Multiple nfts given, Single nft wanted, Token and Eth wanted
    function testSuccess_acceptSwap_MultipleGiveSingleWant(uint256 amount, uint256 ethAmount) public {
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(amount != 0);
        vm.assume(ethAmount != 0);

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](1);
        nftsWanted[0] = address(bayc);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](1);
        idsWanted[0] = 5;

        address tokenWanted = address(shiba);

        address buyer = address(0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, buyer, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);

        assertEq(shiba.balanceOf(address(seller1)), 100 ether);
        assertEq(shiba.balanceOf(address(protocol)), 0);
        assertEq(shiba.balanceOf(address(seller3)), 100 ether);
        assertEq(shiba.balanceOf(address(px)), 0);

        assertEq(address(seller1).balance, 999 ether);
        assertEq(address(protocol).balance, 0);
        assertEq(address(seller3).balance, 999 ether);
        assertEq(address(px).balance, 0);

        vm.startPrank(seller3);

        //approve
        bayc.approve(address(px), 5);

        shiba.approve(address(px), amount);

        uint256[] memory tokenIds = new uint256[](0);

        px.acceptSwap{value: ethAmount}(0, tokenIds);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        assertEq(bayc.balanceOf(seller1), 3);
        assertEq(punk.balanceOf(seller1), 2);
        assertEq(butt.balanceOf(seller1), 2);

        assertEq(bayc.balanceOf(seller3), 1);
        assertEq(punk.balanceOf(seller3), 2);
        assertEq(butt.balanceOf(seller3), 2);

        // fee calculation
        uint256 protocolEthFee = ethAmount / px.fee();
        uint256 finalEthAmount = ethAmount - protocolEthFee;

        assertEq(address(seller1).balance, 999 ether + finalEthAmount);
        assertEq(address(protocol).balance, protocolEthFee);
        assertEq(address(seller3).balance, 999 ether - ethAmount);
        assertEq(address(px).balance, 0);

        // fee calculation
        uint256 protocolTokenFee = amount / px.fee();
        uint256 finalTokenAmount = amount - protocolTokenFee;

        assertEq(shiba.balanceOf(address(seller1)), 100 ether + finalTokenAmount);
        assertEq(shiba.balanceOf(address(protocol)), protocolTokenFee);
        assertEq(shiba.balanceOf(address(seller3)), 100 ether - amount);
        assertEq(shiba.balanceOf(address(px)), 0);
    }

    // Single nft given, Single nft wanted, Token and Eth wanted
    function testSuccess_acceptSwap_SingleGiveWant(uint256 amount, uint256 ethAmount) public {
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(amount != 0);
        vm.assume(ethAmount != 0);

        assertEq(bayc.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](1);
        nftsGiven[0] = address(bayc);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](1);
        idsGiven[0] = 1;
        //approve nfts
        bayc.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](1);
        nftsWanted[0] = address(punk);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](1);
        idsWanted[0] = 5;

        address tokenWanted = address(doge);

        address buyer = address(0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, buyer, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 0);

        assertEq(doge.balanceOf(address(seller1)), 100 ether);
        assertEq(doge.balanceOf(address(protocol)), 0);
        assertEq(doge.balanceOf(address(seller3)), 100 ether);
        assertEq(doge.balanceOf(address(px)), 0);

        assertEq(address(seller1).balance, 999 ether);
        assertEq(address(protocol).balance, 0);
        assertEq(address(seller3).balance, 999 ether);
        assertEq(address(px).balance, 0);

        vm.startPrank(seller3);

        //approve
        punk.approve(address(px), 5);

        doge.approve(address(px), amount);

        uint256[] memory tokenIds = new uint256[](0);

        px.acceptSwap{value: ethAmount}(0, tokenIds);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        assertEq(bayc.balanceOf(seller1), 2);
        assertEq(punk.balanceOf(seller1), 4);
        assertEq(butt.balanceOf(seller1), 3);

        assertEq(bayc.balanceOf(seller3), 2);
        assertEq(punk.balanceOf(seller3), 0);
        assertEq(butt.balanceOf(seller3), 1);

        // fee calculation
        uint256 protocolEthFee = ethAmount / px.fee();
        uint256 finalEthAmount = ethAmount - protocolEthFee;

        assertEq(address(seller1).balance, 999 ether + finalEthAmount);
        assertEq(address(protocol).balance, protocolEthFee);
        assertEq(address(seller3).balance, 999 ether - ethAmount);
        assertEq(address(px).balance, 0);

        // fee calculation
        uint256 protocolTokenFee = amount / px.fee();
        uint256 finalTokenAmount = amount - protocolTokenFee;

        assertEq(doge.balanceOf(address(seller1)), 100 ether + finalTokenAmount);
        assertEq(doge.balanceOf(address(protocol)), protocolTokenFee);
        assertEq(doge.balanceOf(address(seller3)), 100 ether - amount);
        assertEq(doge.balanceOf(address(px)), 0);
    }

    // Single nft given, multiple nfts wanted, Token and Eth wanted
    function testSuccess_acceptSwap_SingleGiveMultipleWant(uint256 amount, uint256 ethAmount) public {
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(amount != 0);
        vm.assume(ethAmount != 0);

        assertEq(bayc.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](1);
        nftsGiven[0] = address(bayc);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](1);
        idsGiven[0] = 1;

        //approve nfts
        bayc.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](3);
        nftsWanted[0] = address(bayc);
        nftsWanted[1] = address(punk);
        nftsWanted[2] = address(butt);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](3);
        idsWanted[0] = 5;
        idsWanted[1] = 5;
        idsWanted[2] = 5;

        address tokenWanted = address(elon);

        address buyer = address(0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, buyer, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(elon.balanceOf(address(px)), 0);

        assertEq(elon.balanceOf(address(seller1)), 100 ether);
        assertEq(elon.balanceOf(address(protocol)), 0);
        assertEq(elon.balanceOf(address(seller3)), 100 ether);
        assertEq(elon.balanceOf(address(px)), 0);

        assertEq(address(seller1).balance, 999 ether);
        assertEq(address(protocol).balance, 0);
        assertEq(address(seller3).balance, 999 ether);
        assertEq(address(px).balance, 0);

        vm.startPrank(seller3);

        //approve
        bayc.approve(address(px), 5);
        punk.approve(address(px), 5);
        butt.approve(address(px), 5);

        elon.approve(address(px), amount);

        uint256[] memory tokenIds = new uint256[](0);

        px.acceptSwap{value: ethAmount}(0, tokenIds);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        assertEq(bayc.balanceOf(seller1), 3);
        assertEq(punk.balanceOf(seller1), 4);
        assertEq(butt.balanceOf(seller1), 4);

        assertEq(bayc.balanceOf(seller3), 1);
        assertEq(punk.balanceOf(seller3), 0);
        assertEq(butt.balanceOf(seller3), 0);

        // fee calculation
        uint256 protocolEthFee = ethAmount / px.fee();
        uint256 finalEthAmount = ethAmount - protocolEthFee;

        assertEq(address(seller1).balance, 999 ether + finalEthAmount);
        assertEq(address(protocol).balance, protocolEthFee);
        assertEq(address(seller3).balance, 999 ether - ethAmount);
        assertEq(address(px).balance, 0);

        // fee calculation
        uint256 protocolTokenFee = amount / px.fee();
        uint256 finalTokenAmount = amount - protocolTokenFee;

        assertEq(elon.balanceOf(address(seller1)), 100 ether + finalTokenAmount);
        assertEq(elon.balanceOf(address(protocol)), protocolTokenFee);
        assertEq(elon.balanceOf(address(seller3)), 100 ether - amount);
        assertEq(elon.balanceOf(address(px)), 0);
    }

    /*     // Single nft given, Token and Eth wanted
    function testSuccess_putSwap_SingleGiveTokenEthWant(uint256 amount, uint256 ethAmount, address tokenWanted) public {
        vm.assume(amount < 900 ether);
        vm.assume(ethAmount < 100 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](1);
        nftsGiven[0] = address(bayc);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](1);
        idsGiven[0] = 1;

        //approve nfts
        bayc.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);

    } */

    /*     // Multiple nfts given, Token and Eth wanted
    function testSuccess_putSwap_MultipleGiveTokenEthWant(uint256 amount, uint256 ethAmount, address tokenWanted) public {
        vm.assume(amount < 900 ether);
        vm.assume(ethAmount < 100 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);

    } */

    /*     // Multiple nfts given, Token wanted
    function testSuccess_putSwap_MultipleGiveTokenWant(uint256 amount, address tokenWanted) public {
        vm.assume(amount < 900 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        uint256 ethAmount = 0;

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);

    } */

    // Multiple nfts given, Eth wanted
    /*     function testSuccess_putSwap_MultipleGiveEthWant(uint256 ethAmount) public {
        vm.assume(ethAmount < 100 ether);

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        address tokenWanted = address(0);

        uint256 amount = 0;

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);

    } */

    /////////////////////////////////////////////
    //                  Limit
    /////////////////////////////////////////////

    /////////////////////////////////////////////
    //               openLimitBuy
    /////////////////////////////////////////////

    function testSuccess_openLimitBuy(address wantNft, uint256 wantId, uint256 price) public {
        vm.assume(wantNft != address(0));
        vm.assume(price > 100000000000000);
        vm.assume(price < 999 ether);

        assertEq(address(seller3).balance, 999 ether);
        assertEq(address(px).balance, 0);

        vm.startPrank(seller3);
        px.openLimitBuy{value: price}(wantNft, wantId);
        vm.stopPrank();

        assertEq(address(seller3).balance, 999 ether - price);
        assertEq(address(px).balance, price);
    }

    function testRevert_openLimitBuy_DustValue(address wantNft, uint256 wantId, uint256 price) public {
        vm.assume(wantNft != address(0));
        vm.assume(price < 100000000000000);

        assertEq(address(seller3).balance, 999 ether);
        assertEq(address(px).balance, 0);

        vm.startPrank(seller3);
        vm.expectRevert("Non-dust amount required!");
        px.openLimitBuy{value: price}(wantNft, wantId);
        vm.stopPrank();

        assertEq(address(seller3).balance, 999 ether);
        assertEq(address(px).balance, 0);
    }

    function testRevert_openLimitBuy_ZeroAddress(uint256 wantId, uint256 price) public {
        vm.assume(price > 100000000000000);
        vm.assume(price < 999 ether);

        address wantNft = address(0);

        assertEq(address(seller3).balance, 999 ether);
        assertEq(address(px).balance, 0);

        vm.startPrank(seller3);
        vm.expectRevert("Zero address not allowed!");
        px.openLimitBuy{value: price}(wantNft, wantId);
        vm.stopPrank();

        assertEq(address(seller3).balance, 999 ether);
        assertEq(address(px).balance, 0);
    }

    /////////////////////////////////////////////
    //              cancelBuyOrder
    /////////////////////////////////////////////

    function testSuccess_cancelBuyOrder(address wantNft, uint256 wantId, uint256 price) public {
        vm.assume(wantNft != address(0));
        vm.assume(price > 100000000000000);
        vm.assume(price < 999 ether);

        assertEq(address(seller3).balance, 999 ether);
        assertEq(address(px).balance, 0);

        vm.startPrank(seller3);
        px.openLimitBuy{value: price}(wantNft, wantId);
        vm.stopPrank();

        assertEq(address(seller3).balance, 999 ether - price);
        assertEq(address(px).balance, price);

        vm.startPrank(seller3);
        px.cancelBuyOrder(0);
        vm.stopPrank();

        assertEq(address(seller3).balance, 999 ether);
        assertEq(address(px).balance, 0);
    }

    function testRevert_cancelBuyOrder_NotActive(address wantNft, uint256 wantId, uint256 price) public {
        vm.assume(wantNft != address(0));
        vm.assume(price > 100000000000000);
        vm.assume(price < 999 ether);

        assertEq(address(seller3).balance, 999 ether);
        assertEq(address(px).balance, 0);

        vm.startPrank(seller3);
        px.openLimitBuy{value: price}(wantNft, wantId);
        vm.stopPrank();

        assertEq(address(seller3).balance, 999 ether - price);
        assertEq(address(px).balance, price);

        vm.startPrank(seller3);
        px.cancelBuyOrder(0);
        vm.stopPrank();

        assertEq(address(seller3).balance, 999 ether);
        assertEq(address(px).balance, 0);

        vm.startPrank(seller3);
        vm.expectRevert("Order is not active!");
        px.cancelBuyOrder(0);
        vm.stopPrank();
    }

    function testRevert_cancelBuyOrder_NotOwner(address wantNft, uint256 wantId, uint256 price, address nonOwner)
        public
    {
        vm.assume(wantNft != address(0));
        vm.assume(price > 100000000000000);
        vm.assume(price < 999 ether);
        vm.assume(nonOwner != seller3);

        assertEq(address(seller3).balance, 999 ether);
        assertEq(address(px).balance, 0);

        vm.startPrank(seller3);
        px.openLimitBuy{value: price}(wantNft, wantId);
        vm.stopPrank();

        assertEq(address(seller3).balance, 999 ether - price);
        assertEq(address(px).balance, price);

        vm.startPrank(nonOwner);
        vm.expectRevert("Only owner!");
        px.cancelBuyOrder(0);
        vm.stopPrank();

        assertEq(address(seller3).balance, 999 ether - price);
        assertEq(address(px).balance, price);
    }

    /////////////////////////////////////////////
    //              fillBuyOrder
    /////////////////////////////////////////////

    function testSuccess_fillBuyOrder(uint256 price) public {
        vm.assume(price > 100000000000000);
        vm.assume(price < 999 ether);

        assertEq(address(seller3).balance, 999 ether);
        assertEq(address(px).balance, 0);
        assertEq(punk.balanceOf(seller3), 1);
        assertEq(punk.balanceOf(seller1), 3);
        assertEq(punk.balanceOf(address(px)), 0);

        vm.startPrank(seller3);
        px.openLimitBuy{value: price}(address(punk), 1);
        vm.stopPrank();

        assertEq(address(seller3).balance, 999 ether - price);
        assertEq(address(seller1).balance, 999 ether);
        assertEq(address(px).balance, price);

        vm.startPrank(seller1);
        punk.approve(address(px), 1);
        px.fillBuyOrder(0, 1);
        vm.stopPrank();

        uint256 fee = price / px.fee();
        uint256 finalPrice = price - (price / px.fee());

        assertEq(punk.balanceOf(seller3), 2);
        assertEq(punk.balanceOf(seller1), 2);
        assertEq(address(px).balance, 0);
        assertEq(address(protocol).balance, fee);
        assertEq(address(seller1).balance, 999 ether + finalPrice);
    }

    /////////////////////////////////////////////
    //               openLimitSell
    /////////////////////////////////////////////

    function testSuccess_openLimitSell(uint256 price) public {
        vm.assume(price > 100000000000000);
        vm.assume(price < 999 ether);

        assertEq(punk.balanceOf(address(seller1)), 3);

        vm.startPrank(seller1);
        punk.approve(address(px), 1);

        address[] memory nfts = new address[](1);
        nfts[0] = address(punk);

        uint256[] memory ids = new uint256[](1);
        ids[0] = 1;

        px.openLimitSell(nfts, ids, price);
        vm.stopPrank();

        assertEq(punk.balanceOf(address(seller1)), 2);
    }

    function testRevert_openLimitSell_ZeroAddress(uint256 price) public {
        vm.assume(price > 100000000000000);
        vm.assume(price < 999 ether);

        assertEq(punk.balanceOf(address(seller1)), 3);

        address[] memory nfts = new address[](1);
        nfts[0] = address(0);

        uint256[] memory ids = new uint256[](1);
        ids[0] = 1;

        vm.startPrank(seller1);
        vm.expectRevert("Zero address not allowed!");

        px.openLimitSell(nfts, ids, price);
        vm.stopPrank();

        assertEq(punk.balanceOf(address(seller1)), 3);
    }

    /////////////////////////////////////////////
    //              cancelSellOrder
    /////////////////////////////////////////////

    function testSuccess_cancelSellOrder(uint256 price) public {
        vm.assume(price > 100000000000000);
        vm.assume(price < 999 ether);

        assertEq(punk.balanceOf(address(seller1)), 3);
        assertEq(punk.balanceOf(address(px)), 0);

        vm.startPrank(seller1);
        punk.approve(address(px), 1);
        
        address[] memory nfts = new address[](1);
        nfts[0] = address(punk);

        uint256[] memory ids = new uint256[](1);
        ids[0] = 1;

        px.openLimitSell(nfts, ids, price);
        vm.stopPrank();

        assertEq(punk.balanceOf(address(seller1)), 2);
        assertEq(punk.balanceOf(address(px)), 1);

        vm.startPrank(seller1);
        px.cancelSellOrder(0);
        vm.stopPrank();

        assertEq(punk.balanceOf(address(seller1)), 3);
        assertEq(punk.balanceOf(address(px)), 0);
    }

    function testRevert_cancelSellOrder_NonOwner(uint256 price, address nonOwner) public {
        vm.assume(nonOwner != seller1);
        vm.assume(price > 100000000000000);
        vm.assume(price < 999 ether);

        assertEq(punk.balanceOf(address(seller1)), 3);
        assertEq(punk.balanceOf(address(px)), 0);

        vm.startPrank(seller1);
        punk.approve(address(px), 1);

        address[] memory nfts = new address[](1);
        nfts[0] = address(punk);

        uint256[] memory ids = new uint256[](1);
        ids[0] = 1;
        
        px.openLimitSell(nfts, ids, price);
        vm.stopPrank();

        assertEq(punk.balanceOf(address(seller1)), 2);
        assertEq(punk.balanceOf(address(px)), 1);

        vm.startPrank(nonOwner);
        vm.expectRevert("Only owner!");
        px.cancelSellOrder(0);
        vm.stopPrank();

        assertEq(punk.balanceOf(address(seller1)), 2);
        assertEq(punk.balanceOf(address(px)), 1);
    }

    function testRevert_cancelSellOrder_NotActive(uint256 price) public {
        vm.assume(price > 100000000000000);
        vm.assume(price < 999 ether);

        assertEq(punk.balanceOf(address(seller1)), 3);
        assertEq(punk.balanceOf(address(px)), 0);

        vm.startPrank(seller1);
        punk.approve(address(px), 1);

        address[] memory nfts = new address[](1);
        nfts[0] = address(punk);

        uint256[] memory ids = new uint256[](1);
        ids[0] = 1;

        px.openLimitSell(nfts, ids, price);
        vm.stopPrank();

        assertEq(punk.balanceOf(address(seller1)), 2);
        assertEq(punk.balanceOf(address(px)), 1);

        vm.startPrank(seller1);
        px.cancelSellOrder(0);
        vm.stopPrank();

        assertEq(punk.balanceOf(address(seller1)), 3);
        assertEq(punk.balanceOf(address(px)), 0);

        vm.startPrank(seller1);
        vm.expectRevert("Order is not active!");
        px.cancelSellOrder(0);
        vm.stopPrank();

        assertEq(punk.balanceOf(address(seller1)), 3);
        assertEq(punk.balanceOf(address(px)), 0);
    }

    /////////////////////////////////////////////
    //              fillSellOrder
    /////////////////////////////////////////////

    function testSuccess_fillSellOrder(uint256 price) public {
        vm.assume(price > 100000000000000);
        vm.assume(price < 999 ether);

        assertEq(punk.balanceOf(address(seller1)), 3);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(address(protocol).balance, 0);
        assertEq(address(seller1).balance, 999 ether);
        assertEq(address(seller3).balance, 999 ether);

        vm.startPrank(seller1);
        punk.approve(address(px), 1);

        address[] memory nfts = new address[](1);
        nfts[0] = address(punk);

        uint256[] memory ids = new uint256[](1);
        ids[0] = 1;
        
        px.openLimitSell(nfts, ids, price);
        vm.stopPrank();

        assertEq(punk.balanceOf(address(seller1)), 2);
        assertEq(punk.balanceOf(address(seller3)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(address(protocol).balance, 0);
        assertEq(address(seller1).balance, 999 ether);
        assertEq(address(seller3).balance, 999 ether);

        vm.startPrank(seller3);
        px.fillSellOrder{value: price}(0);
        vm.stopPrank();

        uint256 fee = price / px.fee();
        uint256 finalAmount = price - fee;

        assertEq(punk.balanceOf(address(seller1)), 2);
        assertEq(punk.balanceOf(address(seller3)), 2);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(address(protocol).balance, fee);
        assertEq(address(seller1).balance, 999 ether + finalAmount);
        assertEq(address(seller3).balance, 999 ether - price);
    }

    /////////////////////////////////////////////
    //                  P2P
    /////////////////////////////////////////////

    /////////////////////////////////////////////
    //               offerP2P
    /////////////////////////////////////////////

    // Multiple nfts given, multiple nfts wanted, Token and Eth wanted
    function testSuccess_P2P_MultipleGiveWant(uint256 amount, uint256 ethAmount, address tokenWanted, address buyer)
        public
    {
        vm.assume(buyer != address(0));
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](3);
        nftsWanted[0] = address(bayc);
        nftsWanted[1] = address(punk);
        nftsWanted[2] = address(butt);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](3);
        idsWanted[0] = 5;
        idsWanted[1] = 5;
        idsWanted[2] = 5;

/*         px.offerP2P(buyer, nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount); */

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);
    }

    // Multiple nfts given, multiple nfts wanted without ids, Token and Eth wanted
    function testSuccess_P2P_MultipleGiveWantNoId(address buyer, uint256 amount, uint256 ethAmount, address tokenWanted)
        public
    {
        vm.assume(buyer != address(0));
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](3);
        nftsWanted[0] = address(bayc);
        nftsWanted[1] = address(punk);
        nftsWanted[2] = address(butt);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

/*         px.offerP2P(buyer, nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount); */

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);
    }

    // Multiple nfts given, Single nft wanted, Token and Eth wanted
    function testSuccess_P2P_MultipleGiveSingleWant(
        address buyer,
        uint256 amount,
        uint256 ethAmount,
        address tokenWanted
    ) public {
        vm.assume(buyer != address(0));
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](1);
        nftsWanted[0] = address(bayc);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](1);
        idsWanted[0] = 5;

/*         px.offerP2P(buyer, nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount); */

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);
    }

    // Single nft given, Single nft wanted, Token and Eth wanted
    function testSuccess_P2P_SingleGiveWant(address buyer, uint256 amount, uint256 ethAmount, address tokenWanted)
        public
    {
        vm.assume(buyer != address(0));
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](1);
        nftsGiven[0] = address(bayc);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](1);
        idsGiven[0] = 1;
        //approve nfts
        bayc.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](1);
        nftsWanted[0] = address(bayc);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](1);
        idsWanted[0] = 5;

/*         px.offerP2P(buyer, nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount); */

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
    }

    // Single nft given, multiple nfts wanted, Token and Eth wanted
    function testSuccess_P2P_SingleGiveMultipleWant(
        address buyer,
        uint256 amount,
        uint256 ethAmount,
        address tokenWanted
    ) public {
        vm.assume(buyer != address(0));
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](1);
        nftsGiven[0] = address(bayc);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](1);
        idsGiven[0] = 1;

        //approve nfts
        bayc.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](3);
        nftsWanted[0] = address(bayc);
        nftsWanted[1] = address(punk);
        nftsWanted[2] = address(butt);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](3);
        idsWanted[0] = 5;
        idsWanted[1] = 5;
        idsWanted[2] = 5;

/*         px.offerP2P(buyer, nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount); */

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
    }

    // Single nft given, Token and Eth wanted
    function testSuccess_P2P_SingleGiveTokenEthWant(
        address buyer,
        uint256 amount,
        uint256 ethAmount,
        address tokenWanted
    ) public {
        vm.assume(buyer != address(0));
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](1);
        nftsGiven[0] = address(bayc);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](1);
        idsGiven[0] = 1;

        //approve nfts
        bayc.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

/*         px.offerP2P(buyer, nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount); */

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
    }

    // Multiple nfts given, Token and Eth wanted
    function testSuccess_P2P_MultipleGiveTokenEthWant(
        address buyer,
        uint256 amount,
        uint256 ethAmount,
        address tokenWanted
    ) public {
        vm.assume(buyer != address(0));
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

/*         px.offerP2P(buyer, nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount); */

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);
    }

    // Multiple nfts given, Token wanted
    function testSuccess_P2P_MultipleGiveTokenWant(address buyer, uint256 amount, address tokenWanted) public {
        vm.assume(buyer != address(0));
        vm.assume(amount < 99 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        uint256 ethAmount = 0;

/*         px.offerP2P(buyer, nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount); */

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);
    }

    // Multiple nfts given, Eth wanted
    function testSuccess_P2P_MultipleGiveEthWant(address buyer, uint256 ethAmount) public {
        vm.assume(buyer != address(0));
        vm.assume(ethAmount < 999 ether);
        vm.assume(ethAmount != 0);

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        address tokenWanted = address(0);

        uint256 amount = 0;

/*         px.offerP2P(buyer, nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount); */

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);
    }

    /////////////////////////////////////////////
    //               cancelP2P
    /////////////////////////////////////////////

    function testSuccess_cancelP2P(address buyer, uint256 amount, uint256 ethAmount, address tokenWanted) public {
        // Initialize a swap
        vm.assume(amount < 900 ether);
        vm.assume(buyer != address(0));
        vm.assume(ethAmount < 100 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        assertEq(bayc.balanceOf(seller1), 3);
        assertEq(punk.balanceOf(seller1), 3);
        assertEq(butt.balanceOf(seller1), 3);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](3);
        nftsWanted[0] = address(bayc);
        nftsWanted[1] = address(punk);
        nftsWanted[2] = address(butt);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](3);
        idsWanted[0] = 5;
        idsWanted[1] = 5;
        idsWanted[2] = 5;

/*         px.offerP2P(buyer, nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount); */

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);

        assertEq(bayc.balanceOf(seller1), 2);
        assertEq(punk.balanceOf(seller1), 2);
        assertEq(butt.balanceOf(seller1), 2);

/*         vm.startPrank(seller1);
        px.cancelP2P(0);
        vm.stopPrank(); */

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        assertEq(bayc.balanceOf(seller1), 3);
        assertEq(punk.balanceOf(seller1), 3);
        assertEq(butt.balanceOf(seller1), 3);
    }

    function testSuccess_cancelP2P_EmptySwap() public {
        // Initialize an empty swap
        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](0);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](0);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        uint256 amount = 0;

        uint256 ethAmount = 0;

        address tokenWanted = address(0);

/*         px.offerP2P(address(seller3), nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount); */

        vm.stopPrank();

/*         vm.startPrank(seller1);
        px.cancelP2P(0);
        vm.stopPrank(); */
    }

    function testRevert_cancelP2P_Unauthorized(
        address buyer,
        uint256 amount,
        uint256 ethAmount,
        address tokenWanted,
        address unauthorizedAddress
    ) public {
        // Initialize an empty swap
        vm.assume(buyer != address(0));
        vm.assume(tokenWanted != address(0));
        vm.assume(unauthorizedAddress != address(seller1));

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](0);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](0);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

/*         px.offerP2P(buyer, nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount); */

        vm.stopPrank();

/*         vm.startPrank(unauthorizedAddress);
        vm.expectRevert("Unauthorized call, cant cancel swap!");
        px.cancelP2P(0);
        vm.stopPrank(); */
    }

    function testRevert_cancelP2P_Deactive(address buyer, uint256 amount, uint256 ethAmount, address tokenWanted)
        public
    {
        // Initialize an empty swap
        vm.assume(buyer != address(0));

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](0);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](0);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, buyer, ethAmount);
        px.cancelSwap(0);

        vm.stopPrank();

        vm.startPrank(seller1);
        vm.expectRevert("Swap is not active!");
        px.cancelSwap(0);
        vm.stopPrank();
    }

    /////////////////////////////////////////////
    //               acceptP2P
    /////////////////////////////////////////////

    // Multiple nfts given, multiple nfts wanted, Token and Eth wanted
    function testSuccess_acceptP2P_MultipleGiveWant(uint256 amount, uint256 ethAmount) public {
        vm.assume(amount < 99 ether);
        vm.assume(ethAmount < 999 ether);
        vm.assume(amount != 0);
        vm.assume(ethAmount != 0);

        // checks
        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        assertEq(bayc.balanceOf(seller1), 3);
        assertEq(punk.balanceOf(seller1), 3);
        assertEq(butt.balanceOf(seller1), 3);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](3);
        nftsWanted[0] = address(bayc);
        nftsWanted[1] = address(punk);
        nftsWanted[2] = address(butt);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](3);
        idsWanted[0] = 5;
        idsWanted[1] = 5;
        idsWanted[2] = 5;

/*         px.offerP2P(address(seller3), nftsGiven, idsGiven, nftsWanted, idsWanted, address(doge), amount, ethAmount); */

        vm.stopPrank();

        // checks
        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);

        assertEq(bayc.balanceOf(seller1), 2);
        assertEq(punk.balanceOf(seller1), 2);
        assertEq(butt.balanceOf(seller1), 2);

        vm.startPrank(seller3);

        assertEq(bayc.balanceOf(seller3), 1);
        assertEq(punk.balanceOf(seller3), 1);
        assertEq(butt.balanceOf(seller3), 1);

        assertEq(doge.balanceOf(seller3), 100 ether);

        assertEq(address(seller3).balance, 999 ether);
        assertEq(address(seller1).balance, 999 ether);

        assertEq(address(protocol).balance, 0);

        //approve
        bayc.approve(address(px), 5);
        punk.approve(address(px), 5);
        butt.approve(address(px), 5);

        /* doge.approve(address(px), amount); */
        doge.increaseAllowance(address(px), amount);

        uint256[] memory tokenIds = new uint256[](0);

/*         px.acceptP2P{value: ethAmount}(0); */

        vm.stopPrank();

        uint256 sellersPie = ethAmount - (ethAmount / px.fee());

        // checks
        assertEq(doge.balanceOf(seller3), 100 ether - amount);
        assertEq(doge.balanceOf(address(protocol)), amount / px.fee());

        assertEq(address(seller3).balance, 999 ether - ethAmount);
        assertEq(address(seller1).balance, 999 ether + sellersPie);
        assertEq(address(protocol).balance, ethAmount / px.fee());
        assertEq(address(px).balance, 0);

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        assertEq(bayc.balanceOf(seller1), 3);
        assertEq(punk.balanceOf(seller1), 3);
        assertEq(butt.balanceOf(seller1), 3);

        assertEq(bayc.balanceOf(seller3), 1);
        assertEq(punk.balanceOf(seller3), 1);
        assertEq(butt.balanceOf(seller3), 1);
    }

    /*     // Multiple nfts given, multiple nfts wanted without ids, Token and Eth wanted
    function testSuccess_acceptSwap_MultipleGiveWantNoId(uint256 amount, uint256 ethAmount, address tokenWanted) public {
        vm.assume(amount < 900 ether);
        vm.assume(ethAmount < 100 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](3);
        nftsWanted[0] = address(bayc);
        nftsWanted[1] = address(punk);
        nftsWanted[2] = address(butt);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);

    } */

    /* 
    // Multiple nfts given, Single nft wanted, Token and Eth wanted
    function testSuccess_putSwap_MultipleGiveSingleWant(uint256 amount, uint256 ethAmount, address tokenWanted) public {
        vm.assume(amount < 900 ether);
        vm.assume(ethAmount < 100 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](1);
        nftsWanted[0] = address(bayc);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](1);
        idsWanted[0] = 5;

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);

    } */

    /*     // Single nft given, Single nft wanted, Token and Eth wanted
    function testSuccess_putSwap_SingleGiveWant(uint256 amount, uint256 ethAmount, address tokenWanted) public {
        vm.assume(amount < 900 ether);
        vm.assume(ethAmount < 100 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](1);
        nftsGiven[0] = address(bayc);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](1);
        idsGiven[0] = 1;
        //approve nfts
        bayc.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](1);
        nftsWanted[0] = address(bayc);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](1);
        idsWanted[0] = 5;

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);

    } */

    /*     // Single nft given, multiple nfts wanted, Token and Eth wanted
    function testSuccess_putSwap_SingleGiveMultipleWant(uint256 amount, uint256 ethAmount, address tokenWanted) public {
        vm.assume(amount < 900 ether);
        vm.assume(ethAmount < 100 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](1);
        nftsGiven[0] = address(bayc);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](1);
        idsGiven[0] = 1;

        //approve nfts
        bayc.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](3);
        nftsWanted[0] = address(bayc);
        nftsWanted[1] = address(punk);
        nftsWanted[2] = address(butt);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](3);
        idsWanted[0] = 5;
        idsWanted[1] = 5;
        idsWanted[2] = 5;

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);

    } */

    /*     // Single nft given, Token and Eth wanted
    function testSuccess_putSwap_SingleGiveTokenEthWant(uint256 amount, uint256 ethAmount, address tokenWanted) public {
        vm.assume(amount < 900 ether);
        vm.assume(ethAmount < 100 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](1);
        nftsGiven[0] = address(bayc);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](1);
        idsGiven[0] = 1;

        //approve nfts
        bayc.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);

    } */

    /*     // Multiple nfts given, Token and Eth wanted
    function testSuccess_putSwap_MultipleGiveTokenEthWant(uint256 amount, uint256 ethAmount, address tokenWanted) public {
        vm.assume(amount < 900 ether);
        vm.assume(ethAmount < 100 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);

    } */

    /*     // Multiple nfts given, Token wanted
    function testSuccess_putSwap_MultipleGiveTokenWant(uint256 amount, address tokenWanted) public {
        vm.assume(amount < 900 ether);
        vm.assume(tokenWanted != address(0));

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        uint256 ethAmount = 0;

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);

    } */

    // Multiple nfts given, Eth wanted
    /*     function testSuccess_putSwap_MultipleGiveEthWant(uint256 ethAmount) public {
        vm.assume(ethAmount < 100 ether);

        assertEq(bayc.balanceOf(address(px)), 0);
        assertEq(punk.balanceOf(address(px)), 0);
        assertEq(butt.balanceOf(address(px)), 0);

        vm.startPrank(seller1);

        // set given nfts array
        address[] memory nftsGiven = new address[](3);
        nftsGiven[0] = address(bayc);
        nftsGiven[1] = address(punk);
        nftsGiven[2] = address(butt);
        // set given ids array
        uint256[] memory idsGiven = new uint256[](3);
        idsGiven[0] = 1;
        idsGiven[1] = 1;
        idsGiven[2] = 1;

        //approve nfts
        bayc.approve(address(px), 1);
        punk.approve(address(px), 1);
        butt.approve(address(px), 1);

        // set wanted nfts array
        address[] memory nftsWanted = new address[](0);
        // set wanted ids array
        uint256[] memory idsWanted = new uint256[](0);

        address tokenWanted = address(0);

        uint256 amount = 0;

        px.putSwap(nftsGiven, idsGiven, nftsWanted, idsWanted, tokenWanted, amount, ethAmount);

        vm.stopPrank();

        assertEq(bayc.balanceOf(address(px)), 1);
        assertEq(punk.balanceOf(address(px)), 1);
        assertEq(butt.balanceOf(address(px)), 1);

    } */

    /////////////////////////////////////////////
    //                 Admin
    /////////////////////////////////////////////

    /////////////////////////////////////////////
    //               setProtocol
    /////////////////////////////////////////////

    function testSuccess_setProtocol() public {
        assertEq(px.protocol(), address(protocol));

        vm.startPrank(creator);
        px.setProtocol(address(999));
        vm.stopPrank();

        assertEq(px.protocol(), address(999));
    }

    function testRevert_setProtocol_NonOwner() public {
        assertEq(px.protocol(), address(protocol));

        vm.startPrank(hacker);
        vm.expectRevert("Ownable: caller is not the owner");
        px.setProtocol(hacker);
        vm.stopPrank();
    }

    /////////////////////////////////////////////
    //                 setFee
    /////////////////////////////////////////////

    function testSucces_setFee() public {
        assertEq(px.fee(), 100);

        vm.startPrank(creator);
        px.setFee(30);
        vm.stopPrank();

        assertEq(px.fee(), 30);
    }

    function testRevert_setFee_NonOwner() public {
        assertEq(px.fee(), 100);

        vm.startPrank(hacker);
        vm.expectRevert("Ownable: caller is not the owner");
        px.setFee(30);
        vm.stopPrank();
    }
}

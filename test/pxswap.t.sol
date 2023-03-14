// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "lib/forge-std/src/Test.sol";
import {Deploy} from "script/Deploy.s.sol";
import "../src/Pxswap.sol";
import "./mock/mockERC721.sol";
import "./mock/mockERC20.sol";

contract PxswapTest is Test {
    Pxswap px;

    MockERC721 pxs;

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
        /*         px.setProtocol(address(protocol)); */

        pxs = new MockERC721("pxs", "PXS");

        px.setPoints(address(pxs), address(pxs), address(protocol));

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
        pxs.mintTo(seller3);
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

    function testSuccess_putSwap() public {
        vm.startPrank(seller1);

        SwapParties[] memory maker_ = new SwapParties[](1);
        maker_[0].tokenStandard = 1;
        maker_[0].amount = 0;
        maker_[0].tokenId = 1;
        maker_[0].token = address(bayc);
        maker_[0].data = 0;

        SwapParties[] memory taker_ = new SwapParties[](1);
        maker_[0].tokenStandard = 1;
        maker_[0].amount = 0;
        maker_[0].tokenId = 2;
        maker_[0].token = address(butt);
        maker_[0].data = 0;

        px.putSwap(
            [seller1, address(bayc), 1, address(doge), 100, 1000, 100],
            maker_,
            taker_
        );
        vm.stopPrank();
    }

    /////////////////////////////////////////////
    //                 Admin
    /////////////////////////////////////////////

    /////////////////////////////////////////////
    //            setERC20Whitelist
    /////////////////////////////////////////////

    function testSuccess_setERC20Whitelist() public {
        vm.startPrank(creator);
        px.setERC20Whitelist(address(doge), true);
        px.setERC20Whitelist(address(elon), true);
        px.setERC20Whitelist(address(shiba), true);
        vm.stopPrank();

        assertEq(px.getERC20WhiteList(address(doge)), true);
        assertEq(px.getERC20WhiteList(address(elon)), true);
        assertEq(px.getERC20WhiteList(address(shiba)), true);
    }

    /////////////////////////////////////////////
    //                setPoints
    /////////////////////////////////////////////

    function testSuccess_setPoints() public {
        vm.startPrank(creator);
        px.setPoints(address(pxs), address(pxs), address(protocol));
        vm.stopPrank();
    }
}

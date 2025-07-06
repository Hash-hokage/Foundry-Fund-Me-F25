//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
contract FundMeTest is Test {
    FundMe fundMe;
    
    address USER = makeAddr("User");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;


    function setUp () external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }
    
    function testMinimumUsdIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgsender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        if (block.chainid == 11155111) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 6);
        }
    }

    function testFundFailsWithoutEnounghETH() public {
        vm.expectRevert(); // the next line should revert
        // asserts this transaction fails or reverts
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructures() public {
        vm.prank(USER); // makes the next transaction come from USER
        vm.deal(USER, STARTING_BALANCE); // gives USER 10 ether
        fundMe.fund{value: SEND_VALUE}();

        uint256 ammountFunded = fundMe.s_addressToAmountFunded(address(USER));
         assertEq(ammountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        vm.deal(USER, STARTING_BALANCE);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }
    
    modifier funded {
        vm.prank(USER);
        vm.deal(USER, STARTING_BALANCE);
        fundMe.fund{value: SEND_VALUE}();
        _;

    }
    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        //Assert
        uint256 endingOWnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOWnerBalance);
        
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i= startingFunderIndex; i < numberOfFunders; i++) {
            hoax (address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //Assert
        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);
    }

     function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i= startingFunderIndex; i < numberOfFunders; i++) {
            hoax (address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        //Assert
        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);
    }


}
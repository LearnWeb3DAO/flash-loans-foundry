// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {Counter} from "../src/Counter.sol";
import {FlashLoanExample} from "../src/FlashLoanExample.sol";
import "aave-v3-core/contracts/interfaces/IPoolAddressesProvider.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "forge-std/console.sol";

contract CounterTest is Test {
    //Ethereum Mainnet DAI Contract Address
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    // Random user's address that happens to have a lot of DAI on Ethereum Mainnet
    // By the time you're doing this lesson, if this address doesn't have DAI on Ethereum Mainnet,
    // switch it out for someone else who does have a lot of DAI
    address constant DAI_WHALE = 0x837c20D568Dfcd35E74E5CC0B8030f9Cebe10A28;

    // Mainnet Pool contract address
    address constant POOL_ADDRESS_PROVIDER =
        0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e;

    //vm.envString is provided by Foundry so that we can read our .env file and get values from there    
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");



    uint256 mainnetFork;
    IERC20 public token;

    FlashLoanExample public flashLoanExample;

    function setUp() public {
        // vm is a variable included in the forge standard library that is used to manipulate the execution environment of our tests
        // create a fork of Ethereum mainnet using the specified RPC URL and store its id in mainnetFork 
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
        //select the fork thus obtained, using its id
        vm.selectFork(mainnetFork);
        //deploy FlashLoanExample to the created fork with POOL_ADDRESS_PROVIDER as its constructor argument
        flashLoanExample = FlashLoanExample(POOL_ADDRESS_PROVIDER);
        //fetch the DAI contract
        token = IERC20(DAI);
    }

    function testTakeAndReturnLoan() public {

        // Get 2000 DAI in our contract by using deal
        // deal is a cheatcode that lets us arbitrarily set the balance of any address and works with most ERC-20 tokens
        uint BALANCE_AMOUNT_DAI = 2000 ether;
        deal(DAI, address(flashLoanExample), BALANCE_AMOUNT_DAI, true);

        console.log(token.balanceOf(address(flashLoanExample)));
        console.log(address(flashLoanExample));
        
        flashLoanExample.createFlashLoan(DAI, 10000);

        
        uint remainingBalance = token.balanceOf(address(flashLoanExample));
        console.log(remainingBalance);

        assertLt(remainingBalance, BALANCE_AMOUNT_DAI);
    }
}

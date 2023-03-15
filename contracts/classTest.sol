//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

// check there's something in balance against address

contract Test {

    // Getting Balance in Wallet 
    // Transfering Balance outside of wallet

    mapping(address => uint256) balances; 

    function addBalance(uint256 number, address user) external {
        balances[user] = number;
    }
 

    function getvalue(address user) external view returns(bool) {
        if (bytes(balances[user]).length > 0 )
        {
            return true;
        }
        else {
            return false;
        }

    }


    // 90+92 / 2 = 91
    // 91 + 98 / 2 = 94.5 


}
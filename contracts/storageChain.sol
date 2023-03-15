//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
import "@openzeppelin/contracts/access/Ownable.sol";

// Have to calculate average of Upcoming Stats against

contract StakingContract is Ownable {
    uint256 public adminTreasury;
    uint256 treasuryBalance;
    bool public paused;

    uint256 public totalStakedTokens;

    struct Stake {
        uint256 tokenAmount; // amount to stake
        // uint256 endTime; // when does the staking period end
        // uint256 startTime; // End time of Staking
        // uint256 bandWidth;
        // uint256 storageGB;
        // bool alreadyStaked;
    }

    struct Stats {
        uint256[] validationRatio; // when does the staking period end
        uint256[] upTime; // End time of Staking
        uint256[] bandWidth;
        uint256[] storageGB;
        bool newUser;
    }

    function updateStats(address user, uint256 _validationRatio, uint256 _upTime, uint256 _bandWidth, uint _storageGB ) external onlyOwner {
        // Just push data in array
        NodeStats[user].validationRatio.push(_validationRatio); 
        NodeStats[user].upTime.push(_upTime);
        NodeStats[user].bandWidth.push(_bandWidth); 
        NodeStats[user].storageGB.push(_storageGB);
    }

     

    mapping(address => uint256) public tokenAmount;
    mapping (address => Stats) public NodeStats; 

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }


    

    function transferTreasuryBalance(uint amount, address payable receiver) onlyOwner public  {
        require(amount <= treasuryBalance, "Insufficient Balance");
        require(!paused , "Contract is Paused");
        receiver.transfer(amount); 
        treasuryBalance -= amount; 
        
    }

    function stakeTokens(
        // uint256 _tokenAmount
        // 
        // uint256 _startTime,
        // uint256 _endTime,
        // uint256 _storageGB
    ) external payable {
        require(!paused, "Staking is paused");
        require(msg.value > 0, "Cannot stake 0");
        tokenAmount[_msgSender()] += msg.value; 
        totalStakedTokens += msg.value; 

        // if user has already Staked and want to stake more tokens and Specs
        // if (userStakes[_msgSender()].alreadyStaked == false) {
        //     userStakes[_msgSender()].endTime = _endTime;
        //     userStakes[_msgSender()].tokenAmount = _tokenAmount;
        //     userStakes[_msgSender()].startTime = _startTime;
        //     userStakes[_msgSender()].bandWidth = _bandWidth;
        //     userStakes[_msgSender()].storageGB = _storageGB;
        //     userStakes[_msgSender()].alreadyStaked = true;
        //     totalStakedTokens += _tokenAmount;
        // }
        // // if user is staking for first time
        // else {
        //     userStakes[_msgSender()].endTime += _endTime;
        //     userStakes[_msgSender()].tokenAmount += _tokenAmount;
        //     userStakes[_msgSender()].startTime += _startTime;
        //     userStakes[_msgSender()].bandWidth += _bandWidth;
        //     userStakes[_msgSender()].storageGB += _storageGB;
        //     userStakes[_msgSender()].alreadyStaked = true;
        //     totalStakedTokens += _tokenAmount;
        // }
    }

    function unStakeTokens(uint256 _tokenAmount, address payable toAccount)
        external
    {
        // check user exist before
        // Get number of tokens he want to unstake
        // require the amount of unstake tokens with total number of balance

        // The Only Owner can unstake his tokens

        require(!paused, "Contract is Paused");

        require(
            tokenAmount[_msgSender()] >= _tokenAmount,
            "Insufficient Tokens to WithDraw"
        );

        toAccount.transfer(_tokenAmount);
        tokenAmount[_msgSender()] -= _tokenAmount;

        emit TokenTransfer(_msgSender(), _tokenAmount);
    }

    function FlipPauseStatus() external onlyOwner {
        if (paused == true) {
            paused = false;
        } else {
            paused = true;
        }
    }

    function transferRewards(
        address payable receiverAddress,
        uint256 rewardAmount
    ) external onlyOwner {
        require(!paused, "Staking is paused");
        require(
            rewardAmount <= adminTreasury,
            "Treasury has Insufficient Tokens"
        );
        require(
            tokenAmount[_msgSender()] > 0,
            "User Does't have Staked"
        );
        receiverAddress.transfer(rewardAmount);
        adminTreasury -= rewardAmount;
        emit TokenTransfer(receiverAddress, rewardAmount);
    }

    function fillTreasury() external payable onlyOwner {
        require(msg.value > 0 , "Invalid Amount"); 
        adminTreasury += msg.value;
    }

    function withDrawFromTreasury(
        uint256 amount,
        address payable _receiverAddress
    ) external onlyOwner {
        require(adminTreasury >= amount, "Insufficient Funds to Withdraw");
        _receiverAddress.transfer(amount);
        adminTreasury -= amount;
        emit TokenTransfer(_receiverAddress, amount);
    }

    function totalHoldings() public {}


    function getStake(address user) external view returns (uint256) {
        return tokenAmount[user];
    }

    function getAllStakes(address account) public {}


    receive() external payable {
        emit EtherReceived(msg.sender, msg.value);
    }

    event FallbackTriggered(bytes data, address sender, uint256 value);
    event EtherReceived(address indexed sender, uint256 value);
    event TokenTransfer(address indexed add, uint256 value);

}

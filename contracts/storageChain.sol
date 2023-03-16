//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingContract is Ownable {
    mapping(address => uint256) tokenAmount;
    mapping(address => Stats) NodeStats;
    uint256 public adminTreasury;
    bool public paused;

    // Total Number of Staked tokens of Storage chain Nodes
    uint256 public totalStakedTokens;

    struct Stats {
        uint256[] validationRatio; // storage-node did't delete any data
        uint256[] upTime; // The Node was online
        uint256[] bandWidth; // Amount of Data that can be transfered in given amount of time
        uint256[] storageGB; // Amount of storage being Staked
        bool oldUser; // Flag to check old/new User
    }

    // Function to Update Stats of Storage-Nodes (Admin can Access)
    function updateStats(
        address user,
        uint256 _validationRatio,
        uint256 _upTime,
        uint256 _bandWidth,
        uint256 _storageGB
    ) external onlyOwner {
        require(tokenAmount[user] > 0, "No Staked amount against this user");
        NodeStats[user].validationRatio.push(_validationRatio);
        NodeStats[user].upTime.push(_upTime);
        NodeStats[user].bandWidth.push(_bandWidth);
        NodeStats[user].storageGB.push(_storageGB);
        emit StatsUpdated(
            user,
            _validationRatio,
            _upTime,
            _bandWidth,
            _storageGB
        );
    }

    // Admin can remove Storage Node Stats when the Stake is zero
    function deleteStats(address user) external onlyOwner {
        require(
            tokenAmount[user] == 0,
            "Unstake tokens before deleting Stat's"
        );
        delete NodeStats[user];
        emit StaorageNodeStatsDeleted(user); 

    }

    // Function to get Contract Address
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Function for USER to Stake STOR Tokens
    function stakeTokens() external payable {
        require(!paused, "Staking is paused");
        require(msg.value > 0, "Cannot stake 0");
        tokenAmount[_msgSender()] += msg.value;
        totalStakedTokens += msg.value;
        NodeStats[_msgSender()].oldUser = true;
    }

    // The user can unstake tokens as much he has in balance
    function unStakeTokens(uint256 _tokenAmount, address payable toAccount)
        external
    {
        require(!paused, "Contract is Paused");

        require(
            tokenAmount[_msgSender()] >= _tokenAmount,
            "Insufficient Tokens to WithDraw"
        );

        toAccount.transfer(_tokenAmount);
        tokenAmount[_msgSender()] -= _tokenAmount;
        totalStakedTokens -= _tokenAmount;
        emit TokenTransfer(_msgSender(), _tokenAmount);
    }

    // Function to Pause and Resume contract
    function FlipPauseStatus() external onlyOwner {
        if (paused == true) {
            paused = false;
        } else {
            paused = true;
        }
    }

    // The Function accessible by Admin to Disstribute rewards to Storage Nodes
    function transferRewards(
        address payable receiverAddress,
        uint256 rewardAmount
    ) external onlyOwner {
        require(!paused, "Staking is paused");
        require(
            rewardAmount <= adminTreasury,
            "Treasury has Insufficient Tokens"
        );
        require(tokenAmount[_msgSender()] > 0, "User Does't have Staked");
        receiverAddress.transfer(rewardAmount);
        adminTreasury -= rewardAmount;
        emit TokenTransfer(receiverAddress, rewardAmount);
    }

    // Funcction for Admin to Add more tokens in Treasury
    function fillTreasury() external payable onlyOwner {
        require(msg.value > 0, "Invalid Amount");
        adminTreasury += msg.value;
    }

    // Function for Admin to Transfer tokens from treasury
    function withDrawFromTreasury(
        uint256 amount,
        address payable _receiverAddress
    ) external onlyOwner {
        require(adminTreasury >= amount, "Insufficient Funds to Withdraw");
        _receiverAddress.transfer(amount);
        adminTreasury -= amount;
        emit TokenTransfer(_receiverAddress, amount);
    }

    // Function to get Staked Amount of User
    function getStake(address user) external view returns (uint256) {
        return tokenAmount[user];
    }

    // Function to get Stats of each storage Node
    function getNodeStats(address user) external view returns (Stats memory) {
        return NodeStats[user];
    }

    // FallBack Function
    receive() external payable {
        emit EtherReceived(msg.sender, msg.value);
    }

    // Events
    event FallbackTriggered(bytes data, address sender, uint256 value);
    event EtherReceived(address indexed sender, uint256 value);
    event TokenTransfer(address indexed add, uint256 value);
    event StatsUpdated(
        address indexed user,
        uint256 validationRatio,
        uint256 upTime,
        uint256 bandWidth,
        uint256 storageGB
    );
    event StaorageNodeStatsDeleted(address indexed user); 
}

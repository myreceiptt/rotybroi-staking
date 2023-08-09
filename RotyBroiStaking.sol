// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract RotyBroiStaking is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Interfaces for ERC20 and ERC721.
    IERC20 public immutable oioiToken;
    IERC721 public immutable therotybroiCollection;

    // Constructor function to set the rewards token and the NFT collection addresses.
    constructor(IERC721 _therotybroiCollection, IERC20 _oioiToken) {
        therotybroiCollection = _therotybroiCollection;
        oioiToken = _oioiToken;
    }

    struct StakedRotyBroi {
        address staker;
        uint256 rotybroiId;
    }

    // Staker info.
    struct Staker {
        // Amount of NFT staked by the staker.
        uint256 amountStaked;
        // IDs of the NFT staked by the staker.
        StakedRotyBroi[] stakedRotyBrois;
        // Last time of the rewards were calculated for this staker.
        uint256 timeOfLastUpdate;
        // Calculated, but unclaimed rewards for the staker.
        // The rewards are calculated each time the staker writes to this staking smart contract.
        uint256 unclaimedRewards;
    }

    // Rewards per hour in wei for each NFT staked by the staker.
    uint256 private rewardsPerHour = 47474747;

    // Mapping of staker address to staker info.
    mapping(address => Staker) public stakers;

    // Mapping of NFT ID to staker.
    // Made for this staking smart contract to remember who to send back the NFT/s to.
    mapping(uint256 => address) public stakerAddress;

    // If the staker address already has NFT/s staked, calculate the rewards.
    // Increment the "amountStaked" and map "msg.sender" to the IDs of the staked NFTs to later send back on withdrawal.
    // Finally give "timeOfLastUpdate" the value of now.
    function stake(uint256 _rotybroiId) external nonReentrant {
        // If wallet has staked NFT/s, calculate the rewards before adding the new NFT.
        if (stakers[msg.sender].amountStaked > 0) {
            uint256 rewards = calculateRewards(msg.sender);
            stakers[msg.sender].unclaimedRewards += rewards;
        }

        // Wallet must own the NFT they are trying to stake.
        require(
            therotybroiCollection.ownerOf(_rotybroiId) == msg.sender,
            "You are not #OiOi!!!! Buy The ROTY BROI now!!!!!!!"
        );

        // Transfer the NFT from the wallet to this staking smart contract.
        therotybroiCollection.transferFrom(
            msg.sender,
            address(this),
            _rotybroiId
        );

        // Create "StakedRotyBroi".
        StakedRotyBroi memory stakedRotyBroi = StakedRotyBroi(
            msg.sender,
            _rotybroiId
        );

        // Add the NFT to the "stakedRotyBrois" array.
        stakers[msg.sender].stakedRotyBrois.push(stakedRotyBroi);

        // Increment the amount of NFT staked for this wallet.
        stakers[msg.sender].amountStaked++;

        // Update the mapping of the "rotybroiId" to the staker's address.
        stakerAddress[_rotybroiId] = msg.sender;

        // Update the "timeOfLastUpdate" for the staker
        stakers[msg.sender].timeOfLastUpdate = block.timestamp;
    }

    // Check if staker has any NFT staked and if they tried to withdraw, calculate the rewards and store them in the "unclaimedRewards" decrement the "amountStaked" of the staker and transfer the NFT back to them.
    function withdraw(uint256 _rotybroiId) external nonReentrant {
        // Make sure the staker has at least one NFT staked before withdrawing.
        require(
            stakers[msg.sender].amountStaked > 0,
            "You have no ROTY BROI staked!!!! Stake The ROTY BROI now!!!!!!!"
        );

        // Wallet must own the NFT they are trying to withdraw.
        require(
            stakerAddress[_rotybroiId] == msg.sender,
            "You don't own this ROTY BROI!!!!!!!"
        );

        // Update the rewards for this staker, as the amount of rewards decreases with less NFTs.
        uint256 rewards = calculateRewards(msg.sender);
        stakers[msg.sender].unclaimedRewards += rewards;

        // Find the index of this NFT ID in the "stakedRotyBrois" array
        uint256 index = 0;
        for (
            uint256 i = 0;
            i < stakers[msg.sender].stakedRotyBrois.length;
            i++
        ) {
            if (
                stakers[msg.sender].stakedRotyBrois[i].rotybroiId ==
                _rotybroiId &&
                stakers[msg.sender].stakedRotyBrois[i].staker != address(0)
            ) {
                index = i;
                break;
            }
        }

        // Set this NFT's staker to be address 0 to mark it as no longer staked.
        stakers[msg.sender].stakedRotyBrois[index].staker = address(0);

        // Decrement the amount of NFT staked for this wallet.
        stakers[msg.sender].amountStaked--;

        // Update the mapping of the "rotybroiId" to the be "address(0)" to indicate that the NFT is no longer staked.
        stakerAddress[_rotybroiId] = address(0);

        // Transfer the NFT back to the staker address.
        therotybroiCollection.transferFrom(
            address(this),
            msg.sender,
            _rotybroiId
        );

        // Update the "timeOfLastUpdate" for the staker.
        stakers[msg.sender].timeOfLastUpdate = block.timestamp;
    }

    // Calculate rewards for the "msg.sender", check if there are any rewards claim, set "unclaimedRewards" to 0 and transfer the reward tokens to the user.
    function claimRewards() external {
        uint256 rewards = calculateRewards(msg.sender) +
            stakers[msg.sender].unclaimedRewards;
        require(rewards > 0, "You have no OiOi tokens to claim");
        stakers[msg.sender].timeOfLastUpdate = block.timestamp;
        stakers[msg.sender].unclaimedRewards = 0;
        oioiToken.safeTransfer(msg.sender, rewards);
    }

    //////////
    // View //
    //////////

    function availableRewards(address _staker) public view returns (uint256) {
        uint256 rewards = calculateRewards(_staker) +
            stakers[_staker].unclaimedRewards;
        return rewards;
    }

    function getStakedRotyBrois(address _user)
        public
        view
        returns (StakedRotyBroi[] memory)
    {
        // Check if we know this staker.
        if (stakers[_user].amountStaked > 0) {
            // Return all the NFTs in the "stakedRotyBroi" Array for this staker that are not -1.
            StakedRotyBroi[] memory _stakedRotyBrois = new StakedRotyBroi[](
                stakers[_user].amountStaked
            );
            uint256 _index = 0;

            for (
                uint256 j = 0;
                j < stakers[_user].stakedRotyBrois.length;
                j++
            ) {
                if (stakers[_user].stakedRotyBrois[j].staker != (address(0))) {
                    _stakedRotyBrois[_index] = stakers[_user].stakedRotyBrois[
                        j
                    ];
                    _index++;
                }
            }

            return _stakedRotyBrois;
        }
        // Otherwise, return empty array.
        else {
            return new StakedRotyBroi[](0);
        }
    }

    /////////////
    // Internal//
    /////////////

    // Calculate rewards for "param _staker" by calculating the time passed since last update in hours and mulitplying it to amount of NFT staked and "rewardsPerHour".
    function calculateRewards(address _staker)
        internal
        view
        returns (uint256 _rewards)
    {
        return (((
            ((block.timestamp - stakers[_staker].timeOfLastUpdate) *
                stakers[_staker].amountStaked)
        ) * rewardsPerHour) / 3600);
    }
}

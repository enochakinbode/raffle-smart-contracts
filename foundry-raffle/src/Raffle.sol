// SPDX-License-Identifier: Unlicense
pragma solidity ~0.8.0;

import { VRFv2PlusWrapperConsumer } from "./VRFv2PlusWrapperConsumer.sol";
import { AutomationCompatible } from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

error Raffle__NotEnoughEthSent();
error Raffle__TransferFailed();
error Raffle__RaffleNotOpen();

/**
 * @notice Error thrown when performUpkeep is called but conditions aren't met.
 * @param balance The current contract balance.
 * @param players The current number of tickets/players.
 * @param expired Whether the raffle interval has passed.
 * @param pickingWinner Whether a winner selection is already in progress.
 */
error Raffle__UpkeepNotNeeded(uint256 balance, uint256 players, bool expired, bool pickingWinner);

/**
 * @title A sample Raffle Contract
 * @author enochakinbode
 * @notice This contract is for creating a sample raffle using Chainlink VRF and Automation.
 */
contract Raffle is VRFv2PlusWrapperConsumer, AutomationCompatible {
    uint256 private immutable i_entranceFee;
    uint256 private constant INTERVAL = 5 minutes;

    uint256 private s_currentEpoch;
    uint256 private s_epochStartTime;
    uint256 private s_ticketsInCurrentEpoch;

    // mapping(epoch => mapping(ticketId => participant))
    mapping(uint256 => mapping(uint256 => address)) private s_tickets;

    event Raffle__TicketsPurchased(address indexed participant, uint256 ntickets);
    event Raffle__WinnerRequested(uint256 indexed requestId);
    event Raffle__EpochCompleted(
        uint256 indexed currentEpoch, address indexed winner, uint256 winningTicket, uint256 reward, uint256 ntickets
    );
    event Raffle__EpochSkipped(uint256 indexed epoch);

    /**
     * @param entranceFee The price in wei for a single ticket.
     * @param vrfWrapper The address of the VRF V2 Plus Wrapper.
     */
    constructor(uint256 entranceFee, address vrfWrapper) VRFv2PlusWrapperConsumer(vrfWrapper) {
        i_entranceFee = entranceFee;
        s_epochStartTime = block.timestamp;
    }

    /**
     * @notice Enter the raffle by sending ETH. Number of tickets is calculated by value / fee.
     * @dev Excess ETH is refunded to the sender.
     */
    function enterRaffle() public payable {
        if (block.timestamp >= s_epochStartTime + INTERVAL) revert Raffle__RaffleNotOpen();

        uint256 ticketsToPurchase = msg.value / i_entranceFee;
        if (ticketsToPurchase == 0) revert Raffle__NotEnoughEthSent();

        uint256 _ticketsInEpoch = s_ticketsInCurrentEpoch;
        uint256 _epoch = s_currentEpoch;
        for (uint256 i = 0; i < ticketsToPurchase; i++) {
            s_tickets[_epoch][_ticketsInEpoch + i] = msg.sender;
        }
        s_ticketsInCurrentEpoch = _ticketsInEpoch + ticketsToPurchase;

        // Refund excess ETH
        uint256 excess = msg.value % i_entranceFee;
        if (excess > 0) {
            (bool success,) = payable(msg.sender).call{ value: excess }("");
            if (!success) revert Raffle__TransferFailed();
        }

        emit Raffle__TicketsPurchased(msg.sender, ticketsToPurchase);
    }

    /**
     * @dev Implementation of the virtual callback from VRFv2PlusWrapperConsumer.
     * @notice Selects a winner using randomness and distributes the entire contract balance as a reward.
     * @param randomWords The array of random numbers returned by Chainlink VRF.
     */
    function onRandomWordsFulfilled(
        uint256,
        /* requestId */
        uint256[] memory randomWords
    )
        internal
        override
    {
        uint256 _currentEpoch = s_currentEpoch;
        uint256 _ticketsInCurrentEpoch = s_ticketsInCurrentEpoch;

        // The reward is the total balance, which includes entries minus the VRF fee.
        uint256 reward = address(this).balance;

        uint256 winningTicketIndex = randomWords[0] % _ticketsInCurrentEpoch;
        address winner = s_tickets[_currentEpoch][winningTicketIndex];

        _startNextEpoch();

        (bool success,) = payable(winner).call{ value: reward }("");
        if (!success) revert Raffle__TransferFailed();

        emit Raffle__EpochCompleted(_currentEpoch, winner, winningTicketIndex, reward, _ticketsInCurrentEpoch);
    }

    /**
     * @dev Off-chain check for Chainlink Automation to determine if winner should be picked.
     * @return upkeepNeeded True if the raffle interval has passed and no winner is currently being picked.
     */
    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        bool raffleExpired = (block.timestamp - s_epochStartTime) >= INTERVAL;
        bool pickingWinner = s_lastRequestId != 0 && s_currentRequestStatus.fulfilled == false;

        upkeepNeeded = raffleExpired && !pickingWinner;
        return (upkeepNeeded, "0x");
    }

    /**
     * @dev On-chain execution triggered by Automation to request randomness.
     */
    function performUpkeep(
        bytes calldata /* performData */
    )
        external
        override
    {
        bool raffleExpired = (block.timestamp - s_epochStartTime) >= INTERVAL;
        bool pickingWinner = s_lastRequestId != 0 && s_currentRequestStatus.fulfilled == false;
        bool hasPlayers = s_ticketsInCurrentEpoch > 0;

        if (!raffleExpired || pickingWinner || !hasPlayers) {
            // If the raffle expired but there were no players, we skip to the next epoch
            if (raffleExpired && !pickingWinner && !hasPlayers) {
                _startNextEpoch();
                emit Raffle__EpochSkipped(s_currentEpoch - 1);
                return;
            }
            revert Raffle__UpkeepNotNeeded(address(this).balance, s_ticketsInCurrentEpoch, raffleExpired, pickingWinner);
        }

        (uint256 requestId,) = _requestRandomness();
        emit Raffle__WinnerRequested(requestId);
    }

    /**
     * @dev Internal helper to reset state and advance to the next epoch.
     */
    function _startNextEpoch() private {
        s_epochStartTime = block.timestamp;
        s_currentEpoch++;
        s_ticketsInCurrentEpoch = 0;
    }

    /* Getter Functions */

    /**
     * @return The entrance fee in wei for a single ticket.
     */
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    /**
     * @param epoch The epoch to query.
     * @param ticketId The ticket index to query.
     * @return The address of the participant who owns the ticket.
     */
    function getTicketParticipant(uint256 epoch, uint256 ticketId) external view returns (address) {
        return s_tickets[epoch][ticketId];
    }

    /**
     * @return The number of tickets purchased in the current epoch.
     */
    function getTicketsInCurrentEpoch() external view returns (uint256) {
        return s_ticketsInCurrentEpoch;
    }

    /**
     * @return The index of the current epoch.
     */
    function getCurrentEpoch() external view returns (uint256) {
        return s_currentEpoch;
    }

    /**
     * @return The timestamp when the current epoch started.
     */
    function getEpochStartTime() external view returns (uint256) {
        return s_epochStartTime;
    }
}

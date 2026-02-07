// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { VRFV2PlusWrapperConsumerBase } from "@chainlink/contracts/src/v0.8/vrf/dev/VRFV2PlusWrapperConsumerBase.sol";
import { VRFV2PlusClient } from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

error VRFv2PlusWrapperConsumer__UnAuthorisedCaller();
error VRFv2PlusWrapperConsumer__WithdrawalFailed();

/**
 * @title VRFv2PlusWrapperConsumer
 * @author enochakinbode
 * @notice An abstract contract for consuming Chainlink VRF V2 Plus using the Direct Funding model (Wrapper).
 * @dev This contract handles request tracking, ownership, and configuration for VRF consumers.
 */
abstract contract VRFv2PlusWrapperConsumer is VRFV2PlusWrapperConsumerBase {
    /**
     * @dev Status of a VRF request.
     * @param paid The amount in native currency paid for the request.
     * @param fulfilled Whether the request has been fulfilled by the Chainlink node.
     */
    struct RequestStatus {
        uint256 paid;
        bool fulfilled;
    }

    address public immutable i_wrapperAddress;
    uint16 public immutable i_requestConfirmations = 3;
    uint32 public immutable i_numWords = 1;

    address public s_owner;
    uint256 public s_lastRequestId;
    RequestStatus s_currentRequestStatus;
    uint32 public s_callbackGasLimit = 500_000;

    /**
     * @notice Emitted when a random word request is fulfilled.
     * @param requestId The ID of the request that was fulfilled.
     * @param randomWords The array of random numbers returned by Chainlink VRF.
     * @param payment The amount paid for the request.
     */
    event RequestFulfilled(uint256 requestId, uint256[] randomWords, uint256 payment);

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    /**
     * @notice Initializes the contract with the VRF Wrapper address.
     * @param _wrapperAddress The address of the VRF V2 Plus Wrapper contract.
     */
    constructor(address _wrapperAddress) VRFV2PlusWrapperConsumerBase(_wrapperAddress) {
        i_wrapperAddress = _wrapperAddress;
        s_owner = msg.sender;
    }

    function _onlyOwner() internal view {
        if (msg.sender != s_owner) revert VRFv2PlusWrapperConsumer__UnAuthorisedCaller();
    }

    /**
     * @notice Internal helper to request randomness using native currency.
     * @dev Updates s_currentRequestStatus to track the new request.
     * @return requestId The ID of the created VRF request.
     * @return reqPrice The cost paid for the request in native currency.
     */
    function _requestRandomness() internal returns (uint256 requestId, uint256 reqPrice) {
        bytes memory extraArgs = VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({ nativePayment: true }));
        (requestId, reqPrice) =
            requestRandomnessPayInNative(s_callbackGasLimit, i_requestConfirmations, i_numWords, extraArgs);
        s_lastRequestId = requestId;

        s_currentRequestStatus = RequestStatus({ paid: reqPrice, fulfilled: false });
    }

    /**
     * @dev The base implementation of fulfillRandomWords from VRFV2PlusWrapperConsumerBase.
     * It updates the local fulfillment status and then calls the virtual onRandomWordsFulfilled.
     * @param _requestId The ID of the request being fulfilled.
     * @param _randomWords The randomness results provided by the Chainlink node.
     */
    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(s_currentRequestStatus.paid > 0, "request not found");
        s_currentRequestStatus.fulfilled = true;

        emit RequestFulfilled(_requestId, _randomWords, s_currentRequestStatus.paid);

        onRandomWordsFulfilled(_requestId, _randomWords);
    }

    /**
     * @dev Child contracts must override this to implement their specific logic (e.g., picking a winner).
     */
    function onRandomWordsFulfilled(uint256 requestId, uint256[] memory randomWords) internal virtual;

    /**
     * @notice Updates the callback gas limit for future VRF requests.
     * @param _callbackGasLimit The new gas limit for the callback.
     */
    function setCallbackGasLimit(uint32 _callbackGasLimit) external onlyOwner {
        s_callbackGasLimit = _callbackGasLimit;
    }

    /**
     * @notice Transfers ownership of the contract to a new address.
     * @param _newOwner The address of the new owner.
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        if (_newOwner == address(0)) revert("New owner is zero address");
        s_owner = _newOwner;
    }

    /**
     * @notice Withdraws the contract's native balance to the owner.
     */
    function withdrawBalance() external onlyOwner {
        (bool success,) = payable(s_owner).call{ value: address(this).balance }("");
        if (!success) revert VRFv2PlusWrapperConsumer__WithdrawalFailed();
    }

    /**
     * @dev Fallback function to allow the contract to receive native currency.
     */
    receive() external payable { }
}

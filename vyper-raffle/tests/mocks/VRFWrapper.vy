# tests/mocks/VrfWrapper.vy

interface VrfRouter:
    def new_entry(request_id: uint256, target: address): nonpayable

interface VRFRequestCallback:
    def rawFulfillRandomWords(request_id: uint256, random_words: DynArray[uint256, 1]): nonpayable

last_request_id: public(uint256)
router: public(address)
consumers: HashMap[uint256, address]  # request_id -> consumer (raffle) address

@deploy
def __init__(_router: address):
    self.router = _router


@external
@view
def calculateRequestPriceNative(_callbackGasLimit: uint32, _numWords: uint32) -> uint256:
    return 0  # free in tests

@external
@payable
def requestRandomWordsInNative(
    _callbackGasLimit: uint32,
    _requestConfirmations: uint16,
    _numWords: uint32,
    extraArgs: Bytes[1024]
) -> uint256:
    self.last_request_id += 1
    request_id: uint256 = self.last_request_id
    
    # Store which consumer (raffle) made this request
    self.consumers[request_id] = msg.sender
    
    # Register this request with the router so it knows which wrapper to call
    # The router will call this wrapper's fulfillRandomWords, which then calls the consumer
    if self.router != empty(address):
        extcall VrfRouter(self.router).new_entry(request_id, self)
    
    # In the real Chainlink flow, this function only queues the request and
    # returns a request ID. The VRF coordinator later calls back into the
    # wrapper's fulfill function, which then calls the consumer.
    #
    # To mirror that separation in tests, we do NOT call the raffle here.
    # Tests should simulate fulfillment by calling `router.transmit(...)`.
    return request_id


@external
def fulfillRandomWords(request_id: uint256, random_words: DynArray[uint256, 1]):
    """
    Called by the router to fulfill a VRF request. This wrapper then forwards
    the callback to the consumer contract (raffle) that originally made the request.
    """
    consumer: address = self.consumers[request_id]
    assert consumer != empty(address), "no consumer for request_id"
    
    # Forward the callback to the consumer contract
    # msg.sender here is this wrapper, which is what the raffle expects
    extcall VRFRequestCallback(consumer).rawFulfillRandomWords(request_id, random_words)
# tests/mocks/VrfRouter.vy

# Minimal mock router that:
#  - lets you register a wrapper contract for a given request_id
#  - has a `transmit` function that calls the wrapper's fulfillRandomWords

interface VrfWrapper:
    def fulfillRandomWords(request_id: uint256, random_words: DynArray[uint256, 1]): nonpayable

entries: HashMap[uint256, address]  # request_id -> wrapper address


@deploy
def __init__():
    # HashMap is empty by default
    pass


@external
def new_entry(request_id: uint256, target: address):
    """
    Register the wrapper contract that should receive the VRF callback for this request_id.
    The wrapper will then forward it to the consumer (raffle).
    """
    self.entries[request_id] = target


@external
def transmit(request_id: uint256, random_words: DynArray[uint256, 1]):
    """
    Simulate an OCR/VRF report: look up the wrapper for `request_id`
    and call its `fulfillRandomWords` function, which will forward to the consumer.
    """
    wrapper: address = self.entries[request_id]
    assert wrapper != empty(address), "no wrapper for request_id"

    extcall VrfWrapper(wrapper).fulfillRandomWords(request_id, random_words)
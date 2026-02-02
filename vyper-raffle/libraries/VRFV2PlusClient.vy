# pragma version ^0.4.0

struct ExtraArgsV1:
    native_payment: bool

# first 4 bytes of keccak256("VRF ExtraArgsV1")
EXTRA_ARGS_V1_TAG: constant(bytes4) = 0x92fd1338

@internal
@pure
def args_to_bytes(extra_args: ExtraArgsV1) -> Bytes[1024]:
    return concat(EXTRA_ARGS_V1_TAG, abi_encode(extra_args))

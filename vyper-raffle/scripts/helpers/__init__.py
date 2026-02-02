import os
from types import SimpleNamespace
from dotenv import load_dotenv
from eth_utils import to_wei

# Load environment variables at module import time
load_dotenv()

# Now safe to use os.getenv()
rpc_url = os.getenv("SEPOLIA_RPC_URL")
private_key = os.getenv("PRIVATE_KEY")
private_key2 = os.getenv("PRIVATE_KEY_2")
etherscan_key = os.getenv("ETHERSCAN_API_KEY")

c_args = SimpleNamespace(
    entrance_fee=to_wei(0.01, "ether"),
    vrf_wrapper_address="0x195f15F2d49d693cE265b4fB0fdDbE15b1850Cc1",
)

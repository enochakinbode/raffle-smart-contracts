import boa
from contextlib import contextmanager
from eth_utils.currency import to_wei
import pytest

entrance_fee = to_wei(0.01, "ether")
DEFAULT_VRF_WRAPPER_ADDRESS = "0x0000000000000000000000000000000000000000"


@pytest.fixture
def accounts():
    """Create test accounts with balances using boa's generate_address"""
    # In boa test mode, use generate_address() to create new addresses
    accounts_list = []

    for i in range(5):
        # Generate a new address
        account_address = boa.env.generate_address()

        # Set balance to 100 ETH (in wei)
        boa.env.set_balance(account_address, to_wei(100, "ether"))
        accounts_list.append(account_address)

    return accounts_list


@contextmanager
def fresh_raffle(vrf_wrapper_address=None):
    """Context manager that creates a fresh raffle contract.
    Use this instead of the raffle fixture for better test isolation."""
    vrf_address = vrf_wrapper_address or DEFAULT_VRF_WRAPPER_ADDRESS
    raffle_contract = boa.load("contracts/Raffle.vy", entrance_fee, vrf_address)
    yield raffle_contract


@contextmanager
def fresh_raffle_and_account(balance_ether=100, vrf_wrapper_address=None):
    """Context manager that creates a fresh raffle contract and funded account.
    Automatically sets and restores the EOA."""
    vrf_address = vrf_wrapper_address or DEFAULT_VRF_WRAPPER_ADDRESS
    raffle_contract = boa.load("contracts/Raffle.vy", entrance_fee, vrf_address)
    account = boa.env.generate_address()
    boa.env.set_balance(account, to_wei(balance_ether, "ether"))

    # Save current EOA and set new one
    old_eoa = boa.env.eoa
    boa.env.eoa = account

    try:
        yield raffle_contract, account
    finally:
        # Restore previous EOA
        boa.env.eoa = old_eoa


def setup_account(balance_ether=100):
    """Helper to create and fund an account."""
    account = boa.env.generate_address()
    boa.env.set_balance(account, to_wei(balance_ether, "ether"))
    return account

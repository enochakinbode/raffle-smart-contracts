import boa
from eth_utils import to_wei
from hypothesis import given, strategies as st

from tests.units.conftest import (
    entrance_fee,
    fresh_raffle,
    fresh_raffle_and_account,
    setup_account,
)


def test_enter_raffle():
    """Test entering raffle with a single ticket"""
    with fresh_raffle_and_account() as (raffle, account):

        # Initial state check
        assert raffle.total_tickets_in_current_epoch() == 0

        ntickets = 1
        total_fee = ntickets * entrance_fee

        raffle.enter_raffle(value=total_fee)

        assert raffle.total_tickets_in_current_epoch() == ntickets
        assert raffle.get_ticket_owner(0, 0) == account


def test_enter_raffle_after_epoch_deadline():
    with fresh_raffle_and_account() as (raffle, _):
        boa.env.time_travel(seconds=301)

        with boa.reverts("raffle not open"):
            raffle.enter_raffle(value=entrance_fee)


def test_enter_raffle_excess_eth_refunded():
    """Test that excess ETH is refunded (accounting for gas costs)"""
    with fresh_raffle_and_account() as (raffle, account):

        initial_balance = boa.env.get_balance(account)
        excess = to_wei(0.005, "ether")
        total_sent = entrance_fee + excess

        raffle.enter_raffle(value=total_sent)

        assert raffle.total_tickets_in_current_epoch() == 1

        final_balance = boa.env.get_balance(account)
        expected_balance = initial_balance - entrance_fee

        assert final_balance == expected_balance, (
            f"Balance mismatch. Initial: {initial_balance}, Final: {final_balance}, "
            f"Expected: {expected_balance}, Entrance fee: {entrance_fee}, "
        )


# ============================================================================
# FUZZ TESTS - Property-based testing with Hypothesis
# ============================================================================


@given(num_tickets=st.integers(min_value=1, max_value=100))  # Test 1 to 100 tickets
def test_enter_raffle_fuzz_tickets(num_tickets):
    """Fuzz test: Test entering raffle with random number of tickets"""
    with fresh_raffle_and_account() as (raffle, account):
        total_fee = num_tickets * entrance_fee

        raffle.enter_raffle(value=total_fee)

        assert raffle.total_tickets_in_current_epoch() == num_tickets

        for i in range(num_tickets):
            assert raffle.get_ticket_owner(0, i) == account


@given(
    num_users=st.integers(min_value=1, max_value=5),  # 1-5 users
    tickets_per_user=st.lists(
        st.integers(min_value=1, max_value=10),  # Each user buys 1-10 tickets
        min_size=1,
        max_size=5,
    ),
)
def test_enter_raffle_fuzz_multiple_users(num_users, tickets_per_user):
    """Fuzz test: Test multiple users entering with random ticket counts"""
    with fresh_raffle() as raffle:
        # Limit to available accounts and create them
        num_users = min(num_users, len(tickets_per_user))
        tickets_per_user = tickets_per_user[:num_users]

        accounts_list = [setup_account() for _ in range(num_users)]

        total_expected_tickets = 0

        # Each user enters with their ticket count
        for i, ticket_count in enumerate(tickets_per_user):
            boa.env.eoa = accounts_list[i]
            total_fee = ticket_count * entrance_fee
            raffle.enter_raffle(value=total_fee)
            total_expected_tickets += ticket_count

        # Verify total tickets
        assert raffle.total_tickets_in_current_epoch() == total_expected_tickets

        # Verify ticket ownership
        ticket_index = 0
        for i, ticket_count in enumerate(tickets_per_user):
            for j in range(ticket_count):
                assert raffle.get_ticket_owner(0, ticket_index) == accounts_list[i]
                ticket_index += 1


@given(
    excess_amount=st.integers(
        min_value=1,
        max_value=entrance_fee - 1,  # Excess must be less than entrance_fee
    )
)
def test_enter_raffle_fuzz_excess_refund(excess_amount):
    """Fuzz test: Test that various excess amounts are refunded"""
    with fresh_raffle_and_account() as (raffle, account):
        initial_balance = boa.env.get_balance(account)
        total_sent = entrance_fee + excess_amount

        raffle.enter_raffle(value=total_sent)

        # Should have exactly 1 ticket (excess is less than entrance_fee, so can't buy extra tickets)
        assert raffle.total_tickets_in_current_epoch() == 1

        # Verify excess was refunded
        final_balance = boa.env.get_balance(account)
        expected_balance = initial_balance - entrance_fee

        assert final_balance == expected_balance, (
            f"Excess not refunded properly. Excess: {excess_amount}, "
            f"Expected balance: {expected_balance}, Got: {final_balance}"
        )


@given(
    value_sent=st.integers(
        min_value=1, max_value=to_wei(10, "ether")  # Test various amounts
    )
)
def test_enter_raffle_fuzz_various_amounts(value_sent):
    """Fuzz test: Test entering with various ETH amounts"""
    with fresh_raffle_and_account() as (raffle, account):
        initial_balance = boa.env.get_balance(account)

        # Calculate expected tickets (floor division)
        expected_tickets = value_sent // entrance_fee

        if expected_tickets == 0:
            # Should revert if not enough for even 1 ticket
            with boa.reverts("not enough eth sent"):
                raffle.enter_raffle(value=value_sent)
        else:
            raffle.enter_raffle(value=value_sent)

            # Verify ticket count (capped at MAX_TICKETS)
            max_tickets = raffle.get_max_tickets()
            actual_tickets = min(expected_tickets, max_tickets)
            assert raffle.total_tickets_in_current_epoch() == actual_tickets

            # Verify balance (excess refunded)
            final_balance = boa.env.get_balance(account)
            expected_balance = initial_balance - (actual_tickets * entrance_fee)

            # If we hit MAX_TICKETS, there might be additional excess
            if expected_tickets > max_tickets:
                expected_balance = initial_balance - (max_tickets * entrance_fee)

            assert final_balance == expected_balance, (
                f"Balance mismatch. Value sent: {value_sent}, "
                f"Expected tickets: {actual_tickets}, Expected balance: {expected_balance}, "
                f"Got: {final_balance}"
            )

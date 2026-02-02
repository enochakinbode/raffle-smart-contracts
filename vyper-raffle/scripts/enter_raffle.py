import boa
from eth_account import Account
from helpers import private_key, private_key2, rpc_url, c_args


total_value = c_args.entrance_fee * 3


try:
    with open("broadcast/deployed_address.txt", "r") as f:
        raffle_address = f.read().strip()
except FileNotFoundError:
    raffle_address = None


def enter():
    boa.set_network_env(rpc_url)

    print(f"Connecting to Raffle at: {raffle_address}")
    raffle = boa.load_partial("contracts/Raffle.vy").at(raffle_address)

    boa.env.add_account(Account.from_key(private_key), force_eoa=True)
    print(f"Signer: {boa.env.eoa}")
    print(f"Entering raffle for 3 tickets (Cost: {total_value / 10**18} ETH)...")
    raffle.enter_raffle(value=total_value)

    boa.env.add_account(Account.from_key(private_key2), force_eoa=True)
    print(f"Signer: {boa.env.eoa}")
    print(f"Entering raffle for 3 tickets (Cost: {total_value / 10**18} ETH)...")
    raffle.enter_raffle(value=total_value)

    print("Success! Tickets purchased.")
    print(f"New total tickets in epoch: {raffle.total_tickets_in_current_epoch()}")


if __name__ == "__main__":
    enter()

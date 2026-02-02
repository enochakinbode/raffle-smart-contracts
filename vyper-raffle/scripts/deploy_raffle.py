import boa
from eth_account import Account
from helpers import private_key, rpc_url, c_args


def main():
    boa.set_network_env(rpc_url)
    boa.env.add_account(Account.from_key(private_key))

    raffle = boa.load(
        "contracts/Raffle.vy", c_args.entrance_fee, c_args.vrf_wrapper_address
    )

    # Automate: Write the deployed address to a file for verify.py
    with open("broadcast/deployed_address.txt", "w") as f:
        f.write(raffle.address)


if __name__ == "__main__":
    main()

# Provably Random Raffle Contracts (Solidity)

> **📊 Comparison**: This is the Solidity implementation. For a side-by-side comparison with the Vyper implementation, see the [root README](../README.md).

## About

This is a provably random smart contract lottery built with Foundry, using Chainlink VRF for randomness and Chainlink Automation for automated winner selection.

## Features

1. Users can enter the raffle by paying for tickets. The ticket fees accumulate as the prize pool that the winner receives.
2. The lottery automatically and programmatically draws a winner after a certain period (5 minutes).
3. Chainlink VRF generates a provably random number to select the winner.
4. Chainlink Automation triggers the lottery draw regularly when conditions are met.

## Tech Stack

- **Solidity**: Smart contract development
- **Foundry**: Development framework
- **Chainlink VRF V2 Plus**: Provably random number generation
- **Chainlink Automation**: Automated upkeep execution

## Setup

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Node.js (for dependencies)

### Installation

1. Clone the repository (if you haven't already):
```bash
# Option 1: Clone with submodules recursively
git clone --recursive <repository-url>
cd raffle/foundry-raffle

# Option 2: Clone normally, then initialize submodules
git clone <repository-url>
cd raffle/foundry-raffle
git submodule update --init --recursive
```

2. Install dependencies:
```bash
forge install
```

**Note**: This project uses git submodules for dependencies (`forge-std` and `chainlink-brownie-contracts`). The submodules are defined at the repository root level (in `../.gitmodules`), not in this directory. If you cloned without `--recursive`, run `git submodule update --init --recursive` from the repository root before `forge install`. The `forge install` command will also handle submodule initialization automatically.

3. Set up environment variables:
Copy `.env.example` to `.env` and fill in your values:
```bash
cp .env.example .env
```

Then edit `.env` with your actual values:
- `SEPOLIA_RPC_URL`: Your Ethereum RPC endpoint
- `PRIVATE_KEY`: Your deployment account private key
- `ETHERSCAN_API_KEY`: Your Etherscan API key (for contract verification)

### Deployment

Deploy the contract to Sepolia:
```bash
forge script script/01_DeployRaffle.s.sol:DeployRaffle --rpc-url sepolia --broadcast --verify
```

### Usage

Enter the raffle:
```bash
forge script script/02_EnterRaffle.s.sol:EnterRaffle --rpc-url sepolia --broadcast
```

## Contract Details

- **Entrance Fee**: 0.01 ETH per ticket
- **Interval**: 5 minutes per epoch
- **Network**: Sepolia Testnet

## License

This project is licensed under the Unlicense - see the LICENSE file for details.
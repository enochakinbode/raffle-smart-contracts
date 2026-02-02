# Raffle Contract - Solidity (Foundry)

A provably random smart contract lottery built with **Solidity** and **Foundry**, using Chainlink VRF for randomness and Chainlink Automation for automated winner selection.

> This is the Solidity/Foundry implementation. For an overview of both implementations, see the [root README](../README.md).

## 📋 Table of Contents

- [About](#about)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Usage](#usage)
- [Testing](#testing)
- [Contract Details](#contract-details)

## About

This implementation demonstrates a raffle contract using:
- **Solidity** ~0.8.0 for smart contract development
- **Foundry** (Forge) for compilation, testing, and deployment
- **Chainlink VRF V2 Plus** for provably random number generation
- **Chainlink Automation** for automated lottery draws

## Project Structure

```
foundry-raffle/
├── src/
│   ├── Raffle.sol                    # Main raffle contract
│   └── VRFv2PlusWrapperConsumer.sol  # VRF wrapper consumer base
│
├── script/
│   ├── 01_DeployRaffle.s.sol        # Deployment script
│   └── 02_EnterRaffle.s.sol         # Enter raffle script
│
├── test/                             # Test files (add your tests here)
│
├── lib/                              # Git submodules
│   ├── forge-std/                    # Foundry standard library
│   └── chainlink-brownie-contracts/  # Chainlink contracts
│
├── foundry.toml                      # Foundry configuration
├── foundry.lock                      # Dependency lock file
├── .gitmodules                       # Submodule configuration (at root)
├── .env.example                      # Environment variables template
└── README.md                         # This file
```

### Key Files

- **`src/Raffle.sol`**: Main raffle contract implementing ticket purchase, winner selection, and prize distribution
- **`script/01_DeployRaffle.s.sol`**: Script to deploy the contract to a network
- **`script/02_EnterRaffle.s.sol`**: Script to enter the raffle
- **`foundry.toml`**: Foundry configuration (compiler settings, RPC URLs, etc.)

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- Git (for submodule management)
- Access to an Ethereum RPC endpoint (e.g., Sepolia testnet)
- Private key for deployment (keep secure!)
- Etherscan API key (for contract verification)

## Installation

### 1. Clone the Repository

If you haven't already cloned the parent repository:

```bash
# Option 1: Clone with submodules recursively
git clone --recursive <repository-url>
cd raffle/foundry-raffle

# Option 2: Clone normally, then initialize submodules from root
git clone <repository-url>
cd raffle
git submodule update --init --recursive --depth 1
cd foundry-raffle
```

### 2. Install Dependencies

```bash
forge install
```

**Note**: This project uses git submodules for dependencies (`forge-std` and `chainlink-brownie-contracts`). The submodules are defined at the repository root level (in `../.gitmodules`). If you cloned without `--recursive`, make sure to run `git submodule update --init --recursive --depth 1` from the repository root before running `forge install`.

### 3. Verify Installation

```bash
forge build
```

If successful, you should see compilation output without errors.

## Configuration

### Environment Variables

1. Copy the example environment file:
```bash
cp .env.example .env
```

2. Edit `.env` with your actual values:
```bash
SEPOLIA_RPC_URL=your_sepolia_rpc_url
PRIVATE_KEY=your_private_key
ETHERSCAN_API_KEY=your_etherscan_api_key
```

**Security**: Never commit your `.env` file. It's already in `.gitignore`.

### Foundry Configuration

The `foundry.toml` file contains:
- Compiler settings (Solidity version, optimizer)
- RPC URL configuration (references `SEPOLIA_RPC_URL` from `.env`)
- Etherscan API configuration (for verification)

You can modify these settings as needed for your deployment target.

## Deployment

### Deploy to Sepolia Testnet

```bash
forge script script/01_DeployRaffle.s.sol:DeployRaffle --rpc-url sepolia --broadcast --verify
```

This will:
1. Compile the contract
2. Deploy to Sepolia

### Deployment Parameters

The deployment script uses:
- **Entrance Fee**: 0.01 ETH per ticket
- **VRF Wrapper**: Configured in the script (Sepolia VRF V2 Plus Wrapper)

You can modify these in `script/01_DeployRaffle.s.sol` if needed.

## Usage

### Enter the Raffle

```bash
forge script script/02_EnterRaffle.s.sol:EnterRaffle --rpc-url sepolia --broadcast
```

This script will purchase tickets using the account specified in your `PRIVATE_KEY`.

### Interact with the Contract

You can also interact with the deployed contract using Foundry's `cast` command or write custom scripts.

Example: Check current epoch
```bash
cast call <CONTRACT_ADDRESS> "getCurrentEpoch()" --rpc-url sepolia
```

## Contract Details

### Core Functionality

- **Ticket Purchase**: Users send ETH to `enterRaffle()` to purchase tickets
- **Epoch System**: Raffles run in 5-minute epochs
- **Automated Draws**: Chainlink Automation triggers winner selection
- **Random Selection**: Chainlink VRF provides provably random winner selection
- **Prize Distribution**: Winner receives entire contract balance

### Contract Parameters

- **Entrance Fee**: 0.01 ETH per ticket (configurable in constructor)
- **Interval**: 5 minutes per epoch (constant)
- **Network**: Sepolia Testnet (for testing)

### Key Functions

- `enterRaffle()`: Purchase tickets by sending ETH
- `checkUpkeep()`: Chainlink Automation checks if upkeep is needed
- `performUpkeep()`: Chainlink Automation triggers winner selection
- `getCurrentEpoch()`: View current epoch number
- `getTicketsInCurrentEpoch()`: View tickets purchased in current epoch

## Troubleshooting

### Submodule Issues

If dependencies are missing:
```bash
# From repository root
git submodule update --init --recursive --depth 1
cd foundry-raffle
forge install
```

### Compilation Errors

Ensure you have the correct Solidity version:
```bash
forge --version
```

Check `foundry.toml` for compiler settings.

### Deployment Issues

- Verify your `PRIVATE_KEY` has sufficient ETH for gas
- Check your `SEPOLIA_RPC_URL` is correct and accessible

## License

Unlicense

## Author

enochlee

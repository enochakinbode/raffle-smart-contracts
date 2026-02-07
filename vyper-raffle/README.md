# Raffle Contract - Vyper (Titanoboa)

A decentralized lottery/raffle smart contract built with **Vyper** and **Titanoboa**, using Chainlink VRF (Verifiable Random Function) for provably random winner selection and Chainlink Automation for automated lottery draws.

> This is the Vyper/Titanoboa implementation. For an overview of both implementations, see the [root README](../README.md).

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
- **Vyper** ^0.4.0 for smart contract development
- **Titanoboa** for testing and deployment
- **Python** for scripting and testing
- **Chainlink VRF V2 Plus** for provably random number generation
- **Chainlink Automation** for automated lottery draws

## Project Structure

```
vyper-raffle/
├── contracts/
│   └── Raffle.vy                    # Main raffle contract
│
├── interfaces/
│   └── VrfV2PlusWrapper.vyi         # VRF wrapper interface
│
├── libraries/
│   └── VRFV2PlusClient.vy           # VRF client library
│
├── scripts/
│   ├── deploy_raffle.py             # Deployment script
│   ├── enter_raffle.py              # Enter raffle script
│   ├── verify_raffle.py             # Etherscan verification script
│   └── helpers/
│       └── __init__.py              # Helper functions and config
│
├── tests/
│   ├── mocks/                       # Mock contracts for testing
│   │   ├── VRFRouter.vy
│   │   └── VRFWrapper.vy
│   └── units/                       # Unit tests
│       ├── conftest.py              # Pytest configuration
│       ├── test_raffle.py           # Raffle functionality tests
│       ├── test_raffle_upkeep.py    # Automation tests
│       └── test_raffle_with_vrf.py # VRF integration tests
│
├── pyproject.toml                   # Project configuration and dependencies
├── uv.lock                          # Dependency lock file
├── .env.example                      # Environment variables template
└── README.md                         # This file
```

### Key Files

- **`contracts/Raffle.vy`**: Main raffle contract implementing ticket purchase, winner selection, and prize distribution
- **`scripts/deploy_raffle.py`**: Python script to deploy the contract
- **`scripts/enter_raffle.py`**: Python script to enter the raffle
- **`scripts/verify_raffle.py`**: Python script to verify the contract on Etherscan
- **`pyproject.toml`**: Project dependencies and configuration

## Prerequisites

- Python 3.14+
- [uv](https://github.com/astral-sh/uv) package manager
- Access to an Ethereum RPC endpoint (e.g., Sepolia testnet)
- Private keys for deployment and testing (keep secure!)
- Etherscan API key (for contract verification)

## Installation

### 1. Clone the Repository

If you haven't already cloned the parent repository:

```bash
git clone <repository-url>
cd raffle/vyper-raffle
```

### 2. Install Dependencies

Install dependencies using `uv`:

```bash
uv sync
```

This will:
- Create a virtual environment
- Install all Python dependencies (including Titanoboa)
- Set up the project environment

### 3. Verify Installation

```bash
uv run python -c "import boa; print('Titanoboa installed successfully')"
```

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
PRIVATE_KEY_2=your_second_private_key  # For testing with multiple accounts
ETHERSCAN_API_KEY=your_etherscan_api_key
```

**Security**: Never commit your `.env` file. It's already in `.gitignore`.

### Project Configuration

The `pyproject.toml` file contains:
- Python dependencies (Titanoboa, pytest, etc.)
- Project metadata
- Build configuration

Contract-specific configuration (entrance fee, VRF wrapper address) is in `scripts/helpers/__init__.py`.

## Deployment

### Deploy to Sepolia Testnet

```bash
uv run python scripts/deploy_raffle.py
```

This will:
1. Compile the Vyper contract
2. Deploy to Sepolia
3. Save the deployed address to `broadcast/deployed_address.txt`

### Deployment Parameters

The deployment script uses configuration from `scripts/helpers/__init__.py`:
- **Entrance Fee**: 0.01 ETH per ticket
- **VRF Wrapper**: Sepolia VRF V2 Plus Wrapper address

You can modify these values in the helpers file if needed.

## Usage

### Enter the Raffle

```bash
uv run python scripts/enter_raffle.py
```

This script will:
- Read the deployed contract address from `broadcast/deployed_address.txt`
- Purchase tickets using two different accounts (PRIVATE_KEY and PRIVATE_KEY_2)
- Display the results

### Verify the Contract on Etherscan

```bash
uv run python scripts/verify_raffle.py
```

This will verify the contract on Etherscan using the deployed address and constructor arguments.

### Interact with the Contract

You can also interact with the deployed contract using Python:

```python
import boa
from scripts.helpers import rpc_url

boa.set_network_env(rpc_url)
raffle = boa.load_partial("contracts/Raffle.vy").at("<CONTRACT_ADDRESS>")

# Call contract functions
current_epoch = raffle.current_epoch()
tickets = raffle.total_tickets_in_current_epoch()
```

## Testing

Run the test suite:

```bash
uv run pytest tests/
```

Run with verbose output:

```bash
uv run pytest tests/ -v
```

Run specific test files:

```bash
uv run pytest tests/units/test_raffle.py
uv run pytest tests/units/test_raffle_upkeep.py
uv run pytest tests/units/test_raffle_with_vrf.py
```

### Test Structure

The test suite includes:
- **Unit Tests** (`test_raffle.py`): Core raffle functionality
- **Automation Tests** (`test_raffle_upkeep.py`): Chainlink Automation integration
- **VRF Tests** (`test_raffle_with_vrf.py`): VRF integration and randomness


## Contract Details

### Core Functionality

- **Ticket Purchase**: Users send ETH to `enter_raffle()` to purchase tickets (max 1000 per transaction)
- **Epoch System**: Raffles run in 5-minute epochs (300 seconds)
- **Automated Draws**: Chainlink Automation triggers winner selection via `performUpkeep()`
- **Random Selection**: Chainlink VRF provides provably random winner selection
- **Prize Distribution**: Winner receives entire contract balance

### Contract Parameters

- **Maximum Tickets per Purchase**: 1000 tickets
- **Default Interval**: 300 seconds (5 minutes)
- **Entrance Fee**: Configurable (default: 0.01 ETH)

### Key Functions

- `enter_raffle()`: Purchase tickets by sending ETH
- `checkUpkeep()`: Chainlink Automation checks if upkeep is needed
- `performUpkeep()`: Chainlink Automation triggers winner selection
- `rawFulfillRandomWords()`: VRF callback to receive randomness
- `current_epoch()`: View current epoch number
- `total_tickets_in_current_epoch()`: View tickets purchased in current epoch

## Troubleshooting

### Dependency Issues

If `uv sync` fails:
```bash
# Update uv
pip install --upgrade uv

# Try again
uv sync
```

### Compilation Errors

Ensure you have the correct Vyper version. Check `pyproject.toml` for Titanoboa version requirements.

### Deployment Issues

- Verify your `PRIVATE_KEY` has sufficient ETH for gas
- Check your `SEPOLIA_RPC_URL` is correct and accessible
- Ensure the contract address file exists: `broadcast/deployed_address.txt`

### Testing Issues

If tests fail:
- Ensure all dependencies are installed: `uv sync`
- Check that mock contracts are properly set up
- Verify your test network configuration

## License

Unlicense

## Author

enochakinbode

# Provably Random Raffle Contracts (Vyper)

> **📊 Comparison**: This is the Vyper implementation. For a side-by-side comparison with the Solidity implementation, see the [root README](../README.md).

A decentralized lottery/raffle smart contract built with Vyper that uses Chainlink VRF (Verifiable Random Function) for provably random winner selection and Chainlink Automation for automated lottery draws.

## Features

1. **Ticket Purchase**: Users can enter the raffle by paying for tickets. The ticket fees accumulate to form the prize pool that the winner receives.
2. **Automated Draws**: The lottery automatically and programmatically draws a winner after a configurable time interval (default: 5 minutes).
3. **Provably Random**: Chainlink VRF V2 Plus generates cryptographically verifiable random numbers for fair winner selection.
4. **Chainlink Automation**: Chainlink Automation triggers the lottery draw regularly without manual intervention.

## Technology Stack

- **Vyper**: Smart contract language
- **Titanoboa**: Vyper testing and deployment framework
- **Chainlink VRF V2 Plus**: For provably random number generation
- **Chainlink Automation**: For automated lottery draws
- **Python**: For testing and deployment scripts

## Contract Details

- **Maximum Tickets per Purchase**: 1000 tickets
- **Default Interval**: 300 seconds (5 minutes)
- **Entrance Fee**: Configurable (default: 0.01 ETH)

## Prerequisites

- Python 3.14+
- [uv](https://github.com/astral-sh/uv) package manager
- Access to an Ethereum RPC endpoint (e.g., Sepolia testnet)
- Private keys for deployment and testing
- Etherscan API key (for contract verification)

## Installation

1. Clone the repository (if you haven't already):
```bash
git clone <repository-url>
cd raffle/vyper-raffle
```

2. Install dependencies using `uv`:
```bash
uv sync
```

3. Copy `.env.example` to `.env` and fill in your values:
```bash
cp .env.example .env
```

Then edit `.env` with your actual values:
- `SEPOLIA_RPC_URL`: Your Ethereum RPC endpoint
- `PRIVATE_KEY`: Your deployment account private key
- `PRIVATE_KEY_2`: A second account private key (for testing)
- `ETHERSCAN_API_KEY`: Your Etherscan API key (for contract verification)

## Usage

### Deploy the Contract

```bash
uv run python scripts/deploy_raffle.py
```

The deployed contract address will be saved to `broadcast/deployed_address.txt`.

### Enter the Raffle

```bash
uv run python scripts/enter_raffle.py
```

This script will purchase tickets using two different accounts.

### Verify the Contract on Etherscan

```bash
uv run python scripts/verify_raffle.py
```

## Testing

Run the test suite:

```bash
uv run pytest tests/
```

The project includes:
- Unit tests for raffle functionality
- Tests for Chainlink Automation integration
- Tests for VRF integration
- Property-based tests using Hypothesis

## Project Structure

```
vyper-raffle/
├── contracts/
│   └── Raffle.vy              # Main raffle contract
├── interfaces/
│   └── VrfV2PlusWrapper.vyi   # VRF wrapper interface
├── libraries/
│   └── VRFV2PlusClient.vy     # VRF client library
├── scripts/
│   ├── deploy_raffle.py       # Deployment script
│   ├── enter_raffle.py        # Enter raffle script
│   ├── verify_raffle.py       # Etherscan verification script
│   └── helpers/               # Helper functions and config
├── tests/
│   ├── mocks/                 # Mock contracts for testing
│   └── units/                 # Unit tests
└── pyproject.toml             # Project configuration
```

## Security Considerations

- Never commit your `.env` file or private keys
- Always test on testnets before mainnet deployment
- Review the contract code thoroughly before deploying
- Ensure sufficient LINK tokens for Chainlink services

## License

Unlicense

## Author

enochlee

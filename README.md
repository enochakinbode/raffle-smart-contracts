# Raffle Contract: Solidity and Vyper

This repository contains two implementations of a provably random raffle/lottery smart contract - one written in **Solidity** using **Foundry** and one written in **Vyper** using **Titanoboa**. Both contracts implement the same functionality using Chainlink VRF V2 Plus for randomness and Chainlink Automation for automated draws.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Implementation Comparison](#implementation-comparison)
- [Getting Started](#getting-started)
- [Contract Details](#contract-details)
- [License](#license)

## 🎯 Overview

Both implementations provide:
- **Ticket Purchase System**: Users can buy multiple tickets by sending ETH
- **Automated Draws**: Chainlink Automation triggers winner selection after a time interval
- **Provably Random Selection**: Chainlink VRF V2 Plus ensures fair, verifiable randomness
- **Epoch-based System**: Raffles run in epochs (default: 5 minutes)
- **Automatic Prize Distribution**: Winners receive the entire contract balance

## ✨ Features

1. **Multiple Ticket Purchase**: Buy multiple tickets in a single transaction
2. **Excess ETH Refund**: Automatically refunds excess ETH if sent amount isn't a multiple of ticket price
3. **Epoch Management**: Automatic epoch transitions with skipped epoch handling
4. **Chainlink Integration**: 
   - VRF V2 Plus for provably random number generation
   - Automation for scheduled upkeep execution
5. **Gas Optimization**: Both implementations focus on efficient gas usage

## 📁 Project Structure

```
raffle/
├── foundry-raffle/          # Solidity implementation (Foundry)
│   ├── src/                 # Solidity source files
│   ├── script/              # Deployment scripts
│   ├── test/                # Test files
│   ├── lib/                 # Git submodules (forge-std, chainlink-brownie-contracts)
│   ├── .gitmodules          # Submodule configuration
│   └── README.md            # Solidity-specific documentation
│
├── vyper-raffle/            # Vyper implementation (Titanoboa)
│   ├── contracts/           # Vyper source files
│   ├── interfaces/          # Interface definitions
│   ├── libraries/           # Library code
│   ├── scripts/             # Python deployment scripts
│   ├── tests/               # Test files
│   └── README.md            # Vyper-specific documentation
│
└── README.md                # This file (comparison overview)
```

### Git Submodules

The `foundry-raffle` directory uses git submodules for dependencies:
- `foundry-raffle/lib/forge-std` - Foundry standard library
- `foundry-raffle/lib/chainlink-brownie-contracts` - Chainlink contracts

**How it works**: Git submodules are defined at the root of the repository (in `.gitmodules`), even though the submodule directories are nested inside `foundry-raffle/`. When you clone the repository, git automatically recognizes and initializes these submodules based on the root `.gitmodules` file.

When cloning the repository, use:
```bash
git clone --recursive <repository-url>
```

Or initialize submodules after cloning:
```bash
git clone <repository-url>
cd raffle
git submodule update --init --recursive
```

The `forge install` command (run from `foundry-raffle/`) will also automatically handle submodule initialization.

## 🔍 Implementation Comparison

### Language & Framework

| Aspect | Solidity | Vyper |
|--------|----------|-------|
| **Language** | Solidity ~0.8.0 | Vyper ^0.4.0 |
| **Framework** | Foundry (Forge) | Titanoboa |
| **Testing** | Solidity tests (Forge) | Python tests (pytest) |
| **Deployment** | Foundry scripts | Python scripts |

### Code Structure

#### Solidity (`foundry-raffle/src/Raffle.sol`)
- Uses inheritance: `VRFv2PlusWrapperConsumer` and `AutomationCompatible`
- Custom errors for gas efficiency
- State variables with `s_` prefix for storage, `i_` for immutable
- Internal callback function `onRandomWordsFulfilled()`

#### Vyper (`vyper-raffle/contracts/Raffle.vy`)
- Direct implementation without inheritance
- Uses `assert` statements for validation
- Public state variables with explicit visibility
- External callback function `rawFulfillRandomWords()`

### Key Differences

| Feature | Solidity | Vyper |
|---------|----------|-------|
| **Error Handling** | Custom errors (`error Raffle__NotEnoughEthSent()`) | Assert statements with messages |
| **State Visibility** | Private with getter functions | Public state variables |
| **VRF Integration** | Inherits from wrapper consumer | Direct interface calls |
| **Automation** | Inherits `AutomationCompatible` | Implements interface directly |
| **Ticket Limit** | No explicit limit | `MAX_TICKETS = 1000` per purchase |
| **Gas Optimization** | Custom errors, immutable variables | Direct state access, minimal overhead |

### Gas Considerations

**Solidity Advantages:**
- Custom errors save gas compared to revert strings
- Immutable variables are cheaper than storage
- Inheritance allows code reuse

**Vyper Advantages:**
- Simpler syntax can lead to smaller bytecode
- Direct state variable access (no getter functions needed)
- Built-in bounds checking

### Code Size Comparison

Both implementations are similar in functionality, but:
- **Solidity**: ~206 lines (with inheritance)
- **Vyper**: ~174 lines (self-contained)

### Development Experience

**Solidity (Foundry):**
- ✅ Mature ecosystem and tooling
- ✅ Extensive documentation
- ✅ Large community support
- ✅ Type safety with Solidity 0.8+

**Vyper (Titanoboa):**
- ✅ Python-like syntax (easier for Python developers)
- ✅ Explicit and readable code
- ✅ Built-in security features
- ✅ Smaller learning curve for Python developers

## 🚀 Getting Started

### Prerequisites

**For Solidity (Foundry):**
- [Foundry](https://book.getfoundry.sh/getting-started/installation) - Development framework for Solidity
- Git (for submodule management)
- Node.js (for dependencies)

**For Vyper (Titanoboa):**
- Python 3.14+
- [Titanoboa](https://github.com/vyperlang/titanoboa) - Vyper testing and deployment framework
- [uv](https://github.com/astral-sh/uv) package manager

**Common:**
- Access to Ethereum RPC endpoint (e.g., Sepolia testnet)
- Private keys for deployment
- Etherscan API key (for verification)
- LINK tokens for Chainlink services

### Quick Start

#### Solidity Implementation (Foundry)

```bash
# If you cloned without --recursive, initialize submodules from the root:
git submodule update --init --recursive

cd foundry-raffle
# Or use forge install to set up dependencies (handles submodules automatically)
forge install
forge script script/01_DeployRaffle.s.sol:DeployRaffle --rpc-url sepolia --broadcast --verify
```

**Note**: Git submodules are defined at the repository root. If you cloned without `--recursive`, run `git submodule update --init --recursive` from the root directory. The `forge install` command will also handle submodule initialization automatically.

See [foundry-raffle/README.md](./foundry-raffle/README.md) for detailed instructions.

#### Vyper Implementation (Titanoboa)

```bash
cd vyper-raffle
uv sync
uv run python scripts/deploy_raffle.py
```

See [vyper-raffle/README.md](./vyper-raffle/README.md) for detailed instructions.

## 📊 Contract Details

Both implementations share these characteristics:

- **Entrance Fee**: Configurable (default: 0.01 ETH per ticket)
- **Interval**: 5 minutes per epoch
- **Network**: Sepolia Testnet (for testing)
- **VRF**: Chainlink VRF V2 Plus with native payment
- **Automation**: Chainlink Automation for upkeep

### Differences

| Parameter | Solidity | Vyper |
|-----------|----------|-------|
| Max Tickets per Purchase | Unlimited | 1000 |
| Ticket Storage | `mapping(epoch => mapping(ticketId => address))` | `HashMap[uint256, HashMap[uint256, address]]` |
| Epoch Skipping | Handled in `performUpkeep` | Handled in `performUpkeep` |

## 🔐 Security Considerations

Both implementations follow security best practices:

- ✅ Reentrancy protection through state checks
- ✅ Access control for VRF callbacks
- ✅ Input validation (ticket count, ETH amount)
- ✅ Safe ETH transfers with proper error handling
- ✅ Epoch state management to prevent double execution

**Note**: Always audit contracts before mainnet deployment and test thoroughly on testnets.

## 📝 Testing

### Solidity Tests (Foundry)
```bash
cd foundry-raffle
forge test
```

### Vyper Tests (Titanoboa/pytest)
```bash
cd vyper-raffle
uv run pytest tests/
```

## 🤝 Contributing

This is a comparison repository. Both implementations are maintained separately:
- Solidity implementation (Foundry): `foundry-raffle/`
- Vyper implementation (Titanoboa): `vyper-raffle/`

## 📄 License

Unlicense - see individual project directories for license details.

## 👤 Author

enochlee

---

## 💡 Which Should You Choose?

**Choose Solidity if:**
- You're building in the Ethereum ecosystem (most common)
- You need extensive library support
- Your team is familiar with Solidity
- You want maximum ecosystem compatibility

**Choose Vyper if:**
- You're a Python developer
- You prefer explicit, readable code
- You want a simpler language with built-in safety features
- You're building specialized contracts where bytecode size matters

Both implementations are production-ready and achieve the same functionality. The choice often comes down to team preference, ecosystem requirements, and specific project needs.


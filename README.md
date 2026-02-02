# Raffle Contract: Implementation in Solidity and Vyper

This repository is an exploration of implementing a provably random raffle/lottery smart contract using two different approaches:

- **Solidity** with **Foundry** - The most popular smart contract language and development framework
- **Vyper** with **Titanoboa** - A Python-like language with a modern testing and deployment framework

Both implementations demonstrate the same functionality: a decentralized raffle system using Chainlink VRF V2 Plus for provably random winner selection and Chainlink Automation for automated draws.

## 🎯 Purpose

This project serves as an experiment and educational resource to:

- Explore how the same smart contract logic can be implemented in different languages
- Compare development experiences between Solidity/Foundry and Vyper/Titanoboa
- Demonstrate Chainlink VRF and Automation integration in both ecosystems
- Provide working examples for developers learning either language

## 🚀 Quick Start

### Clone the Repository

```bash
# Clone with submodules (required for Foundry dependencies)
git clone --recursive https://github.com/enochakinbode/raffle-smart-contracts
cd raffle
```

Or if you already cloned without `--recursive`:

```bash
git submodule update --init --recursive --depth 1
```

### Explore the Implementations

**Solidity (Foundry):**
```bash
cd foundry-raffle
# See foundry-raffle/README.md for detailed setup
```

**Vyper (Titanoboa):**
```bash
cd vyper-raffle
# See vyper-raffle/README.md for detailed setup
```

## 📁 Repository Structure

```
raffle/
├── foundry-raffle/          # Solidity implementation using Foundry
│   └── README.md            # Detailed setup and project structure
│
├── vyper-raffle/            # Vyper implementation using Titanoboa
│   └── README.md            # Detailed setup and project structure
│
└── README.md                # This file (overview)
```

## 🔧 What You'll Find

Both implementations include:

- **Smart Contract**: A raffle contract with ticket purchasing and automated winner selection
- **Chainlink Integration**: 
  - VRF V2 Plus for provably random number generation
  - Automation for scheduled upkeep execution
- **Deployment Scripts**: Ready-to-use scripts for deploying to testnets
- **Tests**: Comprehensive test suites for each implementation
- **Documentation**: Detailed setup instructions in each subdirectory

## 🎓 Learning Resources

- **Foundry Documentation**: https://book.getfoundry.sh/
- **Titanoboa Documentation**: https://github.com/vyperlang/titanoboa
- **Chainlink VRF**: https://docs.chain.link/vrf
- **Chainlink Automation**: https://docs.chain.link/chainlink-automation

## 📊 Key Differences in Approach

| Aspect | Solidity (Foundry) | Vyper (Titanoboa) |
|--------|-------------------|-------------------|
| **Language** | Solidity ~0.8.0 | Vyper ^0.4.0 |
| **Framework** | Foundry (Forge) | Titanoboa |
| **Testing** | Solidity tests | Python tests (pytest) |
| **Deployment** | Foundry scripts | Python scripts |
| **Code Style** | Inheritance-based | Direct implementation |

## 🔐 Security Note

Both implementations follow security best practices, but this is experimental/educational code. Always audit contracts thoroughly before deploying to mainnet.

## 📄 License

Unlicense - see individual project directories for details.

## 👤 Author

enochlee

---

**Note**: This is an experimental repository demonstrating different approaches to the same problem. Each implementation is self-contained with its own setup instructions in the respective subdirectories.

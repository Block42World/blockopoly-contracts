![Block42](http://assets.block42.world/images/icons/block42_logo_200.png)

-----------------------

# Blockopoly World and Land Token Contracts

- Using [OpenZeppelin 1.11.0](https://github.com/OpenZeppelin/openzeppelin-solidity) framework for best security and stability
- Token is ERC721 non-fungible token standard
- Using lateset [Solidity 0.4.24](http://solidity.readthedocs.io/en/v0.4.24/) at the time of writing
- Using [async/awake](https://truffleframework.com/docs/getting_started/javascript-tests#using-async-await) and [Chai](http://www.chaijs.com/api/bdd/) for clean and readable test code
- Flattened scripts using [truffle-flattener](https://github.com/alcuadrado/truffle-flattener), for deploying to [Remix](http://remix.ethereum.org) without using truffle

## What's Block42 World
A world is a separated planet, which having number of lands. In Block42 universe, there can be unlimited number of parallel worlds (capped by `uint32`, i.e. 4.3B, but is way enough). A world is an ERC721 token which can be owned. The owner of first few worlds will be us, and we will give / sell the ownership of world to anyone who are passionate to contribute to Block42 community.

## What's Block42 Land
In each world, there's a number of lands. Each land is also an ERC721 token. World creators can create arbitrary number of lands, given the x, y positions, width and height of the land. Positions are capped to be within +/- 1T. Width and height should be under 65k and must be a odd number, to avoid using floating numbers. Lands should not be overlapping each other. A land's `uint256` token ID is encoded from `(worldId, x, y)` and should always be unique. After world creator creating the new land, he can give / sell to anymore. The land owner then can construct voxel buildings and decorations in his own land, using our web app or standalone client. A voting and rewarding system may be introduced in later stage, for incentivizing players who build good content in their lands, as well as prohibiting illegal content.

## Getting Started

### Requirements
- [Node.js 10.7.x](https://nodejs.org/en/download/current/)
- [truffle](https://github.com/trufflesuite/truffle) `npm install -g truffle`
- [ganache-cli](https://github.com/trufflesuite/ganache-cli) `npm install -g ganache-cli`
- [truffle-flattener](https://www.npmjs.com/package/truffle-flattener) `npm install -g truffle-flattener` (Optional)

### Install dependencies
`npm i`

### Start Ganache CLI to run a local private blockchain, or use GUI [Ganache](https://truffleframework.com/ganache)
`ganache-cli`

### Compile the contracts
`truffle compile`

### Deploy contracts to the local environment
`truffle migrate`

### Run test
`truffle test`

## Create flattened scripts (Optional to deploy at Remix)
```sh
truffle-flattener contracts/World.sol > contracts_flattened/World.sol
truffle-flattener contracts/Land.sol > contracts_flattened/Land.sol
```

### Contract Address
<!-- ## Mainnet -->
<!-- - [World.sol](contracts_flattened/World.sol): [0x9a62d3825e07342568a34aa31aad38bb04250806](https://etherscan.io/address/0x9a62d3825e07342568a34aa31aad38bb04250806) -->
<!-- - [Land.sol](contracts_flattened/Land.sol): [0xea9Be48045942fFB578e1E295e5401e86CBA8e8c](https://etherscan.io/address/0xea9Be48045942fFB578e1E295e5401e86CBA8e8c) -->
<!-- ## Ropsten -->
<!-- - [World.sol](contracts_flattened/World.sol): [0xb4fddd37602b03fa086c42bfa7b9739be38682c3](https://ropsten.etherscan.io/address/0xb4fddd37602b03fa086c42bfa7b9739be38682c3) -->
<!-- - [Land.sol](contracts_flattened/Land.sol): [0x382b3d898ccfa4ae5cb7375491bb771107e21b61](https://ropsten.etherscan.io/address/0x382b3d898ccfa4ae5cb7375491bb771107e21b61) -->
## Kovan
- [World.sol](contracts_flattened/World.sol): [0x59c1f440e53509e29915e2ddcc3b9cafab77179a](https://kovan.etherscan.io/address/0x59c1f440e53509e29915e2ddcc3b9cafab77179a)
- [Land.sol](contracts_flattened/Land.sol): [0xa2b3f2f1ffb050e93807244bcd94886d2b6556ca](https://kovan.etherscan.io/address/0xa2b3f2f1ffb050e93807244bcd94886d2b6556ca)

## TODO
- Complete all test cases
- Add Travis CI badge
[![Build Status](https://img.shields.io/travis/Block42World/land-contracts.svg?branch=master&style=flat-square)](https://travis-ci.org/Block42World/land-contracts)
- Add CoverAlls badge
[![Coverage Status](https://img.shields.io/coveralls/github/Block42World/land-contracts/master.svg?style=flat-square)](https://coveralls.io/github/Block42World/land-contracts?branch=master)
- Add maketplace

## License
Code released under the [MIT License](LICENSE).

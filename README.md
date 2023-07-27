![Screenshot 2023-07-06 at 11 22 17](https://github.com/Peter-Paul/ocean-nft/assets/35074712/1d80107a-2fab-45af-a7f3-e7945e3915a0)

# Neptune's Garden  
Welcome to a haven of beauty where the best scholars and wizards - united from a shared belief in decentralization and open data - meet each others to collaborate and advance public goods for Web3 and decentralised AI 🌊 ☀️

[Official Website](https://neptunelabs.ai/)<br>
[Official Twitter](https://twitter.com/neptunelabsai)<br>
Official Collection Coming Soon

## Introduction
This is the standard Hardhat implementation of ERC6551 used for deploying The Neptune Garden NFT project.

What is implemented in this NFT?
- Total NFTs = 8623 [Can be increased if needed]
- 1 WL allows for 3 mints
- First mint is free. Other 2 mints cost 0.05ETH each

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
```
## Founding Partners
[Algovera](https://twitter.com/AlgoveraAI)<br>
[Bacalhau](https://twitter.com/BacalhauProject)<br>
[Gitcoin](https://twitter.com/gitcoin)<br>
[Polygon](https://twitter.com/0xPolygonLabs)<br>
[Protocol Labs](https://twitter.com/protocollabs)<br>
[Ocean Protocol](https://twitter.com/oceanprotocol)<br>
[Open Data Community](https://twitter.com/OpenDataforWeb3)

## Here is a brief overview of the contract's functionalities:

1. Token Minting and Ownership:

The contract allows users to mint ERC-721 tokens named "NeptuneGarden" with the symbol "NG".
The tokens are minted using the safeMint function, which requires users to pay a price (MINT_PRICE) in ether to mint a token. However, the owner can mint up to a certain number of tokens for free (FREE_NFT).
There are limits on the number of tokens that can be minted per wallet (WALLET_LIMIT) and through the auction (AUCTION_LIMIT).

2. Staking Mechanism:

Users can stake their tokens using the `stake` function. Staking a token associates it with a Token Bound Account (TBA) using the `showTBA` function from the `IERC6551Registry` contract.
Tokens that are staked cannot be transferred or burned while staked, and there is a limit on the number of tokens a user can stake (WALLET_LIMIT).

3 .Unstaking Tokens:

Users can unstake their staked tokens using the `unstake` function. This process allows them to retrieve any accumulated rewards (pearls) that they have earned while the token was staked.

4. Pearl Rewards:

The contract calculates "pearl" rewards for stakers based on the time the token has been staked. Pearls are rewarded per minute, with a rate defined by the pearlsPerMinute variable.
Users can view their available rewards using the availableRewards function.

5. Auction:

The contract has an auction system that can be activated and deactivated by the contract owner using the `activateAuction` and `deactivateAuction` functions.
While the auction is active, users can only mint a limited number of tokens through the auction (AUCTION_LIMIT).

6. Pausing Functionality:

The contract can be paused and unpaused by the owner using the `pause` and `unpause` functions, respectively.

7. Ownership and Withdrawal:

The contract owner can withdraw any ether balance in the contract using the `withdraw` function.
The contract owner can set the mint price using the `setMintPrice` function.

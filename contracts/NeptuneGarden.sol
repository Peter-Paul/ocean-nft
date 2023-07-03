// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./interfaces/IERC6551Registry.sol";

contract NeptuneGarden is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable {
     // ===== 1. Property Variables ===== //
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 public MINT_PRICE = 0.05 ether;
    uint public MAX_SUPPLY = 8623;
    uint public MAX_SUPPLY_PER_WALLET = 3;
    uint public FREE_NFT = 1;
    IERC6551Registry public NeptuneAccountRegistry;

    // ===== 2. Lifecycle Methods ===== //

    constructor(address _neptuneAccountRegistry) ERC721("NeptuneGarden", "NG") {
        // Start token ID at 1. By default is starts at 0.
        _tokenIdCounter.increment();
        NeptuneAccountRegistry = IERC6551Registry(_neptuneAccountRegistry);
    }

     function withdraw() public onlyOwner() {
        require(address(this).balance > 0, "Balance is zero");
        payable(owner()).transfer(address(this).balance);
    }

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        MINT_PRICE = _mintPrice;
    }


    // ===== 3. Pauseable Functions ===== //

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // ===== 4. Minting Functions ===== //

    function safeMint(address to, string memory uri) public payable {
        uint256 tokenId = _tokenIdCounter.current();
        uint walletBalance = balanceOf(msg.sender);
        if(walletBalance >= FREE_NFT){
            require(msg.value >= MINT_PRICE, "Sorry, amount less than mint price!");
        }
        require(walletBalance < MAX_SUPPLY_PER_WALLET, "Sorry, mint limit for wallet reached!");
        require(tokenId <= MAX_SUPPLY, "Sorry, all NFTs have been minted!");
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        NeptuneAccountRegistry.createAccount(address(this), tokenId); // creates token bound account TBA for tokenId
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId,uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable,ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
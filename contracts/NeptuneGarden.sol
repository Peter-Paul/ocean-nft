// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./interfaces/IERC6551Registry.sol";
import "./interfaces/IERC6551Account.sol";

contract NeptuneGarden is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable {

    // Events
    event ActivatedAuction(address account);
    event DeactivatedAuction(address account);

    // ===== 1. Property Variables ===== //
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 public MINT_PRICE = 0.05 ether;
    uint public MAX_SUPPLY = 8623;
    uint public WALLET_LIMIT = 3;
    uint public AUCTION_LIMIT = 1;
    uint public FREE_NFT = 1;
    IERC6551Registry public NeptuneAccountRegistry;
    address public NeptuneImplementation;
    uint immutable public salt = 0;
    bool private _auctioned;
    mapping(address => uint) _minted;

    // ===== 2. Lifecycle Methods ===== //

    constructor(address _neptuneAccountRegistry,address _neptuneImplementation) ERC721("NeptuneGarden", "NG") {
        // Start token ID at 1. By default is starts at 0.
        _tokenIdCounter.increment();
        NeptuneAccountRegistry = IERC6551Registry(_neptuneAccountRegistry);
        NeptuneImplementation = _neptuneImplementation;
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

    // ===== 3. Auction Functions ===== //

    function auctioned() external view virtual returns (bool) {
        return _auctioned;
    }
    
    function activateAuction() external onlyOwner {
        _auctioned = true;
        emit ActivatedAuction(msg.sender);
    }

    function deactivateAuction() external onlyOwner {
        _auctioned = false;
        emit ActivatedAuction(msg.sender);
    }

    // ===== 5. Minting Functions ===== //

    function safeMint(address to, string memory uri) public payable whenNotPaused() {
        uint256 tokenId = _tokenIdCounter.current();
        address _account = msg.sender;
        uint walletBalance = _minted[_account];
        if(walletBalance >= FREE_NFT){
            require(msg.value >= MINT_PRICE, "Sorry, amount less than mint price!");
        }
        if(_auctioned){
            require(walletBalance < AUCTION_LIMIT, "Sorry, auction limit reached!");
        }
        require(walletBalance < WALLET_LIMIT, "Sorry, wallet limit reached!");
        require(tokenId <= MAX_SUPPLY, "Sorry, all NFTs have been minted!");
        _tokenIdCounter.increment();
        _minted[_account] += 1;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        NeptuneAccountRegistry.createAccount(
            NeptuneImplementation,
            block.chainid,
            address(this), 
            tokenId,
            salt,
            abi.encodeWithSignature("initialize()", msg.sender)
        ); // creates token bound account TBA for tokenId
    }

    function minted(address _account) external view returns(uint){
        return _minted[_account];
    }


    // ===== 6. Token Bound Account Functions ===== //

    function showTBA(uint256 _tokenId) external view returns (address) {
        return NeptuneAccountRegistry.account(
                    NeptuneImplementation,
                    block.chainid,
                    address(this),
                    _tokenId,
                    salt
                );
    }

    function showTBAOwner(address payable _tba) external view returns (address) {
        return IERC6551Account(_tba).owner();
    }

    function showTBAInfo(address payable _tba) external view returns (uint256 chainId,address tokenContract,uint256 tokenId) {
        return IERC6551Account(_tba).token();
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
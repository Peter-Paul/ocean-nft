// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./interfaces/IERC6551Registry.sol";
import "./interfaces/IERC6551Account.sol";

contract NeptuneGarden is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable, ReentrancyGuard {
    // ===== 1. Structs ===== //
    struct Staker {
        uint256 timeOfLastUpdate;
        uint256 unclaimedPearls;
    }

    // ===== 2. Events ===== //
    event ActivatedAuction(address account);
    event DeactivatedAuction(address account);
    event Staked(address account,address TBA,uint256 tokenId);
    event Unstaked(address account,address TBA,uint256 tokenId);

    // ===== 3. Property Variables ===== //
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
    mapping(address => Staker) public stakers;
    mapping(uint256 => address) public stakerAddress;
    mapping(address => uint256) public staked;
    mapping(uint256 => bool) public _isStaked;
    uint256 constant SECONDS_IN_MINUTE = 60;
    uint256 private pearlsPerMinute = 1;

    // ===== 4. Modifiers ===== //

    modifier notStaked(uint256 _tokenId){
        require(_isStaked[_tokenId] == false, "Token is staked");
        _;
    }

    modifier isStaked(uint256 _tokenId){
        require(_isStaked[_tokenId] == true, "Token is not staked");
        _;
    }

    // ===== 5. Lifecycle Methods ===== //

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


    // ===== 6. Pauseable Functions ===== //

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // ===== 7. Auction Functions ===== //

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

    // ===== 8. Minting Functions ===== //

    function safeMint(address to, string memory uri) public payable whenNotPaused {
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


    // ===== 9. Token Bound Account Functions ===== //

    function showTBA(uint256 _tokenId) public view returns (address) {
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

    // ===== 10. Staking Functions ===== //

    function stake(uint256 _tokenId) external whenNotPaused {
        address user = msg.sender;
        require(ownerOf(_tokenId) == user, "Can't stake tokens you don't own!");
        require(staked[user] <  WALLET_LIMIT, "Sorry, stake limit reached!" );
        address TBA = showTBA(_tokenId);
        Staker storage staker = stakers[TBA];
        staker.timeOfLastUpdate = block.timestamp;
        staked[user]+=1;
        stakerAddress[_tokenId] = user;
        _isStaked[_tokenId] = true;
        emit Staked(user,TBA,_tokenId);
    }

    function unstake(uint256 _tokenId) external nonReentrant {
        address user = msg.sender;
        require(staked[user] > 0, "You have no tokens staked!");
        require(stakerAddress[_tokenId] == user, "You did not stake this token!");
        address TBA = showTBA(_tokenId);
        updatePearls(TBA);
        _isStaked[_tokenId] = false;
        staked[user]-=1;
        delete stakerAddress[_tokenId];
        emit Unstaked(user,TBA,_tokenId);
    }

    function stakeInfo(uint256 _tokenId)
        public
        isStaked(_tokenId)
        view
        returns (uint256 _availableRewards)
    {
        address TBA = showTBA(_tokenId);
        return availableRewards(TBA);
    }

    // ---- Internal Staking functions ---- //
    function calculatePearls(address _staker) internal view returns (uint256 _rewards) {
        Staker memory staker = stakers[_staker];
        return (
            (((block.timestamp - staker.timeOfLastUpdate)) * pearlsPerMinute)
                / SECONDS_IN_MINUTE
        );
    }

    function updatePearls(address _staker) internal {
        Staker storage staker = stakers[_staker];

        staker.unclaimedPearls += calculatePearls(_staker);
        staker.timeOfLastUpdate = block.timestamp;
    }

    function availableRewards(address _TBA) internal view returns (uint256 _rewards) {
        Staker memory staker = stakers[_TBA];
        _rewards = staker.unclaimedPearls + calculatePearls(_TBA);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId,uint256 batchSize)
        internal
        notStaked(tokenId)
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal notStaked(tokenId) override(ERC721, ERC721URIStorage) {
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
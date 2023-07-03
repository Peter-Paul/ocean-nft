// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC6551Registry {
    /// @dev The registry SHALL emit the AccountCreated event upon successful account creation
    event AccountCreated(
        address account,
        address tokenContract,
        uint256 tokenId
    );

    /// @dev Creates a token bound account for an ERC-721 token.
    ///
    /// If account has already been created, returns the account address without calling create2.
    ///
    /// If initData is not empty and account has not yet been created, calls account with
    /// provided initData after creation.
    ///
    /// Emits AccountCreated event.
    ///
    /// @return the address of the account
    function createAccount(
        address tokenContract,
        uint256 tokenId
    ) external returns (address);

    /// @dev Returns the computed address of a token bound account
    ///
    /// @return The computed address of the account
    function account(
        address tokenContract,
        uint256 tokenId
    ) external view returns (address);
}
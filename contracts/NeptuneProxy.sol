// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";

contract NeptuneProxy is Proxy, ERC1967Upgrade {
    address immutable defaultImplementation;

    constructor(address _defaultImplementation) {
        defaultImplementation = _defaultImplementation;
    }

    function initialize() external {
        address implementation = ERC1967Upgrade._getImplementation();

        if (implementation == address(0)) {
            ERC1967Upgrade._upgradeTo(defaultImplementation);
        }
    }

    function _implementation() internal view override returns (address) {
        return ERC1967Upgrade._getImplementation();
    }
}
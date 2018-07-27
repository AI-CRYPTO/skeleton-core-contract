pragma solidity ^0.4.23;

import "./AssetProxy.sol";
import "./Asset.sol";

import "./Signiture.sol";

contract Model is AssetProxy, Signiture {

    uint256 public assetId;

    string private scrypt;

    /**
     * @dev Constructor for this contract.
     */
    constructor(
        Asset _asset,
        string _scrypt
    ) 
        public 
        AssetProxy(_asset)
    {
        assetId = _asset.register(msg.sender, MODEL);

        scrypt = _scrypt;
    }
}
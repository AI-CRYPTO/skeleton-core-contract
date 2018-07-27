pragma solidity ^0.4.23;

import "./AssetProxy.sol";
import "./Asset.sol";

import "./Signiture.sol";

contract Trained is AssetProxy, Signiture {

    /**
     * @dev Constructor for this contract.
     */
    constructor(
        Asset _asset
    ) 
        public 
        AssetProxy(_asset)
    {
        assetId = _asset.register(msg.sender, TRAINED);
    }
}
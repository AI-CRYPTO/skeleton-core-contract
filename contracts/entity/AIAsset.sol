pragma solidity ^0.4.23;

import "./Asset.sol";

contract AIAsset is Asset {

    string public constant NAME = "AIASSET";
    string public constant SYMBOL = "AIA";

    /**
     * @dev Constructor for this contract.
     */
    constructor() 
        public
        Asset(NAME, SYMBOL)
    {
    }
}
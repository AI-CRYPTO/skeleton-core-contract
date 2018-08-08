pragma solidity ^0.4.23;

import "./AssetProxy.sol";
import "./Asset.sol";

import "./Storeable.sol";

import "./Signiture.sol";

contract Dataset is AssetProxy, Storeable, Signiture {

    enum SubClass {
        TextLineDataset,
        TFRecordDataset,
        FixedLengthRecordDataset
    }

    bytes[] public sepalLengthVaules;
    bytes[] public sepalWidthValue;
    bytes[] public petalLengthValus;
    bytes[] public petalWidthValus;

    SubClass public subClass;

    /**
     * @dev Constructor for this contract.
     */
    constructor(
        Asset _asset,
        string _url,
        string _fileName
    ) 
        public 
        AssetProxy(_asset, DATASET)
    {
        stored = Storage(_url);
        file = FileMeta(_fileName);
        subClass = SubClass.TextLineDataset;
    }

}


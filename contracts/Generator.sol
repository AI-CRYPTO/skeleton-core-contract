pragma solidity ^0.4.23;

import "./entity/Asset.sol";

import "./entity/Dataset.sol";
import "./entity/Model.sol";
import "./entity/Storeable.sol";

import "./Component.sol";

contract Generator is Component {

    event GeneratedDataset(Dataset _dataset);
    event GeneratedModel(Model _model);

    Asset public asset;
    address[] public created;

    constructor(Asset _asset) public {asset = _asset;}


    function generateData(string url, string fileName) 
        external 
        returns (bool)
    {
        Dataset data = new Dataset(asset, url, fileName);
        created.push(data);

        emit GeneratedDataset(data);
        
        return true;
    }

    function generateModel(string scrypt) 
        external 
        returns (bool)
    {
        Model model = new Model(asset, scrypt);
        created.push(model);

        emit GeneratedModel(model);
        
        return true;
    }
}
pragma solidity ^0.4.23;

import "../entity/Asset.sol";


/**
 * @title AssetToken
 * This mock just provides a public mint and burn functions for testing purposes,
 * and a public setter for metadata URI
 */
contract AssetMock is Asset {
  constructor(string name, string symbol) 
    public 
    Asset(name, symbol) 
  { 
  }

  function mint(address _to, uint256 _tokenId) public {
    super._mint(_to, _tokenId);
  }

  function burn(uint256 _tokenId) public {
    super._burn(ownerOf(_tokenId), _tokenId);
  }

  function setTokenURI(uint256 _tokenId, string _uri) public {
    super._setTokenURI(_tokenId, _uri);
  }
}

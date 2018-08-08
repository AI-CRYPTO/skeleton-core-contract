
pragma solidity ^0.4.21;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

import "./Asset.sol";

contract AssetProxy is Ownable {

  Asset private asset;

  uint256 public assetId;

  constructor(
    Asset _asset,
    string _signiture
  ) 
    public 
  {
    asset = _asset;
    assetId = _asset.register(msg.sender, _signiture);
  }  

  /**
  * @dev Replace asset 
  * @param _assetAddr address of ERC721 token which is being managed
  */
  function setAsset(
    address _assetAddr
  ) 
    public 
    onlyOwner
  {
    require(_assetAddr != 0x0);

    asset = Asset(_assetAddr);
  }

  function name() 
    public 
    view 
    returns (string) 
  {
    return asset.name();
  }
  
  function symbol() 
    public 
    view 
    returns (string) 
  {
    return asset.symbol();
  }

  function tokenURI() 
    public 
    view 
    returns (string) 
  {
    return asset.tokenURI(assetId);
  }

  function price() 
    public 
    view 
    returns (uint256) 
  {
    return asset.priceOf(assetId);
  }

  function isOwner() 
    public 
    view 
    returns (bool) 
  {
    return msg.sender == asset.ownerOf(assetId);
  }

  function isActivated() 
    public 
    view 
    returns (bool) 
  {
    return asset.isActivated(assetId);
  }
}
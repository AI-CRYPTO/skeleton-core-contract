pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/lifecycle/Destructible.sol";
import "zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

import "./payment/Purchasable.sol";
import "./token/ERC20/ERC20.sol";
import "./entity/Asset.sol";

import "./Component.sol";


contract Marketplace is Component {
  
  using SafeMath for uint256;   

  // Address where funds are collected
  ERC20 private token;

  // The Asset being sold
  Purchasable public purchasable;

  /**
   * Event for token purchase logging
   * @param _purchaser - who paid for the tokens
   * @param _seller - who got the tokens
   * @param _assetId - ID of asset
   * @param _value - weis paid for purchase
   */
  event OrderReceiptReceived(
  address indexed _purchaser,
  address indexed _seller,
  uint256 _assetId, 
  uint256 _value
  );

  /**
   * Event for token purchase logging
   * @param _investor - who paid for the tokens
   * @param _owner - who got the tokens
   * @param _assetId - ID of asset
   * @param _worth - weis paid for purchase
   */
  event FundReceiptReceived(
    address indexed _investor,
    address indexed _owner,
    uint256 _assetId, 
    uint256 _worth
  );

  /**
   * @dev Constructor for this contract.
   * @param _token - Address where collected revenue will be forwarded to
   * @param _asset - Address of the token being sold
   */
  constructor(
    ERC20 _token, 
    Asset _asset
  ) 
    public 
  {
    token = ERC20(_token);
    purchasable = Purchasable(_asset);
  }
  
  /**
   * @dev Execute auction
   * @param _assetId ID of the AIA token to query the owner of
   */
  function order(
    uint256 _assetId
  ) 
    public 
    payable
    whenNotPaused
    returns (bool)
  {
    address seller = purchasable.sellerOf(_assetId);
    uint256 price = purchasable.priceOf(_assetId);

    require(seller != address(0));
    require(seller != msg.sender);

    if (purchasable.isOnAuction(_assetId)) {
      //tokenPool.fundTo(msg.sender, price);
      if (token.transfer(seller, price)) {
        purchasable.executeAuction(msg.sender, _assetId, price);
        emit OrderReceiptReceived(msg.sender, seller, _assetId, price);

        return true;
      }
    }

    return false;
  }

  function fund(
    uint256 _assetId,
    uint256 _value
  ) 
    public
    payable
    whenNotPaused
    returns (bool)
  {
    require(token.balanceOf(msg.sender) >= _value);
    require(token.allowance(msg.sender, this) >= _value);


    address seller = purchasable.ownerOf(_assetId);

    require(seller != address(0));
    require(seller != msg.sender);
    
    if (token.transferFrom(msg.sender, seller, _value)) {
      emit FundReceiptReceived(msg.sender, seller, _assetId, _value);

      return true;    
    }

    return false;
  }

  /**
   * @dev Execute auction multiply 
   * @param _assetIds ID list of the AIA token to query the owner of
   */
  function fundSeveral(
    uint256[] _assetIds
  ) 
    public 
    payable
    whenNotPaused
    returns (bool)
  {
    require(_assetIds.length > 0);

    return true;
  }
}
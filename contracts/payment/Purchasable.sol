pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

import '../token/ERC721/ERC721.sol';

/**
 * @title Purchasable ERC-721 Token
 * @dev Purchasable is a base contract for managing an auction for sale
 */
contract Purchasable is ERC721, Ownable {

  using SafeMath for uint256;
  
  /**
   * @dev Auction defines a auction of token
   */
  struct Auction {
    bytes32 id;
    address seller;
    uint256 price;
    uint256 expiresAt;
    bool renewable;
  }

  // Auctions which are item list for purchase
  mapping (uint256 => Auction) public auctions;

  /**
   * @dev Event for auction created
   * @param _id Auction Identifier
   * @param _assetId AIA Identifier
   * @param _seller Address of seller
   * @param _priceInWei Paid for purchase
   * @param _expiresAt Sales end date
   */
  event AuctionCreated(
    bytes32 _id,
    uint256 indexed _assetId,
    address indexed _seller, 
    uint256 _priceInWei, 
    uint256 _expiresAt
  );

  /**
   * @dev Event for auction cancelled
   * @param _id Auction Identifier
   * @param _assetId AIA Identifier
   * @param _seller address of seller
   */
  event AuctionCancelled(
    bytes32 _id,
    uint256 indexed _assetId,
    address indexed _seller
  );

  /**
   * @dev Event for auction completed
   * @param _id Auction Identifier
   * @param _assetId AIA Identifier
   * @param _seller Address of seller
   * @param _priceInWei Paid for purchase
   */
  event AuctionCompleted(
    bytes32 _id,
    uint256 indexed _assetId, 
    address indexed _seller, 
    uint256 _priceInWei 
  );

  /**
   * @dev Create new auction.
   * @param _assetId ID of the published
   * @param _priceInWei Price in Wei for the supported coin.
   * @param _expiresAt Duration of the auction (in hours)
   */
  function createAuction(
    uint256 _assetId, 
    uint256 _priceInWei,
    uint256 _expiresAt 
  ) 
    public 
  {
    require(_priceInWei > 0);
    require(_expiresAt > now);

    _escrow(msg.sender, _assetId);

    bytes32 auctionId = keccak256
    (
      abi.encodePacked
      (
        block.timestamp, 
        msg.sender, 
        _assetId
      )
    );
    auctions[_assetId] = Auction
    ({
      id: auctionId,
      seller: msg.sender,
      price: _priceInWei,
      expiresAt: _expiresAt,
      renewable: true
    });

    emit AuctionCreated
    (
      auctionId,
      _assetId, 
      msg.sender,
      _priceInWei, 
      _expiresAt
    );
  }

  /**
   * @dev Cancel an already published auction
   * @param _assetId ID of the published
   */
  function cancelAuction(
    uint256 _assetId
  ) 
    public 
  {
    address seller = auctions[_assetId].seller;
    require(seller != address(0));
    require(seller == msg.sender);

    bytes32 auctionId = auctions[_assetId].id;
    delete auctions[_assetId];

    emit AuctionCancelled(auctionId, _assetId, seller);
  }

  /**
   * @dev Execute published auction
   * @param _assetId ID of the published 
   */
  function executeAuction(
    address _buyer,
    uint256 _assetId, 
    uint256 _price
  ) 
    public 
    onlyOwner
  {
    address seller = auctions[_assetId].seller;
    require(seller != address(0));
    require(seller != _buyer);

    super.safeTransferFrom(this, _buyer, _assetId);

    bytes32 auctionId = auctions[_assetId].id;
    delete auctions[_assetId];

    emit AuctionCompleted(auctionId, _assetId, seller, _price);
  }

  /**
  * @dev Get the Auction seller of the specified token ID
  * @param _assetId ID of the AIA token to query the owner of
  * @return owner address currently marked as the owner of the given token ID
  */
  function sellerOf(uint256 _assetId) 
    public 
    view 
    returns (address) 
  {
    address seller = auctions[_assetId].seller;
    return seller;
  }

  /**
  * @dev Get the Auction seller of the specified token ID
  * @param _assetIds ID of the AIA token to query the owner of
  * @return owner address currently marked as the owner of the given token ID
  */
  function sellerOneOf(uint256[] _assetIds) 
    public 
    view 
    returns (address) 
  {
    address seller = auctions[_assetIds[0]].seller;
    return seller;
  }

  /**
  * @dev Get the Auction price of the specified token ID
  * @param _assetId ID of the AIA token to query the owner of
  * @return owner address currently marked as the owner of the given token ID
  */
  function priceOf(uint256 _assetId) 
    public 
    view 
    returns (uint256) 
  {
    uint256 price = auctions[_assetId].price;
    return price;
  }

  /**
  * @dev Get the Auction price of the specified token ID
  * @param _assetIds multiple ID of AIA the token to query the owner of
  * @return owner address currently marked as the owner of the given token ID
  */
  function totalPriceOf(uint256[] _assetIds) 
    public 
    view 
    returns (uint256) 
  {
    require(_assetIds.length > 0);

    uint256 price = 0;
    for (uint i = 0; i < _assetIds.length; i++) {
      if (auctions[_assetIds[i]].price > 0) 
        price = price.add(auctions[_assetIds[i]].price);
    }
    
    return price;
  }

  /**
  * @dev Returns true if is on auction
  * @param _assetId ID of the AIA token to query the owner of
  */
  function isOnAuction(
    uint256 _assetId
  ) 
    public 
    view 
    returns (bool) 
  {

    uint256 expiresAt = auctions[_assetId].expiresAt;
    return (expiresAt < now);
  }

  /**
   * @dev Assigne ownership to this contract
   * @return transferFrom succeeds
   * @param _assetId ID of the AIA token whose approval to verify
   */
  function _escrow(
    address _owner, 
    uint256 _assetId
  ) 
    internal 
  {
    super.transferFrom(_owner, this, _assetId);
  }
}
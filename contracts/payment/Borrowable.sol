pragma solidity ^0.4.23;

import "./Purchasable.sol";

/**
 * @title Borrowable ERC-721 Token instead Purchasable
 * @dev Borrowable is a base contract for managing an auction for lease
 */
contract Borrowable is Purchasable {

  using SafeMath for uint256;

  uint16 public rateInPercent;
  

  /**
   * @dev Event when lease rate of cost is changed
   */
  event BorrowRateChanged(
    address indexed previousOwner
  );

  /**
   * @dev constructor to init rate
   */
  constructor() public {
  rateInPercent = 10;
  }

  /**
   * @dev Execute published auction
   * @param _assetId - ID of the published AIA
   * @param _priceInWei Paid for purchase
   */
  function executeAuction
  (
    uint256 _assetId, 
    uint256 _priceInWei
  ) 
    public 
  {
    address seller = auctions[_assetId].seller;
    require(seller != address(0));
    require(seller != msg.sender);

    bytes32 auctionId = auctions[_assetId].id;
    delete auctions[_assetId];

    emit AuctionCompleted(auctionId, _assetId, seller, _priceInWei);
  }

  /**
  * @dev Get the auction price of the specified token ID
  * @param _assetId ID of the AIA token to query the owner of
  * @return owner address currently marked as the owner of the given token ID
  */
  function priceOf(uint256 _assetId) 
    public 
    view 
    returns (uint256) 
  {
    uint256 price = auctions[_assetId].price;
    return price.div(100).mul(rateInPercent);
  }

  /**
  * @dev Change lease rate of cost
  * @param _rate lease rate in Percent
  */
  function changeRate(uint16 _rate) 
    public 
    onlyOwner 
  {
    require(rateInPercent > 0);

    rateInPercent = _rate;
    emit BorrowRateChanged(_rate);
  }
}
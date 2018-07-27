pragma solidity ^0.4.23;

import "./Purchasable.sol";

/**
 * @title License ERC-721 Token instead Purchasable
 * @dev License is a base contract for managing an auction for lease
 */
contract License {

  struct License {
    uint256 assetId;
    uint256 attributes;
    uint256 issuedTime;
    uint256 expirationTime;
  }

  /**
   * @dev The ID of each license is an index in this array.
   */
  License[] licenses;

  /**
   */
  function _isValidLicense(uint256 _licenseId) internal view returns (bool) {
    return assetIdOf(_licenseId) != 0;
  }

  /**
   * @notice Get a license's assetId
   * @param _licenseId the license id
   */
  function assetIdOf(uint256 _licenseId) public view returns (uint256) {
    return licenses[_licenseId].assetId;
  }
}
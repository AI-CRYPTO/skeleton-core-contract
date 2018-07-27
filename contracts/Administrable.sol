pragma solidity ^0.4.24;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/ownership/rbac/RBAC.sol';


/**
 * @title Administrable
 * @dev The Admin contract defines a single Admin who can transfer the ownership 
 * of a contract to a new address, even if he is not the owner. 
 * A Admin can transfer his role to a new address. 
 */
contract Administrable is Ownable, RBAC {
  string public constant ROLE_REGISTER = "register";

  constructor () public {
    addRole(msg.sender, ROLE_REGISTER);
  }

  /**
   * @dev Throws if called by any account that's not a Admin.
   */
  modifier onlyAdmin(string _role) {
    checkRole(msg.sender, _role);
    _;
  }

  modifier onlyOwnerOrAdmin(string _role) {
    require(msg.sender == owner || isAdmin(msg.sender, _role));
    _;
  }

  /**
   * @dev getter to determine if address has Admin role
   */
  function isAdmin(address _addr, string _role)
    public
    view
    returns (bool)
  {
    return hasRole(_addr, _role);
  }

  /**
   * @dev add a admin role to an address
   * @param _operator address
   * @param _role the name of the role
   */
  function addAdmin(address _operator, string _role)
    public
    onlyOwner
  {
    addRole(_operator, _role);
  }

  /**
   * @dev remove a admin role from an address
   * @param _operator address
   * @param _role the name of the role
   */
  function removeAdmin(address _operator, string _role)
    public
    onlyOwner
  {
    removeRole(_operator, _role);
  }

  /**
   * @dev claim a admin role from an address
   * @param _operator address
   * @param _role the name of the role
   */
  function claimAdmin(address _operator, string _role)
    public
    onlyOwner
  {
    removeRole(_operator, _role);

    addRole(msg.sender, _role);
  }
}

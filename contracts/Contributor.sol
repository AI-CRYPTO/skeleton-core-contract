pragma solidity ^0.4.23;

import "./reward/TokenPool.sol";

import "./Component.sol";

contract Contributor is Component {

  TokenPool private tokenPool;

  constructor(TokenPool _tokenPool)
    public
  {
    tokenPool = _tokenPool;
  }

  function _perform() 
    internal 
  {
    /**
      distribute from token pool to contributors
     */
  }
}
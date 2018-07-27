pragma solidity ^0.4.24;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

import '../Administrable.sol';

import "../token/ERC20/ERC20.sol";

/**
 * @title TokenPool
 * @dev Contract where collected revenue will be forwarded to
 */
contract TokenPool is Administrable {
    
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  address[] public accounts;
  mapping (address => uint256) public accountIndexes;
  mapping (address => uint256) public deposited;

  address public vault;
  State public state;

  // The token being withdraw
  ERC20 public token;

  /**
   * @dev Modifier to make a function callable only when the contract is active.
   */
  modifier whenActive() {
    require(state == State.Active);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is refunding.
   */
  modifier whenRefunding() {
    require(state == State.Refunding);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not closed.
   */
  modifier whenNotClosed() {
    require(state != State.Closed);
    _;
  }

  event Acivated();
  event Closed();
  event RefundsEnabled();
  
  event Funded(address indexed _holder, uint256 _weiAmount);
  event Deposited(address indexed _holder, uint256 _weiAmount);
  event Withdrawn(address indexed _holder, uint256 _weiAmount);
  event Refunded(address indexed _holder, uint256 _weiAmount);

  /**
   * @param _vault Cold wallet address to store token
   * @param _token ERC20 token
   */
  constructor(
    address _vault, 
    ERC20 _token
  ) 
    public 
  {
    require(_vault != address(0));
    vault = _vault;
    token = _token;

    state = State.Active;

    accounts.push(vault);
  }

  /**
   * @dev Provide funds
   * @param _value amount of token for fund
   */
  function fund(
    uint256 _value
  ) 
    whenActive
    public 
    payable 
  {
    require(hasEnoughOf(msg.sender, _value));
    require(token.transferFrom(msg.sender, vault, _value));
    deposited[vault] = deposited[vault].add(_value);
    emit Funded(msg.sender, _value);
  }

  /**
   * @dev Funding
   * @param _holder account holder address
   * @param _value amount of token to deposit
   */
  function fundTo(
    address _holder,
    uint256 _value
  ) 
    onlyOwner 
    whenActive
    public 
    payable 
  {
    require(hasEnoughOf(_holder, _value));
    require(token.transferFrom(_holder, vault, _value));
    deposited[_holder] = deposited[_holder].add(_value);
    emit Funded(_holder, _value);
  }

  /**
   * @dev Deposit
   * @param _value amount of token to deposit
   */
  function deposit(
    uint256 _value
  ) 
    whenActive
    public 
    payable 
  {
    require(hasEnoughOf(msg.sender, _value));
    require(token.transferFrom(msg.sender, vault, _value));
    
    deposited[msg.sender] = deposited[msg.sender].add(_value);
    emit Deposited(msg.sender, _value);
  }

  /**
   * @dev return true if holder has enough balances
   * @param _holder account holder address
   * @param _value amount of token to deposit
   */
  function hasEnoughOf(
    address _holder,
    uint256 _value
  ) 
    public
    view
    returns (bool)
  {
    return token.balanceOf(_holder) >= _value;
  }

  /** 
    * @dev Deposit self
    */
  function () external payable {
    deposit(msg.value);
  }

  /**
   * @param _value amount of token to withdraw
   */
  function withdraw(
    uint256 _value
  ) 
    whenActive
    public 
  {
    require(_value > 0);
    require(deposited[msg.sender] >= _value);
    require(token.transferFrom(vault, msg.sender, _value));
    
    deposited[msg.sender] = deposited[msg.sender].sub(_value);
    emit Withdrawn(msg.sender, _value);
  }

  function active() 
    onlyOwner 
    public 
  {
    state = State.Active;

    emit Acivated();
  }

  function close() 
    onlyOwner 
    whenNotClosed
    public 
  {
    state = State.Closed;

    emit Closed();

    vault.transfer(address(this).balance);
  }

  function enableRefunds() 
    onlyOwner 
    whenActive
    public 
  {
    state = State.Refunding;

    emit RefundsEnabled();
  }
}

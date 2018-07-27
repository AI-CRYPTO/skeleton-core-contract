pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';

import "./token/ERC20/ERC20.sol";
import "./entity/AssetProxy.sol";

import "./Marketplace.sol";

import "./Component.sol";

contract Trainer is Component {

    using SafeMath for uint256;     

    enum TaskState {
        ALIVE,
        DEAD
    }

    struct Task {
        bytes32 title;
        address[] assets;
        address performer;
        TaskState state;
    }

    event TaskCreated(bytes32 _title, address[] _assets);
    event TaskUpdated(bytes32 _title, address[] _assets);
    event TaskDeprecated(bytes32 _title);
    event TaskFunded(bytes32 _title);

    /**
    * Event for token purchase logging
    * @param _purchaser - who paid for the tokens
    * @param _seller - who got the tokens
    * @param _value - weis paid for purchase
    * @param _amount - amount of tokens purchased
    */
    event TrainingSuccess(
        address indexed _purchaser,
        address indexed _seller,
        uint256 _value,
        uint256 _amount
    );

    Task[] public tasks;
    mapping(bytes32 => uint) private taskIndex;

    Marketplace private market;

    /**
     * @dev Constructor for this contract.
     * @param _market - Market being sold
     */
    constructor(
        Marketplace _market
    ) 
        public 
    { 
        market = _market; 
    }

    function createTask(
        bytes32 _title, 
        address[] _assets
    ) 
        public 
    {
        uint index = taskIndex[_title];
        require(index == 0);

        taskIndex[_title] = tasks.push(
            Task(_title, _assets, msg.sender, TaskState.ALIVE)) - 1;

        emit TaskCreated(_title, _assets);
    }

    function updateTask(
        bytes32 _title, 
        address[] _assets
    ) 
        public 
    {
        uint index = taskIndex[_title];
        require(index != 0);

        require(tasks[index].state == TaskState.ALIVE);
        require(tasks[index].performer == msg.sender);

        tasks[index].assets = _assets;

        emit TaskUpdated(_title, _assets);
    }

    function deprecateTask(
        bytes32 _title
    )
        public 
    {
        uint index = taskIndex[_title];
        require(index != 0);

        require(tasks[index].state == TaskState.ALIVE);
        require(tasks[index].performer == msg.sender);

        tasks[index].state = TaskState.DEAD;

        emit TaskDeprecated(_title);
    }

    function fundTask(
        bytes32 _title
    ) 
        public 
    {
        uint index = taskIndex[_title];
        require(index != 0);

        require(tasks[index].state == TaskState.ALIVE);

        uint256[] memory assetIds = new uint256[](tasks[index].assets.length);
        for (uint i = 0; i < tasks[index].assets.length; i++) {
            assetIds[i] = AssetProxy(tasks[index].assets[i]).assetId();
        }

        market.orderSeveral(assetIds);

        emit TaskFunded(_title);
    }

    function assetsOf(
        bytes32 _title
    ) 
        public 
        view 
        returns 
    (
        address[],
        uint256
    ) 
    {
        uint index = taskIndex[_title];
        require(index != 0);

        uint256 price = 0;
        address[] memory assets = new address[](tasks[index].assets.length);
        for (uint i = 0; i < tasks[index].assets.length; i++) {
            assets[i] = tasks[index].assets[i];
            price = price.add(AssetProxy(assets[i]).priceOf());
        }
        return (assets, price);
    }

    function predict(bytes32 _title) external returns(bool);
    function estimate(bytes32 _title) external returns(bool);
    function train(bytes32 _title) external returns(bool);
}
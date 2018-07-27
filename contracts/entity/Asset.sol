pragma solidity ^0.4.23;

import "../token/NonFungible.sol";
import "../payment/Borrowable.sol";
import "../reward/Evaluable.sol";
import "../Administrable.sol";

import "./Signiture.sol";

contract Asset is NonFungible, Borrowable, Evaluable, Administrable, Signiture  {

    event AssetRegistered(uint256 _assetId);
    event AssetActivated(uint256 _assetId);
    event AssetDeactivated(uint256 _assetId);
    event AssetExpired(uint256 _assetId);

    enum State 
    { 
        NORMAL, 
        SUSPENDING, 
        CANCELED, 
        DELETED, 
        EXPIRATED // unused
    }

    struct Metadata 
    {
        string title;
        string category;
        string description;
        string[] tags;
    }

    mapping(uint256 => Metadata) internal tokenMetadatas;
    mapping(uint256 => State) internal tokenStates;
    mapping(string => uint256[]) internal tagTokens;

    /**
     * @dev Constructor for this contract.
     * @param _name - string representing the token name.
     * @param _symbol - string representing the token symbol
     */
    constructor
    (
        string _name, 
        string _symbol
    ) 
        public
        NonFungible(_name, _symbol)
        Borrowable()
    {
    }

    function register
    (
        address _author,
        string _signiture
    ) 
        public 
        onlyOwnerOrAdmin(ROLE_REGISTER) 
        returns (uint256)
    {
        uint256 newAssetId = uint256(keccak256
        (
            abi.encodeWithSignature
            (
                _signiture, 
                now, 
                owner
            )
        ));

        _mint(_author, newAssetId);
        _suspending(newAssetId);

        emit AssetRegistered(newAssetId);

        return newAssetId;
    }

    function activate
    (
        uint256 _assetId
    ) 
        public 
        isTokenOwned(_assetId)
    {
        _normal(_assetId);

        emit AssetActivated(_assetId);
    }

    function deactivate
    (
        uint256 _assetId
    ) 
        public 
        isTokenOwned(_assetId)
    {
        _canceled(_assetId);

        emit AssetDeactivated(_assetId);
    }

    function expire
    (
        uint256 _assetId
    ) 
        public 
        onlyOwnerOrAdmin(ROLE_REGISTER)
    {
        _expired(_assetId);

        emit AssetExpired(_assetId);
    }

    function details(uint256 _assetId) 
        external
        view
        returns(string, string, string, State)
    {
        return 
        (
            tokenMetadatas[_assetId].title, 
            tokenMetadatas[_assetId].category, 
            tokenMetadatas[_assetId].description, 
            tokenStates[_assetId]
        );
    }

    function _normal(uint256 _assetId) 
        internal 
    {
        require(tokenStates[_assetId] != State.NORMAL);

        tokenStates[_assetId] = State.NORMAL;
    }

    function _suspending(uint256 _assetId) 
        internal 
    {
        require(tokenStates[_assetId] != State.SUSPENDING);

        tokenStates[_assetId] = State.SUSPENDING;
    }

    function _canceled(uint256 _assetId) 
        internal 
    {
        require(tokenStates[_assetId] != State.CANCELED);

        tokenStates[_assetId] = State.CANCELED;
    }

    function _expired(uint256 _assetId) 
        internal 
    {
        require(tokenStates[_assetId] != State.EXPIRATED);

        tokenStates[_assetId] = State.EXPIRATED;
    }
}
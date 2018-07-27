pragma solidity ^0.4.23;

import "zeppelin-solidity/contracts/lifecycle/Destructible.sol";
import "zeppelin-solidity/contracts/lifecycle/Pausable.sol";
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

import "./Administrable.sol";

contract Component is Pausable, Destructible, Administrable {

    using SafeMath for uint256;

    /**
     * @dev Destroy this contract
     */
    function destroy() 
        public 
        onlyOwner
    {
        super.destroy();
    }

    /**
     * @dev Destroy this contract
     * @param _recipient address of the recipient whom reclaimed token ownership
     */
    function destroyAndSend(
        address _recipient
    )  
        public 
        onlyOwner 
    {
        super.destroyAndSend(_recipient);
    }

    /** 
     * @dev Prevent transfering to this contract 
     */
    function () external payable {
        revert();
    }
}
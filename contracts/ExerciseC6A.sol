pragma solidity ^0.4.25;

contract ExerciseC6A {
    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/
    uint constant M = 2;

    struct UserProfile {
        bool isRegistered;
        bool isAdmin;
    }

    address private contractOwner; // Account used to deploy contract
    mapping(address => UserProfile) userProfiles; // Mapping for storing user profiles
    bool private operational = true;

    address[] multiCalls = new address[](0);

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/

    // No events

    /**
     * @dev Constructor
     *      The deploying account becomes contractOwner
     */
    constructor() public {
        contractOwner = msg.sender;
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
     * @dev Modifier that requires the "ContractOwner" account to be the function caller
     */
    modifier requireContractOwner() {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    modifier requireIsOperational() {
        require(operational, "Contract is not operational");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
     * @dev Check if a user is registered
     *
     * @return A bool that indicates if the user is registered
     */
    function isUserRegistered(address account) external view returns (bool) {
        require(account != address(0), "'account' must be a valid address.");
        return userProfiles[account].isRegistered;
    }

    function setContractStatus(bool mode) external {
        require(
            mode != operational,
            "New mode must be different from existing mode"
        );
        require(userProfiles[msg.sender].isAdmin, "Caller is not an Admin");

        // Note that here we are looping through an array. This is a potential serious drawback because if the array grows sufficintly long, you may
        // reach the gas limit before reaching the end of the array when iterating and as a result the contract will be stuck before it can conclude
        // the operation. This is a potential lockout scenario where the contract becomes unusable. It is better to have an external client repeatedly
        // calling the function, so that the loop is performed by the calling program rather than within the smart contract.
        bool isDuplicate = false;
        for (uint c = 0; c < multiCalls.length; c++) {
            if (multiCalls[c] == msg.sender) {
                isDuplicate = true;
                break;
            }
        }
        require(!isDuplicate, "Caller has already called this function");

        multiCalls.push(msg.sender);
        if (multiCalls.length >= M) {
            operational = mode;
            multiCalls = new address[](0);
        }
    }

    function isOperational() public view returns (bool) {
        return operational;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

    function registerUser(
        address account,
        bool isAdmin
    ) external requireContractOwner requireIsOperational {
        require(
            !userProfiles[account].isRegistered,
            "User is already registered."
        );

        userProfiles[account] = UserProfile({
            isRegistered: true,
            isAdmin: isAdmin
        });
    }
}

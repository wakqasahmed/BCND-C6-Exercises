pragma solidity ^0.5.0;

contract ExerciseC6A {

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/


    struct UserProfile {
        bool isRegistered;
        bool isAdmin;
    }

    address private contractOwner;                  // Account used to deploy contract
    mapping(address => UserProfile) userProfiles;   // Mapping for storing user profiles
    bool private operational; // Allows contract to pause/resume
    uint constant M = 3; // M-of-N e.g. 3-of-5 Allows multi-party auth to set isOperational flag
    uint constant N = 5;
    mapping(address => bool) private voted;   // admin addresses who already voted for changing operational mode
    address[] private voterAddresses;

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/

    // No events

    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor
                                (
                                ) 
                                public 
    {
        contractOwner = msg.sender;
        operational = true;
        // voterAddresses = new address[](N);
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    modifier requireAdminUser()
    {
        // require(account != address(0), "'account' must be a valid address.");
        require(userProfiles[msg.sender].isAdmin == true, "Caller is not an admin user");
        _;
    }

    modifier requireIsOperational()
    {
        require(operational == true, "Contract is not operational.");
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
    function isUserRegistered
                            (
                                address account
                            )
                            external
                            view
                            returns(bool)
    {
        require(account != address(0), "'account' must be a valid address.");
        return userProfiles[account].isRegistered;
    }

   /**
    * @dev Check if a user has admin role
    *
    * @return A bool that indicates if the user is admin
    */   
    function isUserAdmin
                            (
                                address account
                            )
                            external
                            view
                            returns(bool)
    {
        require(account != address(0), "'account' must be a valid address.");
        return userProfiles[account].isAdmin;
    }

    function isOperational() public view returns (bool) {
        return operational;        
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

    function registerUser
                                (
                                    address account,
                                    bool isAdmin
                                )
                                external
                                requireContractOwner
                                requireIsOperational
    {
        require(!userProfiles[account].isRegistered, "User is already registered.");

        userProfiles[account] = UserProfile({
                                                isRegistered: true,
                                                isAdmin: isAdmin
                                            });
    }

    function setOperatingMode (bool mode) external requireAdminUser returns (string memory)
    {
        require(operational != mode, "Contract is already in the given operating mode.");

        if(voted[msg.sender] == true){
            return "vote ignored as it had been casted previously";            
        }

        voterAddresses.push(msg.sender);
        voted[msg.sender] = true;

        if(voterAddresses.length == M){
            operational = mode;
            resetVoters();
        }

        return "More votes required to make a consensus for changing operating mode";
        // return string(abi.encodePacked(Strings.toString(c), " of ", Strings.toString(mCount), " votes received to change operational mode"));
    }

    function resetVoters() private {
        for (uint i = 0; i < voterAddresses.length; i++) {
            clearVotersMapping(voterAddresses[i]);
        }
        
        delete voterAddresses;
        // voterAddresses = new address[](N);
    }

    function clearVotersMapping(address account) private {
        // Reset the value of their vote to false.
        voted[account] = false;
    }    
}
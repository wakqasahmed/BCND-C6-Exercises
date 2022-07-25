
var Test = require('../config/testConfig.js');

contract('ExerciseC6A', async (accounts) => {

  var config;
  before('setup contract', async () => {
    config = await Test.Config(accounts);
  });

  it('contract owner can register new user', async () => {
    
    // ARRANGE
    let caller = accounts[0]; // This should be config.owner or accounts[0] for registering a new user
    let newUser = config.testAddresses[0]; 

    // ACT
    await config.exerciseC6A.registerUser(newUser, false, {from: caller});
    let result = await config.exerciseC6A.isUserRegistered.call(newUser); 

    // ASSERT
    assert.equal(result, true, "Contract owner cannot register new user");

  });

  it('contract owner can register new user with admin role', async () => {
    
    // ARRANGE
    let caller = accounts[0]; // This should be config.owner or accounts[0] for registering a new user
    let newUser = config.testAddresses[1]; 

    // ACT
    await config.exerciseC6A.registerUser(newUser, true, {from: caller});
    let result = await config.exerciseC6A.isUserRegistered.call(newUser); 
    let result2 = await config.exerciseC6A.isUserAdmin.call(newUser); 

    // ASSERT
    assert.equal(result, true, "Contract owner cannot register new user");
    assert.equal(result2, true, "Contract owner cannot register new user as an admin");

  });

  /*
  //This test is for simple pause function by the contract owner
  it('contract owner can pause the contract', async () => {
    
    // ARRANGE
    let caller = accounts[0]; // This should be config.owner or accounts[0] for registering a new user
    let isOperational = false; 

    // ACT
    await config.exerciseC6A.setIsOperational(isOperational, {from: caller});
    let result = await config.exerciseC6A.isContractOperational.call(); 

    // ASSERT
    assert.equal(result, false, "Contract owner is unable to pause the contract");

  });
  */

  //This test is for pausing a contract on the basis of multi-party consensus
  describe('pausing the contract based on multi-party consensus', () => {

    it('operating mode is changed when multi-party consensus is made', async () => {

      // ARRANGE
      let caller = accounts[0]; // This should be config.owner or accounts[0] for registering a new user
      let adminUser1 = accounts[1];
      let adminUser2 = accounts[2];
      let adminUser3 = accounts[3];
      let adminUser4 = accounts[4];
      let adminUser5 = accounts[5];                        
      
      // ACT
      await config.exerciseC6A.registerUser(adminUser1, true, {from: caller});
      await config.exerciseC6A.registerUser(adminUser2, true, {from: caller});
      await config.exerciseC6A.registerUser(adminUser3, true, {from: caller});
      await config.exerciseC6A.registerUser(adminUser4, true, {from: caller});
      await config.exerciseC6A.registerUser(adminUser5, true, {from: caller});

      let currentStatus = await config.exerciseC6A.isOperational.call();
      let newStatus = !currentStatus;

      await config.exerciseC6A.setOperatingMode(newStatus, {from: adminUser1});
      await config.exerciseC6A.setOperatingMode(newStatus, {from: adminUser2});      
      await config.exerciseC6A.setOperatingMode(newStatus, {from: adminUser3});
  
      let result = await config.exerciseC6A.isOperational.call(); 

      // ASSERT
      assert.equal(result, newStatus, "Operating mode could not be changed");  
    });
  })
});

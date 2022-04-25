const { expect } = require("chai");
const { ethers } = require("hardhat");

beforeEach(async () => {
  [owner, alice, bob] = await ethers.getSigners();
  const RockPaperScissors = await ethers.getContractFactory(
    "RockPaperScissors"
  );
  // Contract is the concrete instance of our smart contract
  contract = await RockPaperScissors.deploy(1000);
  await contract.deployed();
  // We create a game instance using the payable createGame function
  await contract.createGame(
    "0xc5df0b6cfb09a97697e51c816ef269f0eb180ebf4183ab2688ea7c5a9a2f9ea8",
    { value: 1000 }
  );
  await contract
    .connect(alice)
    .joinGame(
      "0",
      "0xc5df0b6cfb09a97697e51c816ef269f0eb180ebf4183ab2688ea7c5a9a2f9ea8",
      { value: 1000 }
    );

  // We set game as the variable name for our game object
  game = await contract.games([0]);
  potAmount = await game[2];
  host = await game[0];
  guest = await game[1];
});

describe("Create a game", function () {
  it("Should increment nextGameId by one", async function () {
    // Contract is created already in beforeEach above
    next_game_Id = await contract.nextGameId();
    expect(next_game_Id).to.equal(1);
  });

  it("Should increase the pot amount by the entry fee amount", async function () {
    const pot = await game[2];
    expect(pot).to.equal(1000);
  });

  it("Should set a start time", async function () {
    const startTime = await game[4];
    // console.log("START TIME:", startTime);
    expect(startTime).to.not.equal(0); // FIX THIS
  });
});
// ==============================================================================

describe("Join a game", function () {
  it("Should increase pot amount to 2 x entry fee", async function () {
    console.log("guest");
    // let new_contract = await contract
    //   .connect(alice)
    //   .joinGame(
    //     "0",
    //     "0xc5df0b6cfb09a97697e51c816ef269f0eb180ebf4183ab2688ea7c5a9a2f9ea8",
    //     { value: 1000 }
    //   );

    console.log("host:", host);
    console.log("guest:", guest);
    console.log("Pot:", potAmount);

    expect(potAmount).to.equal(2000);
  });

  it("Should change game status to STATUS_IN_PROGESS", async function () {});
});

// describe("Reveal a move", function () {
//   it("Check that host has revealed their move", async function () {
//
//   });

//   it("Check that guest has revealed their move", async function () {
//
//   });
// });

// describe("Initaite Payout to winner", function () {
//   it("Winners balance has increased by pot amount", async function () {
//
//   });

//   it("Check that the pot amount is now equal to zero", async function () {
//
//   });

//   it("check that the losers balance has decreased by the entry fee amount", async function () {
//
//   });
// });

// describe("Draw functionality", function () {
//   it("Should increase rollover pot by entry fee", async function () {
//
//   });

//   it("Check that player balances have been reduced by entry fee / 2", async function () {
//
//   });

//   it("Check that the next winner gets the pot amount + rollover pot", async function () {
//
//   });
// });

// describe("Refund functionality", function () {
//   it("Check that host is able to request a refund if 48 hours have elapsed and their is no winner", async function () {
//
//   });

//   it("Check that player balances have been reduced by entry fee / 2", async function () {
//
//   });

//   it("Check that the next winner gets the pot amount + rollover pot", async function () {
//
//   });
// });

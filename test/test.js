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

  // We set game as the variable name for our game object
  game = await contract.games([0]);
  potAmount = await game[2];
  host = await game[0];
  guest = await game[2];
  next_game_Id = await contract.nextGameId();
  startTime = await game[4];
});

describe("Create a game", function () {
  it("Should increment nextGameId by one", async function () {
    expect(next_game_Id).to.equal(1);
  });

  it("Should increase the pot amount by the entry fee amount", async function () {
    expect(potAmount).to.equal(1000);
  });

  it("Should set a start time", async function () {
    expect(startTime).to.not.equal(0);
  });
});

describe("Join a game", function () {
  it("Should increase guest bet amount by entry fee", async function () {
    await contract
      .connect(alice)
      .joinGame(
        0,
        "0xc5df0b6cfb09a97697e51c816ef269f0eb180ebf4183ab2688ea7c5a9a2f9ea8",
        { value: 1000 }
      );
    let game = await contract.games([0]);
    expect(game[2]).to.equal(2000);
  });

  it("Should change game status to STATUS_IN_PROGESS", async function () {
    await contract
      .connect(alice)
      .joinGame(
        0,
        "0xc5df0b6cfb09a97697e51c816ef269f0eb180ebf4183ab2688ea7c5a9a2f9ea8",
        { value: 1000 }
      );
    let game = await contract.games([0]);
    expect(game[3]).to.equal(1);
  });
});

describe("Reveal a move", function () {
  it("Check that host has revealed their move", async function () {
    await contract
      .connect(alice)
      .joinGame(
        0,
        "0xc5df0b6cfb09a97697e51c816ef269f0eb180ebf4183ab2688ea7c5a9a2f9ea8",
        { value: 1000 }
      );
    await contract.revealMove(0, 0, "pass");
    let game = await contract.games([0]);
    let player_move = game[0][3];
    expect(player_move).lessThanOrEqual(2);
  });

  // describe("Initaite Payout to winner", function () {
  //   it("Increase winners balance by pot amount", async function () {
  //     // Guest joins game
  //     await contract
  //       .connect(alice)
  //       .joinGame(
  //         0,
  //         "0xc5df0b6cfb09a97697e51c816ef269f0eb180ebf4183ab2688ea7c5a9a2f9ea8",
  //         { value: 1000 }
  //       );
  //     await contract.revealMove(0, 0, "pass");
  //     let player_move = game[0][3];
  //     console.log("player move:", player_move);
  //     console.log("game:", game);
  //   });
});
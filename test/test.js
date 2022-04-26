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

  // We set the variables name for tests
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
  beforeEach(async () => {
    // We join the existing game (game[0]) with Alice's account
    await contract
      .connect(alice)
      .joinGame(
        0,
        "0xc5df0b6cfb09a97697e51c816ef269f0eb180ebf4183ab2688ea7c5a9a2f9ea8",
        { value: 1000 }
      );
  });
  it("Should increase the pot amount by the entry fee amount", async function () {
    let game = await contract.games([0]);
    let new_pot = await game[2];
    expect(new_pot).to.equal(2000);
  });
  it("Should change game status to STATUS_IN_PROGESS", async function () {
    let game = await contract.games([0]);
    expect(game[3]).to.equal(1);
  });
});

describe("Reveal a move", function () {
  beforeEach(async () => {
    // We join the existing game (game[0]) with Alice's account, move is scissors password is "pass"
    await contract
      .connect(alice)
      .joinGame(
        0,
        "0x981eba72fe369eaf5013fbafc2cec2f5dfa27ed62ccb51aaa0f9d487fb46a41b",
        { value: 1000 }
      );
  });
  it("Should reveal the host's move", async function () {
    await contract.revealMove(0, 0, "pass");
    let game = await contract.games([0]);
    let host_move = game[0][3];
    expect(host_move).lessThanOrEqual(2);
  });

  it("Should reveal the guest's move", async function () {
    await contract.revealMove(0, 1, "pass");
    let game = await contract.games([0]);
    let guest_move = game[1][3];
    expect(guest_move).lessThanOrEqual(2);
  });
});

describe("Should Payout winner with pot amount", function () {
  beforeEach(async () => {
    // We join the existing game (game[0]) with Alice's account
    await contract
      .connect(alice)
      .joinGame(
        0,
        "0xc5df0b6cfb09a97697e51c816ef269f0eb180ebf4183ab2688ea7c5a9a2f9ea8",
        { value: 1000 }
      );
  });
  it("Should reveal the host's move", async function () {
    await contract.revealMove(0, 0, "pass");
    let game = await contract.games([0]);
    console.log[("Game:  ", game)];
    let player_move = game[0][3];
    expect(player_move).lessThanOrEqual(2);
  });

  it("Should reveal the guest's move", async function () {
    await contract.revealMove(0, 0, "pass");
    let game = await contract.games([0]);
    console.log[("Game:  ", game)];
    let player_move = game[0][3];
    expect(player_move).lessThanOrEqual(2);
  });
});

// Draw
// Refund

const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

beforeEach(async () => {
  [owner, alice, bob] = await ethers.getSigners();
  const RockPaperScissors = await ethers.getContractFactory(
    "RockPaperScissors"
  );
  // contract is the concrete instance of our smart contract, we also specify the entry fee for each game
  contract = await RockPaperScissors.deploy(1000);
  // We deploy the contract
  await contract.deployed();
  // We create a game instance using the payable createGame function
  await contract.createGame(
    // Salted Hash of move, in this case the move is Rock and the password is "pass"
    "0xc5df0b6cfb09a97697e51c816ef269f0eb180ebf4183ab2688ea7c5a9a2f9ea8",
    // We add the entry fee for the game
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
    const game = await contract.games([0]);
    const new_pot = await game[2];
    expect(new_pot).to.equal(2000);
  });
  it("Should change game status to STATUS_IN_PROGESS", async function () {
    const game = await contract.games([0]);
    expect(game[3]).to.equal(1);
  });
});

describe("Reveal a move", function () {
  beforeEach(async () => {
    // We join the existing game (game[0]) with Alice's account
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
    const game = await contract.games([0]);
    const host_move = game[0][3];
    expect(host_move).lessThanOrEqual(2);
  });

  it("Should reveal the guest's move", async function () {
    await contract.connect(alice).revealMove(0, 1, "pass");
    const game = await contract.games([0]);
    const guest_move = game[1][3];
    expect(guest_move).lessThanOrEqual(2);
  });
});

describe("Should Payout winner with pot amount", function () {
  beforeEach(async () => {
    // We join the existing game (game[0]) with Alice's account
    await contract.connect(alice).joinGame(
      0,
      // Salted Hash of move, in this case Alice's move is Paper and her password is "pass"
      "0x981eba72fe369eaf5013fbafc2cec2f5dfa27ed62ccb51aaa0f9d487fb46a41b",
      { value: 1000 }
    );
  });
  it("Should reveal the host's move", async function () {
    // The host commits their move as part of the createGame() function.  In the case below the host's move is Rock and the password is "pass"
    await contract.revealMove(0, 0, "pass");
    const game = await contract.games([0]);
    const host_move = game[0][3];
    expect(host_move).to.equal(0);
  });

  it("Should reveal the guest's move", async function () {
    // The guest commits their move as part of the joinGame() function.  In the case below the guest's move is Paper and the password is "pass"
    await contract.connect(alice).revealMove(0, 1, "pass");
    const game = await contract.games([0]);
    const guest_move = game[1][3];
    expect(guest_move).to.equal(1);
  });

  it("Should update player status of the winner", async function () {
    await contract.revealMove(0, 0, "pass");
    await contract.connect(alice).revealMove(0, 1, "pass");
    const game = await contract.games([0]);

    const host_player_status = game[0][4];
    const guest_player_status = game[1][4];
    expect(guest_player_status).to.equal(0);
  });
  it("Should update player status of the loser", async function () {
    await contract.revealMove(0, 0, "pass");
    await contract.connect(alice).revealMove(0, 1, "pass");
    const game = await contract.games([0]);
    const host_player_status = game[0][4];
    expect(host_player_status).to.equal(1);
  });
  // it("Should update player status of loser", async function () {});

  // it("Should increase the winners balance by pot amount", async function () {});
  // it("Should decrease the losers balance by entry fee amount", async function () {});
});

// Draw
// Refund

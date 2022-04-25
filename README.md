# The Challenge

Write a new Ethereum smart contract with the following requirements:

- [x] 1. It must keep track of an unbounded number of rock-paper-scissors
     games;
- [x] 2. Each game should be identifiable by a unique ID;
- [x] 3. Once two players commit their move to the same game ID, the game
     is now resolved, and no further moves can be played;
- [x] 4. Each game, once started, needs both moves to be played within 48h.
     If that doesn’t happen, the first player can get a full refund;
- [x] 5. To play, both users have to commit a predetermined amount of ETH (to
     be decided by the contract deployer);
- [x] 6. It should be impossible for the second player to figure out what the
     first player’s move was before both moves are committed;
- [x] 7. When a game is finished, the winner gets to take the full pot;
- [x] 8. In the event of a draw, each player can recover only 50% of their
     locked amount. The other 50% are to be distributed to the next game
     that finishes;
- [ ] 9. The repo should include some unit tests to simulate and test the main
     behaviors of the game.

This challenge required a commit/reveal strategy to ensure that players could not see each others moves before the reveal stage. The flow of the game is as follows:

1. Host creates a hashed salt of their move by calling getSaltedHash() and providing a move and a password.
2. Host creates a game by calling createGame() and providing the salted hash from above and paying the entry fee.
3. Guest joins the game by providing a game ID, a salted hash of their move and paying the entry fee.
4. Host reveals move
5. Player reveals move
6. Payout function can be called by any player, it sends pot amount to the winner
7. In case of a draw, on 50 % of the entry fee is returned to each player, the remainder is sent to a rollover pot for the next winning game.
8. If 48 hours have elapsed between the game creation and both players have not revealed, the host can request a refund using requestRefund() function. Also if the host creates a game and no one joins, this function may be called after 48 hours.

Attack Vectors:
There are a few scenarios that should be explored.

1. Guest reveals, but the host does not. In this scenario the host could potentially lock up the guest's entry fee indefinitely. The refund function can only be called by the host (as per the requirements). The fix would be to allow the guest to call the refund function if the host does not reveal after 48 hrs.
2. In a draw scenario 50% of the pot will go to the rollover pot. It is possible for two colluding parties to time their game so that it finishes directly after a draw. This would be trivial to perform and could also be performed by a single attacker.

# To run locally

1. Start a local node using
   `npx hardhat node`

2. Open a new terminal and deploy the smart contract in the localhost network using
   `npx hardhat run --network localhost scripts/deploy.js`

# To run tests:

`npx hardhat test`

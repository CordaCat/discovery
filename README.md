# The Challenge

Write a new Ethereum smart contract with the following requirements:

- [] It must keep track of an unbounded number of rock-paper-scissors
  games;
- [] Each game should be identifiable by a unique ID;
- [] Once two players commit their move to the same game ID, the game
  is now resolved, and no further moves can be played;
- [] Each game, once started, needs both moves to be played within 48h.
  If that doesn’t happen, the first player can get a full refund;
- [] To play, both users have to commit a predetermined amount of ETH (to
  be decided by the contract deployer);
- [] It should be impossible for the second player to figure out what the
  first player’s move was before both moves are committed;
- [] When a game is finished, the winner gets to take the full pot;
- [] In the event of a draw, each player can recover only 50% of their
  locked amount. The other 50% are to be distributed to the next game
  that finishes;
- [] The repo should include some unit tests to simulate and test the main
  behaviors of the game.

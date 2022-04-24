//SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/// @title A rock, paper, scissors Dapp
/// @author Jalal Hannan
/// @notice You must set an entry fee when deploying this contract
contract RockPaperScissors {
    uint256 entryFee;

    constructor(uint256 _entryFee) payable {
        entryFee = _entryFee;
    }

    enum Move {
        rock,
        paper,
        scissors,
        notRevealed
    }

    enum PlayerStatus {
        STATUS_WIN,
        STATUS_LOSE,
        STATUS_TIE,
        STATUS_PENDING
    }

    struct Player {
        address payable addr;
        uint256 playerBetAmount;
        bytes32 hashedMove;
        Move move;
        PlayerStatus playerStatus;
    }

    enum GameStatus {
        STATUS_NOT_STARTED,
        STATUS_IN_PROGRESS,
        STAUS_COMPLETE,
        STATUS_ERROR
    }

    struct Game {
        Player host;
        Player guest;
        uint256 potAmount;
        GameStatus gameStatus;
    }

    /// @notice Stores instances on a Game struct in a mapping, can be accessed using games[gameId]
    mapping(uint256 => Game) public games;

    /// @notice Stores the next game Id, is incremented(in createGame function) everytime a game is created
    uint256 nextGameId = 0;

    /// @notice Stores the rollover amount in case there is a draw
    uint256 public rolloverPot = 0;

    // Functions: createGame, joinGame, revealMoves, compareMoves, payout, requestRefund

    /// @notice Check if move is valid
    modifier isValidMove(Move _move) {
        require(
            (_move == Move.rock) ||
                (_move == Move.paper) ||
                (_move == Move.scissors)
        );
        _;
    }

    /// @notice This function is used to created a salted hash of the move in order to preserve privacy of a players move
    function getSaltedHash(Move _move, string memory _salt)
        public
        pure
        isValidMove(_move)
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_move, _salt));
    }

    // Events

    // Errors
}

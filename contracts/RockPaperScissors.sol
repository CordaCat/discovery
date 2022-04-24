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

    // Data Types
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

    /// @notice Stores the next game Id, is incremented everytime a game is created
    uint256 nextGameId = 0;

    // Functions: createGame, joinGame, revealMoves, compareMoves, payout, requestRefund

    // Events

    // Errors
}

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

    /// @notice Stores instances of a Game struct in a mapping, can be accessed using games[gameId]
    mapping(uint => Game) public games;

    /// @notice Stores the next game Id, is incremented(in createGame function) everytime a game is created
    uint public nextGameId = 0;

    /// @notice Stores the rollover amount in case there is a draw
    uint256 public rolloverPot = 0;

    /// @notice Check if move is valid, we restrict the move to rock, paper or scissors
    /// @param _move is the player move
    modifier isValidMove(Move _move) {
        require(
            (_move == Move.rock) ||
                (_move == Move.paper) ||
                (_move == Move.scissors)
        );
        _;
    }

    /// @notice This function is used to created a salted hash of the move in order to preserve privacy of a players move
    /// @param _move is the player move, _salt a password provided by the user
    function getSaltedHash(Move _move, string memory _salt)
        public
        pure
        isValidMove(_move)
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_move, _salt));
    }

    /// @notice This function allows a user to create a game, they must provide a salted hash of their move (from getSaltedHash) and add the entry fee
    /// @param _hashedMove is the salted hash of the players move
    /// @dev We temporarily assign the player guest struct fields addr and _hashedMove with the same values as their respective player host struct fields
    function createGame(bytes32 _hashedMove)
        public
        payable
        returns (uint gameId)
    {
        require(msg.value == entryFee, "Please provide the exact entry fee");
        games[nextGameId] = Game({
            host: Player({
                addr: payable(msg.sender),
                playerBetAmount: msg.value,
                hashedMove: _hashedMove,
                move: Move.notRevealed,
                playerStatus: PlayerStatus.STATUS_PENDING
            }),
            guest: Player({
                addr: payable(msg.sender),
                playerBetAmount: 0,
                hashedMove: _hashedMove,
                move: Move.notRevealed,
                playerStatus: PlayerStatus.STATUS_PENDING
            }),
            potAmount: msg.value,
            gameStatus: GameStatus.STATUS_NOT_STARTED
        });
        gameId = nextGameId;
        nextGameId = nextGameId + 1;
    }

    /// @notice This function allows a user to join a game
    /// @param _gameId is the id of the game to join and _hashedMove is the salted hash of the players move
    function joinGame(uint _gameId, bytes32 _hashedMove) public payable {
        require(
            games[_gameId].gameStatus == GameStatus.STATUS_NOT_STARTED &&
                msg.value == entryFee,
            "Please check game id and ensure you have sent the exact entry fee"
        );
        games[_gameId].guest = Player({
            addr: payable(msg.sender),
            playerBetAmount: msg.value,
            hashedMove: _hashedMove,
            move: Move.notRevealed,
            playerStatus: PlayerStatus.STATUS_PENDING
        });
        games[_gameId].potAmount = games[_gameId].potAmount + msg.value;
        games[_gameId].gameStatus = GameStatus.STATUS_IN_PROGRESS;
    }

    // Add reveal move function
    // Add compare move function
    // Add payout function
    // Add request refund function
}

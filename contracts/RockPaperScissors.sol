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
        STATUS_COMPLETE,
        STATUS_ERROR
    }

    struct Game {
        Player host;
        Player guest;
        uint256 potAmount;
        GameStatus gameStatus;
        uint createdAt;
    }

    /// @notice Stores instances of a Game struct in a mapping, can be accessed using games[gameId]
    mapping(uint => Game) public games;

    /// @notice Stores the next game Id, is incremented(in createGame function) every time a game is created
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
    /// @param _move is the player move
    /// @param _salt a password provided by the user
    /// @return a salted hash of the players move
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
    /// @return gameId is the index of the newly created game within the games mapping
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
            createdAt: block.timestamp,
            gameStatus: GameStatus.STATUS_NOT_STARTED
        });
        gameId = nextGameId;
        nextGameId += 1;
    }

    /// @notice This function allows a user to join a game
    /// @param _gameId is the index of the game within the games mapping
    /// @param _hashedMove is the salted hash of the players move
    function joinGame(uint _gameId, bytes32 _hashedMove) public payable {
        require(
            games[_gameId].gameStatus == GameStatus.STATUS_NOT_STARTED &&
                msg.value == entryFee,
            "Please check the gameId is valid and ensure you have sent the exact entry fee"
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

    /// @notice Ensures that the caller is a player in the game
    /// @param _gameId is the index of the game within the games mapping
    modifier isPlayer(uint _gameId, address sender) {
        require(
            sender == games[_gameId].host.addr ||
                sender == games[_gameId].guest.addr,
            "Only a game player can call this function"
        );
        _;
    }

    /// @notice Ensures that the caller is the host of the game
    /// @param _gameId is the index of the game within the games mapping
    modifier isHost(uint _gameId, address sender) {
        require(
            sender == games[_gameId].host.addr,
            "Only the Game host can call this function"
        );
        _;
    }

    /// @dev Helper function to compare player moves
    /// @param _gameId is the index of the game within the games mapping
    function compareMoves(uint _gameId) private {
        uint8 host = uint8(games[_gameId].host.move);
        uint8 guest = uint8(games[_gameId].guest.move);

        if (guest == host) {
            games[_gameId].host.playerStatus = PlayerStatus.STATUS_TIE;
            games[_gameId].guest.playerStatus = PlayerStatus.STATUS_TIE;
        } else if ((guest + 1) % 3 == host) {
            games[_gameId].host.playerStatus = PlayerStatus.STATUS_WIN;
            games[_gameId].guest.playerStatus = PlayerStatus.STATUS_LOSE;
        } else if ((host + 1) % 3 == guest) {
            games[_gameId].host.playerStatus = PlayerStatus.STATUS_LOSE;
            games[_gameId].guest.playerStatus = PlayerStatus.STATUS_WIN;
        } else {
            games[_gameId].gameStatus = GameStatus.STATUS_ERROR;
        }
    }

    /// @notice Ensures that the caller is a player in the game
    /// @param _gameId is the index of the game within the games mapping
    /// @param _move is the unhashed player move
    /// @param _salt is the players password
    function revealMove(
        uint _gameId,
        Move _move,
        string memory _salt
    ) public isPlayer(_gameId, msg.sender) {
        require(
            games[_gameId].host.addr != games[_gameId].guest.addr,
            "You are the only person in the game, you cannot reveal until someone joins!"
        );
        if (msg.sender == games[_gameId].host.addr) {
            require(
                games[_gameId].host.hashedMove ==
                    keccak256(abi.encodePacked(_move, _salt)),
                "Incorrect entry - Please check your move and password again!"
            );
            games[_gameId].host.move = _move;
        } else if (msg.sender == games[_gameId].guest.addr) {
            require(
                games[_gameId].guest.hashedMove ==
                    keccak256(abi.encodePacked(_move, _salt)),
                "Incorrect entry - Please check your move and password again!"
            );
            games[_gameId].guest.move = _move;
        }
        if (
            games[_gameId].host.move != Move.notRevealed &&
            games[_gameId].guest.move != Move.notRevealed
        ) {
            compareMoves(_gameId);
        }
    }

    /// @notice Payout function initiates a payout once both players have revealed their moves
    /// @param _gameId is the index of the game within the games mapping
    function payout(uint _gameId) public payable isPlayer(_gameId, msg.sender) {
        require(
            (games[_gameId].host.move != Move.notRevealed &&
                games[_gameId].guest.move != Move.notRevealed),
            "Both players must reveal their moves before a payout can be initiated"
        );
        if (
            games[_gameId].host.playerStatus == PlayerStatus.STATUS_TIE &&
            games[_gameId].guest.playerStatus == PlayerStatus.STATUS_TIE
        ) {
            games[_gameId].host.addr.transfer((games[_gameId].potAmount) / 4);
            games[_gameId].guest.addr.transfer((games[_gameId].potAmount) / 4);
            rolloverPot = rolloverPot + ((games[_gameId].potAmount) / 2);
        } else if (
            games[_gameId].host.playerStatus == PlayerStatus.STATUS_WIN
        ) {
            games[_gameId].host.addr.transfer(
                games[_gameId].potAmount + rolloverPot
            );
            rolloverPot = 0;
        } else if (
            games[_gameId].guest.playerStatus == PlayerStatus.STATUS_WIN
        ) {
            games[_gameId].guest.addr.transfer(
                games[_gameId].potAmount + rolloverPot
            );
            rolloverPot = 0;
        } else {
            games[_gameId].host.addr.transfer(
                games[_gameId].host.playerBetAmount
            );
            games[_gameId].guest.addr.transfer(
                games[_gameId].guest.playerBetAmount
            );
        }

        games[_gameId].gameStatus = GameStatus.STATUS_COMPLETE;
    }

    function requestRefund(uint _gameId)
        public
        payable
        isHost(_gameId, msg.sender)
    {
        require(
            block.timestamp >= (games[_gameId].createdAt + 172800),
            "You must wait at least 48 hours before requesting a refund!"
        );
        require(
            games[_gameId].gameStatus == GameStatus.STATUS_IN_PROGRESS,
            "Game is not in progress!"
        );
        require(
            games[_gameId].guest.playerStatus != PlayerStatus.STATUS_WIN,
            "You cannot request a refund because the guest won!"
        );
        games[_gameId].host.addr.transfer(games[_gameId].host.playerBetAmount);
    }
}

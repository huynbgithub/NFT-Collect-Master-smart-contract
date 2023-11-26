// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BigPictureFactory.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@bisonai/orakl-contracts/src/v0.1/VRFConsumerBase.sol";
import {IVRFCoordinator} from "@bisonai/orakl-contracts/src/v0.1/interfaces/IVRFCoordinator.sol";

contract BigPicture is VRFConsumerBase, ERC721URIStorage, Ownable {

    receive() external payable {
    }

    IVRFCoordinator COORDINATOR;
    uint64 sAccountId;
    bytes32 sKeyHash;
    uint32 sCallbackGasLimit = 300000;
    uint32 sNumWords = 1;
    uint public randomIndex;

    uint256 public _nextTokenId;
    mapping (uint256 tokenId => bool) public onSale;
    mapping (uint256 tokenId => uint256) public tokenPrice;

    bool public onGoing;
    address public winner;

    string public bigPictureName;
    string public image;
    string[] public picturePieces;
    uint256 public rewardPrice;
    uint256 public mintPrice;
    BigPictureFactory public factory;

    constructor (
        string memory _name,
        string memory _image,
        string[] memory _picturePieces,
        uint256 _rewardPrice,
        uint256 _mintPrice,
        address _factoryAddress
    )
    VRFConsumerBase(0xDA8c0A00A372503aa6EC80f9b29Cc97C454bE499) 
    ERC721("CollectMasterToken", "CMT")
    Ownable(msg.sender)
    payable
    {
        COORDINATOR = IVRFCoordinator(0xDA8c0A00A372503aa6EC80f9b29Cc97C454bE499);
        sAccountId = 134;
        sKeyHash = 0xd9af33106d664a53cb9946df5cd81a30695f5b72224ee64e798b278af812779c;
        bigPictureName = _name;
        image= _image;
        picturePieces = _picturePieces;
        rewardPrice = _rewardPrice;
        mintPrice = _mintPrice;
        factory = BigPictureFactory(_factoryAddress);
        factory.addBigPicture(this);
        randomIndex = 0;
        onGoing = true;
    }

    modifier isOnGoing {
        require(onGoing == true, "The game was ended!");
        _;
    }

    modifier notOwner {
        require(msg.sender != owner(), "Game Creator is now allowed to play!");
        _;
    }

    function getWinner() public view returns (address) {
        return winner;
    }

    function getOnGoingState() public view returns (bool) {
        return onGoing;
    }

    function getSingleBigPicture() public view returns (BigPictureData memory) {
        return BigPictureData(address(this), bigPictureName, image, picturePieces, rewardPrice, mintPrice);
    }

    function getYourTokens(address owner) isOnGoing public view returns (TokenData[] memory) {
        TokenData[] memory tokenList = new TokenData[](_nextTokenId);

        uint256 tokenCount = 0;

        for (uint256 i = 0; i < _nextTokenId; i++) {
            if (ownerOf(i) == owner) {
                tokenList[tokenCount] = TokenData(i, tokenURI(i), onSale[i], tokenPrice[i]);
                tokenCount++;
            }
        }

        assembly {
            mstore(tokenList, tokenCount)
        }

        return tokenList;
    }

    function requestRandomWords() public returns (uint256 requestId) {
        requestId = COORDINATOR.requestRandomWords(
            sKeyHash,
            sAccountId,
            sCallbackGasLimit,
            sNumWords
        );
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        randomIndex = randomWords[0] % picturePieces.length;
        uint256 tokenId = _nextTokenId++;
        _mint(tempAddress, tokenId);
        _setTokenURI(tokenId, picturePieces[randomIndex]);
        onSale[tokenId] = false;
        tokenPrice[tokenId] = 0;
    }

    address public tempAddress;

    function mintCMT () isOnGoing notOwner public payable {
        require(msg.sender.balance >= mintPrice, "Balance is not enough!");
        require(msg.value == mintPrice, "Value must be equal Mint Price!");
        tempAddress = msg.sender;
        payable(owner()).transfer(msg.value);
        requestRandomWords();
    }

    function mintCMTDemo() isOnGoing notOwner public payable {
        require(msg.sender.balance > mintPrice, "Balance is not enough!");
        require(msg.value == mintPrice, "Value must equal to Mint Price!");
        tempAddress = msg.sender;
        payable(owner()).transfer(msg.value);
        for (uint256 i = 0; i < picturePieces.length; i++) {
            uint256 tokenId = _nextTokenId++;
            _mint(tempAddress, tokenId);
            _setTokenURI(tokenId, picturePieces[i]);
            onSale[tokenId] = false;
            tokenPrice[tokenId] = 0;
        }
    }

    modifier isTokenOwner(uint256 tokenId) {
        require(msg.sender == ownerOf(tokenId), "You must be the token's owner!");
        _;
    }

    modifier notTokenOwner(uint256 tokenId) {
        require(msg.sender != ownerOf(tokenId), "You must not be the token's owner!");
        _;
    }

    function putTokenOnSale(uint256 tokenId, uint256 price) public isTokenOwner(tokenId) {
        onSale[tokenId] = true;
        tokenPrice[tokenId] = price;
        approve(address(this), tokenId);
    }

    function unSell(uint256 tokenId) public isTokenOwner(tokenId) {
        onSale[tokenId] = false;
        tokenPrice[tokenId] = 0;
    }

    function getTokensOnSale (address viewer) isOnGoing public view returns (TokenData[] memory) {
        TokenData[] memory tokenList = new TokenData[](_nextTokenId);

        uint256 tokenCount = 0;

        for (uint256 i = 0; i < _nextTokenId; i++) {
            if (onSale[i] == true && ownerOf(i) != viewer) {
                tokenList[tokenCount] = TokenData(i, tokenURI(i), onSale[i], tokenPrice[i]);
                tokenCount++;
            }
        }

        assembly {
            mstore(tokenList, tokenCount)
        }

        return tokenList;
    }

    function purchaseToken(uint256 tokenId) public notTokenOwner(tokenId) notOwner payable {
        require(msg.sender.balance > tokenPrice[tokenId], "Balance is not enough!");
        require(msg.value == tokenPrice[tokenId], "Value must equal to Selling Price!");

        address previousOwner = ownerOf(tokenId);

        payable(previousOwner).transfer(msg.value);
        this.transferFrom(previousOwner, msg.sender, tokenId);
        onSale[tokenId] = false;
        tokenPrice[tokenId] = 0;
    }

    function endGame(address winnerAddress) public {
        payable(winnerAddress).transfer(rewardPrice);
        onGoing = false;
    }

    function claimReward() public isOnGoing winningCondition notOwner {
        this.endGame(msg.sender);
        winner = msg.sender;
    }

    modifier winningCondition() {
        TokenData[] memory tokenList = getYourTokens(msg.sender);

        bool[] memory isExisting = new bool[](picturePieces.length);

        for (uint256 piece = 0; piece < picturePieces.length; piece++) {
            for (uint256 i = 0; i < tokenList.length; i++) {
                if (keccak256(bytes(tokenList[i].image)) == keccak256(bytes(picturePieces[piece]))) {
                    isExisting[piece] = true;
                }
            }
        }

        for (uint256 piece = 0; piece < picturePieces.length; piece++) {
                if (isExisting[piece] == false) {
                    revert("Incomplete Collection!");
                }
        }
        _;
    }

}

struct BigPictureData {
    address bigPictureAddress;
    string name;
    string image;
    string[] picturePieces;
    uint256 rewardPrice;
    uint256 mintPrice;
}

struct TokenData {
    uint256 id;
    string image;
    bool onSale;
    uint256 tokenPrice;
}
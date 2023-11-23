// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BigPictureFactory.sol";

import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "@bisonai/orakl-contracts/src/v0.1/VRFConsumerBase.sol";
import {IVRFCoordinator} from "@bisonai/orakl-contracts/src/v0.1/interfaces/IVRFCoordinator.sol";

contract BigPicture is VRFConsumerBase, ERC721URIStorage, Ownable {

    // event ReceiveCalled(uint amount);

    receive() external payable {
        // emit ReceiveCalled(msg.value);
    }

    IVRFCoordinator COORDINATOR;
    uint64 sAccountId;
    bytes32 sKeyHash;
    uint32 sCallbackGasLimit = 300000;
    uint32 sNumWords = 1;
    uint public randomIndex;

    uint256 public _nextTokenId;
    mapping (uint256 => bool) public onSale;
    mapping (uint256 => uint256) public tokenPrice;

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
    }

    function getSingleBigPicture() public view returns (BigPictureData memory) {
        return BigPictureData(address(this), bigPictureName, image, picturePieces, rewardPrice, mintPrice);
    }

    function getYourTokens(address owner) public view returns (TokenData[] memory) {
        TokenData[] memory tokenList = new TokenData[](_nextTokenId);

        for (uint256 i = 0; i < _nextTokenId; i++) {
            if (ownerOf(i) == owner) {
                tokenList[i] = TokenData(i, tokenURI(i), onSale[i], tokenPrice[i]);
            }
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

    function mintCMT () public payable {
        tempAddress = msg.sender;
        payable(address(this)).transfer(mintPrice);
        requestRandomWords();
    }

    function mintCMTDemo() public payable {
        tempAddress = msg.sender;
        payable(address(this)).transfer(mintPrice * 9);
        for (uint256 i = 0; i < picturePieces.length; i++) {
            uint256 tokenId = _nextTokenId++;
            _mint(tempAddress, tokenId);
            _setTokenURI(tokenId, picturePieces[i]);
            onSale[tokenId] = false;
            tokenPrice[tokenId] = 0;
        }
    }

    function putTokenOnSale(uint256 id, uint256 price) public {
        onSale[id] = true;
        tokenPrice[id] = price;
    }

    function getTokensOnSale () public view returns (TokenData[] memory) {
        TokenData[] memory tokenList = new TokenData[](_nextTokenId);

        uint256 tokenCount = 0;

        for (uint256 i = 0; i < _nextTokenId; i++) {
            if (onSale[i] == true && ownerOf(i) != msg.sender) {
                tokenList[tokenCount] = TokenData(i, tokenURI(i), onSale[i], tokenPrice[i]);
                tokenCount++;
            }
        }
        return tokenList;
    }

    function purchaseToken(uint256 tokenId) public {
        payable(msg.sender).transfer(tokenPrice[tokenId]);
        payable(ownerOf(tokenId)).transfer(tokenPrice[tokenId]);
        transferFrom(msg.sender, ownerOf(tokenId), tokenId);
    }

    SubmittedInfo[] public submitList;

    function submitTokens (SubmittedInfo memory submittedItem) public {
        submitList.push(submittedItem);
    }

    function getSubmittedList() public view returns (SubmittedInfo[] memory){
        return submitList;
    }


    //Reward Winner
    function tranferRewardToWinner(address winnerAddress) public {
            payable(winnerAddress).transfer(rewardPrice);
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

struct SubmittedInfo {
    address owner;
    address[] tokenList;
}
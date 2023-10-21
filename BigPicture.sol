// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BigPictureFactory.sol";

import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "@bisonai/orakl-contracts/src/v0.1/VRFConsumerBase.sol";
import {IVRFCoordinator} from "@bisonai/orakl-contracts/src/v0.1/interfaces/IVRFCoordinator.sol";

contract BigPicture is VRFConsumerBase, ERC721URIStorage, Ownable {

    IVRFCoordinator COORDINATOR;
    uint64 public sAccountId;
    bytes32 public sKeyHash;
    uint32 sCallbackGasLimit = 300000;
    uint32 sNumWords = 1;
    uint public randomIndex;

    uint256 private _nextTokenId;

    string bigPictureName;
    string image;
    string[] picturePieces;
    uint256 rewardPrice;
    BigPictureFactory factory;

    // PictureToken[] thisPictureAllTokens;

    constructor (
        string memory _name,
        string memory _image,
        string[] memory _picturePieces,
        uint256 _rewardPrice,
        address _factoryAddress
    )
    VRFConsumerBase(0x6B4c0b11bd7fE1E9e9a69297347cFDccA416dF5F) 
    ERC721("CollectMasterToken", "CMT")
    Ownable(msg.sender)
    {
        COORDINATOR = IVRFCoordinator(0x6B4c0b11bd7fE1E9e9a69297347cFDccA416dF5F);
        sAccountId = 197;
        sKeyHash = 0xd9af33106d664a53cb9946df5cd81a30695f5b72224ee64e798b278af812779c;
        bigPictureName = _name;
        image= _image;
        picturePieces = _picturePieces;
        rewardPrice = _rewardPrice;
        factory = BigPictureFactory(_factoryAddress);
        factory.addBigPicture(this);
        randomIndex = 0;
    }

    function getSingleBigPicture() public view returns (BigPictureData memory) {
        return BigPictureData(bigPictureName, image, picturePieces, rewardPrice);
    }

    // function getThisBigPictureAllTokens() public view returns (PictureToken[] memory) {
    //     return thisPictureAllTokens;
    // }

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
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, picturePieces[randomIndex]);
    }

    function mintCMT () public {
        requestRandomWords();
    }


    //Reward Winner
    function tranferRewardToWinner(address winnerAddress) public {
            payable(winnerAddress).transfer(rewardPrice);
    }
 
}

struct BigPictureData {
    string name;
    string image;
    string[] picturePieces;
    uint256 rewardPrice;
}
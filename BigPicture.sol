// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BigPictureFactory.sol";
import "./Picture.sol";
import "./PictureToken.sol";

contract BigPicture {

    string name;
    string image;
    Picture[] picturePieces;
    uint256 rewardPrice;
    BigPictureFactory factory;

    PictureToken[] thisPictureAllTokens;

    constructor (
        string memory _name,
        string memory _image,
        Picture[] memory _picturePieces,
        uint256 _rewardPrice,
        address _factoryAddress
    ) {
        name = _name;
        image= _image;
        picturePieces = _picturePieces;
        rewardPrice = _rewardPrice;
        factory = BigPictureFactory(_factoryAddress);
    }

    function getSingleBigPicture() public view returns (BigPictureData memory) {
        return BigPictureData(name, image, picturePieces);
    }

    function getThisBigPictureAllTokens() public view returns (PictureToken[] memory) {
        return thisPictureAllTokens;
    }

    //Create ERC721 Token
    function createPictureToken () public {
        PictureToken newPictureToken = new PictureToken(
            msg.sender,
            picturePieces[0]
        );
        factory.addPictureToken(newPictureToken);
        thisPictureAllTokens.push(newPictureToken);
    }

    //Reward Winner
    // function tranferRewardToWinner(address winnerAddress) public {
    //         payable(winnerAddress).transfer(rewardPrice);
    // }

    //Find the winner
    // function findWinner() public {
    // 
    // }
 
}

struct BigPictureData {
    string name;
    string image;
    Picture[] picturePieces;
}
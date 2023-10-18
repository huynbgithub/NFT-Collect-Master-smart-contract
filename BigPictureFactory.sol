// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BigPicture.sol";
import "./Picture.sol";
import "./PictureToken.sol";

contract BigPictureFactory {

    BigPicture[] public allBigPictures;
    PictureToken[] public allPictureTokens;

    function getAllBigPictures() public view returns (BigPicture[] memory) {
        return allBigPictures;
    }

    function getAllPictureTokens() public view returns (PictureToken[] memory) {
        return allPictureTokens;
    }

    function getAllYourPictureTokens(address yourAddress) public view returns (PictureToken[] memory) {
        PictureToken[] memory allYourPictureTokens = new PictureToken[](
            allPictureTokens.length
        );
        uint32 allYourPictureTokensCount = 0;

        for (uint32 i = 0; i < allPictureTokens.length; i++) {
            if (allPictureTokens[i].owner() == yourAddress) {
                allYourPictureTokens[allYourPictureTokensCount] = allPictureTokens[i];
                allYourPictureTokensCount++;
            }
        }

        return allYourPictureTokens;
    }

    function addPictureToken(PictureToken token) public {
        allPictureTokens.push(token);
    }
 
    function createBigPicture(
        string memory _name,
        string memory _image,
        Picture[] memory _picturePart,
        uint256 _rewardPrice
    ) private {
        BigPicture newBigPicture = new BigPicture(
            _name,
            _image,
            _picturePart,
            _rewardPrice,
            address(this)
        );
        allBigPictures.push(newBigPicture);
    }

}
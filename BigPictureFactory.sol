// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BigPicture.sol";
import "./Picture.sol";

contract BigPictureFactory {
    BigPicture[] private allBigPictures;

    function getAllBigPictures() public view returns (BigPicture[] memory) {
        return allBigPictures;
    }
 
    function createBigPicture(
        string memory _name,
        string memory _image,
        Picture[] memory _picturePart
    ) public {
        BigPicture newBigPicture = new BigPicture(
            _name,
            _image,
            _picturePart
        );
        allBigPictures.push(newBigPicture);
    }

}
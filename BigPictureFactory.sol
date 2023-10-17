// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BigPicture.sol";

contract BigPictureFactory {
    BigPicture[] public deployedBigPictures;

    function createBigPicture(
        string memory _name,
        string memory _image
    ) public {
        BigPicture newBigPicture = new BigPicture(
            _name,
            _image
        );
        deployedBigPictures.push(newBigPicture);
    }
}
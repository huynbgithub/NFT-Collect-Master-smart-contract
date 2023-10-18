// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Picture.sol";

contract BigPicture {

    string name;
    string image;
    Picture[] picturePart;

    constructor (
        string memory _name,
        string memory _image,
        Picture[] memory _picturePart
    ) {
        name = _name;
        image= _image;
        picturePart = _picturePart;
    }

    function getSingleBigPicture() public view returns (BigPictureData memory) {
        return BigPictureData(name, image, picturePart);
    }
 
}

struct BigPictureData {
    string name;
    string image;
    Picture[] picturePart;
}
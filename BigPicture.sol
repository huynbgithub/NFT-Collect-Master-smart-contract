// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BigPicture {

    string private name;
    string private image;

    constructor (
        string memory _name,
        string memory _image
    ) {
        name = _name;
        image= _image;
    }
}
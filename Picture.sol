// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Picture {

    uint256 order;
    string image;

    constructor (
        uint256 _order,
        string memory _image
    ) {
        order = _order;
        image= _image;
    }
}
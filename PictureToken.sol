// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

import "./Picture.sol";

contract PictureToken is Ownable {

    Picture props;

    constructor(
        address initialOwner,
        Picture _props
        )
        Ownable(initialOwner)
    {
        props = _props;
    }

}
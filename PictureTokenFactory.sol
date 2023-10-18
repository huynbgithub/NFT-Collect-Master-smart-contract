// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

import "./Picture.sol";
import "./PictureToken.sol";

contract PictureTokenFactory {

    Picture props;

    function createPictureToken (
        Picture _props
    ) public {       
        PictureToken newPictureToken = new PictureToken(
            msg.sender,
            _props
        );
    }
}
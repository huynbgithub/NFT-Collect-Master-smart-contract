// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

import "./Picture.sol";

contract PictureToken is ERC721, Ownable {

    Picture props;
    uint256 private price;
    bool onSale;

    constructor(address initialOwner, Picture _props)
    ERC721("PictureToken", "PT")
    Ownable(initialOwner)
    {
        props = _props;
        price = 0;
        onSale = false;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://pieceTokenBaseURI";
    }

    function getSinglePictureToken() private view returns(tokenData memory) {
        return tokenData(Ownable.owner(), props, price, onSale);
    }

    function getPrice() private view returns(uint256) {
        return price;
    }

    function setPrice(uint256 _price) private onlyOwner {
        price = _price;
    }

    function putOnSale() private onlyOwner {
        onSale = true;
    }

    function notPutOnSale() private onlyOwner {
        onSale = false;
    }

    function purchase() private {
        payable(msg.sender).transfer(price);
        transferOwnership(msg.sender);
        price = 0;
        onSale = false;
    }

}

struct tokenData {
    address ownerAddress;
    Picture props;
    uint256 price;
    bool onSale;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

import "./Picture.sol";

contract PictureToken is ERC721, Ownable {

    Picture props;
    uint256 public price;
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

    function getSinglePictureToken() public view returns(tokenData memory) {
        return tokenData(Ownable.owner(), props, price, onSale);
    }

    function getPrice() public view returns(uint256) {
        return price;
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function putOnSale() public onlyOwner {
        onSale = true;
    }

    function notPutOnSale() public onlyOwner {
        onSale = false;
    }

    function purchase() public {
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
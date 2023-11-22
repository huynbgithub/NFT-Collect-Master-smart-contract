// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./BigPicture.sol";

contract BigPictureFactory is Ownable {

    constructor() Ownable(msg.sender) {}

    BigPicture[] public allBigPictures;

    function getAllBigPictures() public view returns (BigPicture[] memory) {
        return allBigPictures;
    }

    function getAllBigPictureDatas()
        external
        view
        returns (BigPictureData[] memory)
    {
        BigPictureData[] memory bigPictureDatas = new BigPictureData[](
            allBigPictures.length
        );

        for (uint i = 0; i < allBigPictures.length; i++) {
            bigPictureDatas[i] = allBigPictures[i].getSingleBigPicture();
        }
        return bigPictureDatas;
    }

    function addBigPicture(BigPicture bigPicture) public {
        allBigPictures.push(bigPicture);
    }
 
    function createBigPicture(
        string memory _name,
        string memory _image,
        string[] memory _picturePart,
        uint256 _rewardPrice,
        uint256 _mintPrice
    ) public {
        new BigPicture(
            _name,
            _image,
            _picturePart,
            _rewardPrice,
            _mintPrice,
            address(this)
        );
    }

}
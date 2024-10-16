// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error NoNFTAvailable(uint256);

contract RunnanNFT is ERC721 {
    mapping(uint256 => string) tokenURIMap;

    constructor() ERC721("Liupengfei", "LPF") {
        tokenURIMap[1] = "ipfs://QmWZJXaTZBwhhzzWQv5AQmGZL8pPHzNyWAAhN3LoTx6TRD";
        tokenURIMap[2] = "ipfs://QmeAscvQmGyuEYcdMSVxFZUP5AyzeLa3ube7kDazfawRnJ";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return tokenURIMap[tokenId];
    }

    function mint(uint256 tokenId) public {
        if (tokenId <= 2) {
            _safeMint(msg.sender, tokenId);
        } else {
            revert NoNFTAvailable(tokenId);
        }
    }
} 
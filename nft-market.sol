// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { MarketToken, IMarketTokenReceiver } from "./market-token.sol";
import { RunnanNFT } from "./my-first-nft.sol";


contract NFTMarket is IMarketTokenReceiver {
    MarketToken public immutable marketToken;
    RunnanNFT public immutable runnanNFT;
    // tokenID => price
    mapping(uint256 => uint256) public listings;

    constructor(MarketToken _marketTokenAddr, RunnanNFT _nftAddr) {
        marketToken = _marketTokenAddr;
        runnanNFT = _nftAddr;
    }

    function _isNFTApproved(uint256 tokenId) private view returns(bool) {
        address nftOwner = runnanNFT.ownerOf(tokenId);
        return (
            nftOwner == address(this) || 
            runnanNFT.isApprovedForAll(nftOwner, address(this)) || 
            runnanNFT.getApproved(tokenId) == address(this)
        );
    }

    function _isNFTListed(uint256 tokenId) private view returns(bool) {
        return listings[tokenId] > 0;
    }

    modifier approvedNFT(uint256 tokenId) {
        address nftOwner = runnanNFT.ownerOf(tokenId);
        require(
            _isNFTApproved(tokenId), 
            "the NFT is not approved to the  NFTMarket"
        );
        _;
    }

    modifier allowanedToken(address account, uint256 amount) {
        uint256 _allownedToken = marketToken.allowance(account, address(this));
        require(
            _allownedToken >= amount,
            ("the Market token approved to the NFTMarket is not enough")
        );
        _;
    }

    modifier nftListed(uint256 tokenId) {
        require(_isNFTListed(tokenId), "the nft has not been listed");
        _;
    }

    event Listed(uint256 tokenId, uint256 price);
    event Purchased(uint256 tokenId);

    function list(uint256 tokenId, uint256 price) external approvedNFT(tokenId) {
        require(price > 0, "price must be larger than 0");
        require(runnanNFT.ownerOf(tokenId) == msg.sender, "only the owner of the NFT can list");
        require(listings[tokenId] == 0, "the NFT has been listed before");
        listings[tokenId] = price;
        emit Listed(tokenId, price);
    }

    function buyNFT(uint256 tokenId) external 
        approvedNFT(tokenId) 
        allowanedToken(msg.sender, listings[tokenId]) 
        nftListed(tokenId)  {
        require(listings[tokenId] > 0, "the nft has not been listed");
        uint256 price = listings[tokenId];
        address seller = runnanNFT.ownerOf(tokenId);
        address buyer = msg.sender;
        marketToken.transferFrom(buyer, seller, price);
        runnanNFT.safeTransferFrom(seller, buyer, tokenId);
        delete listings[tokenId];
        emit Purchased(tokenId);
    }

    function tokensReceived(address from, uint256 amount, bytes calldata data) external {
        require(msg.sender == address(marketToken), "Only the MarketToken Contract can call the hook");
        (uint256 tokenId) = abi.decode(data, (uint256));
        uint256 price = listings[tokenId];
        address seller = runnanNFT.ownerOf(tokenId);
        address buyer = from;
        require(_isNFTApproved(tokenId), "the NFT is not approved to the  NFTMarket");
        require(_isNFTListed(tokenId), "the NFT is not listed");
        require(amount >= price, "the amount you transform is not enough to buy the NFT");
        marketToken.transfer(seller, price);
        runnanNFT.safeTransferFrom(seller, buyer, tokenId);
        delete listings[tokenId];
        emit Purchased(tokenId);
    }
}
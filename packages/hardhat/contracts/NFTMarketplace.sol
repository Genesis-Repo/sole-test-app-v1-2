// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ERC721Enumerable, Ownable {
    // Structures to store NFT listing information
    struct Listing {
        address seller;
        uint256 price;
        bool active;
    }

    // Mapping to store listing of each NFT token id
    mapping(uint256 => Listing) private _listings;

    // Event to track when an NFT is listed for sale
    event NFTListed(address indexed seller, uint256 indexed tokenId, uint256 price);

    // Event to track when an NFT sale is completed
    event NFTSold(address indexed seller, address indexed buyer, uint256 indexed tokenId, uint256 price);

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    // Function to list an NFT for sale
    function listNFTForSale(uint256 tokenId, uint256 price) external {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Not approved to list NFT");
        require(!_listings[tokenId].active, "NFT already listed for sale");

        _listings[tokenId] = Listing({
            seller: _msgSender(),
            price: price,
            active: true
        });

        emit NFTListed(_msgSender(), tokenId, price);
    }

    // Function to buy an NFT listed for sale
    function buyNFT(uint256 tokenId) external payable {
        Listing storage listing = _listings[tokenId];
        require(listing.active, "NFT not listed for sale");
        require(msg.value >= listing.price, "Insufficient payment");

        address seller = listing.seller;

        _transfer(seller, _msgSender(), tokenId);
        listing.active = false;

        payable(seller).transfer(listing.price);
        emit NFTSold(seller, _msgSender(), tokenId, listing.price);
    }

    // Function to withdraw funds from the contract
    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // Function to get the details of an NFT listing
    function getListing(uint256 tokenId) external view returns (address seller, uint256 price, bool active) {
        Listing memory listing = _listings[tokenId];
        return (listing.seller, listing.price, listing.active);
    }
}
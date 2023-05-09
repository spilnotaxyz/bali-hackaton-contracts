// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Partnership is ERC721, ERC721Enumerable, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Partnership", "MTK") {}

    function _validSignature(
        bytes memory signature,
        address _addr
    ) public pure returns (address) {
        bytes32 msgHash = keccak256(abi.encodePacked(_addr));

        bytes32 hash = ECDSA.toEthSignedMessageHash(msgHash);
        address addr = ECDSA.recover(hash, signature);
        return addr;
    }

    function safeMint(address to) public {
        uint256 issuerTokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        uint256 partnerTokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _safeMint(msg.sender, issuerTokenId);
        _safeMint(to, partnerTokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        require(from == address(0), "Token is not transferable");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

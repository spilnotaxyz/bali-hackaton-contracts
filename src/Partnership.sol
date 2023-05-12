// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "forge-std/console.sol";

error ErrorFromNotASigner();
error ErrorSenderIsNotAPartner();
error ErrorTokenIsNotTransferable();
error ErrorTokenIsNotBurnable();

struct Colaboration {
    uint256 issuerTokenId;
    uint256 partnerTokenId;
}

contract Partnership is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    mapping(bytes32 => Colaboration[]) public partnerships;

    constructor() ERC721("Partnership", "PTSHP") {}

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function getPartnerRoute(
        address a,
        address b
    ) public pure returns (bytes32) {
        (address a1, address b1) = a > b ? (a, b) : (b, a);
        return keccak256(abi.encodePacked(a1, b1));
    }

    function _validSignature(
        bytes memory signature,
        address issuer,
        address partner
    ) public view returns (bool) {
        bytes32 msgHash = keccak256(abi.encodePacked(issuer, partner));
        bytes32 hash = ECDSA.toEthSignedMessageHash(msgHash);
        address addr = ECDSA.recover(hash, signature);

        if (issuer != addr) revert ErrorFromNotASigner();
        if (partner != msg.sender) revert ErrorSenderIsNotAPartner();

        return true;
    }

    function safeMint(
        address issuer,
        address partner,
        bytes memory signature,
        string memory uri
    ) public {
        if (_validSignature(signature, issuer, partner)) {
            uint256 issuerTokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            uint256 partnerTokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();

            _safeMint(issuer, issuerTokenId);
            _setTokenURI(issuerTokenId, uri);
            _safeMint(partner, partnerTokenId);
            _setTokenURI(partnerTokenId, uri);

            bytes32 route = getPartnerRoute(issuer, partner);
            partnerships[route].push(
                Colaboration({
                    issuerTokenId: issuerTokenId,
                    partnerTokenId: partnerTokenId
                })
            );
        }
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        revert ErrorTokenIsNotBurnable();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        if (from != address(0)) revert ErrorTokenIsNotTransferable();
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

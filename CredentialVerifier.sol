// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CredentialVerifier {

    modifier requiresCredential(
        string memory expectedCredential,
        bytes calldata proof,
        uint validUntil,
        uint approvedAt,
        uint maxAge
    ) {
        require (
            block.timestamp < validUntil,
            "Credential no longer valid"
        );

        require (
            block.timestamp < approvedAt + maxAge,
            "Approval not recent enough"
        );

        string memory sender = Strings.toHexString(uint256(uint160(msg.sender)), 20);
        
        require(
            SignatureChecker.isValidSignatureNow(
                0x559FfB9C4AB5A552Ed2Ea814A84e74D4CFA21d34,
                ECDSA.toEthSignedMessageHash(abi.encodePacked(Strings.toString(validUntil), ";", Strings.toString(approvedAt), ";", sender, ";", expectedCredential)),
                proof
            ),
            "Signature doesn't match"
        );
        
        _;
    }
}

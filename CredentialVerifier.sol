// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CredentialVerifier {
    modifier requiresCredential(
        string memory expectedCredential,
        bytes calldata proof,
        uint256 validUntil,
        uint256 approvedAt,
        uint256 maxAge,
        string memory fractalId
    ) {
        require(block.timestamp < validUntil, "Credential no longer valid");

        require(
            maxAge == 0 || block.timestamp < approvedAt + maxAge,
            "Approval not recent enough"
        );

        string memory sender = Strings.toHexString(
            uint256(uint160(msg.sender)),
            20
        );

        require(
            SignatureChecker.isValidSignatureNow(
                0xacD08d6714ADba531beFF582e6FD5DA1AFD6bc65,
                ECDSA.toEthSignedMessageHash(
                    abi.encodePacked(
                        sender,
                        ";",
                        fractalId,
                        ";",
                        Strings.toString(approvedAt),
                        ";",
                        Strings.toString(validUntil),
                        ";",
                        expectedCredential
                    )
                ),
                proof
            ),
            "Signature doesn't match"
        );

        _;
    }
}

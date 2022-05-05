// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract CredentialVerifier {
    modifier requiresCredential(
        string memory expectedCredential,
        bytes calldata signature
    ) {
        require(SignatureChecker.isValidSignatureNow(
            0xFBA3ee69ee4B25FfA8B1b8249Bd1745bcEAa11D7,
            ECDSA.toEthSignedMessageHash(abi.encodePacked(expectedCredential)),
            signature
        ));

        _;
    }
}

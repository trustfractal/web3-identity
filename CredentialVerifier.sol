// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract CredentialVerifier {
    modifier requiresCredential(
        string memory expectedCredential,
        bytes calldata signature
    ) {
        require(SignatureChecker.isValidSignatureNow(
            0x559FfB9C4AB5A552Ed2Ea814A84e74D4CFA21d34,
            ECDSA.toEthSignedMessageHash(abi.encodePacked(expectedCredential)),
            signature
        ));

        _;
    }
}

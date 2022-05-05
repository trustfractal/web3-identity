# Web3 Identity

## Credential Verifier

This method allows you to authorize transactions by including a signed credential in the transaction payload.

For example, for the credential `plus;not:ca,de,us` states this user cleared the KYC level `plus`, and is not a resident of Canada, Germany or the Unites States, Fractal would return the following signature: `0x9925305e1b30bb7f2ca11f21b0bc899893b1b34fea5f5f9b9d9cb9b99e3f3c8e094f8dafd53a7c41a549a15d8e0a2f665f3ed3dcf715302f7bbb89c0ee6307181b`

This verification adds approximately 8,000 gas to the transaction cost.

### Usage

Import our `CredentialVerifier.sol` contract to inherit its `requiresCredential` modifier. This enforces that the signature matches your expected credential, and has Fractal as the signer.

```
import "github.com/trustfractal/web3-identity/CredentialVerifier.sol";

contract Main is CredentialVerifier {
    function main(
        bytes calldata signature
    ) external requiresCredential("plus;not:ca,de,us", signature) {
        /* your logic goes here */
    }
}
```

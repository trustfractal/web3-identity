# Web3 Identity

## DID Registry Lookup

This method allows you to authorize transactions by looking up the sender in Fractal's DID registry.

For example, you may need your users to have cleared the KYC level `plus`, and not be residents of Canada, Germany or the United States.

The lookups below add approximately 26,000 gas to the transaction cost.

### Usage

Import our `FractalRegistry.sol` contract to use its ABI, set its address, and add a modifier such as the following to enforce the user is present in the registry and in the right lists.

```
import {FractalRegistry} from "github.com/trustfractal/web3-identity/FractalRegistry.sol";

contract Main {
    address public registryAddress = 0x38cB7800C3Fddb8dda074C1c650A155154924C73;

    modifier requiresRegistry(
        string memory allowedLevel,
        string[3] memory blockedCountries
    ) {
        bytes32 fractalId = FractalRegistry(registryAddress).getFractalId(msg.sender);
        require(fractalId != 0);
        
        require(FractalRegistry(registryAddress).isUserInList(fractalId, allowedLevel));

        for (uint256 i = 0; i < blockedCountries.length; i++) {
            string memory list = string(abi.encodePacked("residency_", blockedCountries[i]));
            require(!FractalRegistry(registryAddress).isUserInList(fractalId, list));
        }

        _;
    }

    function main() external requiresRegistry("plus", ["ca", "de", "us"]) {
        /* your logic goes here */
    }
}
```

## Credential Verifier

This method allows you to authorize transactions by including a signed credential in the transaction payload.

For example, for the credential `plus;not:ca,de,us` states this user cleared the KYC level `plus`, and is not a resident of Canada, Germany or the United States, Fractal would return the following signature: `0x9925305e1b30bb7f2ca11f21b0bc899893b1b34fea5f5f9b9d9cb9b99e3f3c8e094f8dafd53a7c41a549a15d8e0a2f665f3ed3dcf715302f7bbb89c0ee6307181b`

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

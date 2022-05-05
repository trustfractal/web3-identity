# Web3 Identity

## DID Registry Lookup

This method allows you to authorize transactions by looking up the sender in Fractal's DID registry.

![did-registry-lookup](https://user-images.githubusercontent.com/365821/166913376-18c369d0-c6a9-49f9-97cf-e8774675b8c1.png)

For example, you may need your users to have cleared the KYC level `plus`, and not be residents of Canada, Germany or the United States.

The lookups below add approximately 26,000 gas to the transaction cost.

### Usage

Import our `FractalRegistry.sol` contract, set its address, and add a modifier such as the following to enforce the user is present in the registry and in the right lists.

```solidity
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

## Credential Verification

This method allows you to authorize transactions by including a signed credential in the transaction payload.

![credential-verification](https://user-images.githubusercontent.com/365821/166913405-033ad50d-366c-4017-af9b-a8b84bf8821e.png)

For example, take the following credential: `1651759004;0x5b38da6a701c568545dcfcb03fcb875f56beddc4;plus;not:ca,de,us`.

It states that:
* it's valid until timestamp `1651759004`
* it's valid for sender `0x5b38da6a701c568545dcfcb03fcb875f56beddc4`
* this user cleared the KYC level `plus`
* this user is not a resident of Canada, Germany or the United States (country codes as per [ISO_3166-1_alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2))

Our API would return the following signature for this credential: `0x8ca40cd6e957b91cce730aa9f29584d9dd0bc19c2934cb94f12ffee20b38940d511c78d50ea55b281943542ba29f567581e08528479e07c432415eda35cb67581c`

This verification adds approximately 26,000 gas to the transaction cost.

### Usage

Import our `CredentialVerifier.sol` contract to inherit its `requiresCredential` modifier. This enforces that the signature matches your expected credential, and has Fractal as the signer.

```solidity
import "github.com/trustfractal/web3-identity/CredentialVerifier.sol";

contract Main is CredentialVerifier {
    function main(
        bytes calldata signature,
        uint validUntil
    ) external requiresCredential("plus;not:ca,de,us", signature, validUntil) {
        /* your logic goes here */
    }
}
```

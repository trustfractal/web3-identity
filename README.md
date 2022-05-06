# Identity for web3: privacy-preserving transaction authorization

**Power your smart contracts with verified identities — without accessing or managing personal data.**

Authorize transactions based on verified user uniqueness, reputation, and KYC/AML status:
* enable truly democratic governance with one-person-one vote;
* distribute airdrops fairly and avoid bot attacks;
* let artists autograph their NFTs to prove their authenticity;
* bring sybil-resistance to quadratic voting;
* unlock undercollateralized loans;
* ensure KYC/AML regulatory compliance.

Identity is how we get adoption. Early adopters take many risks, but most people are looking for a middle ground between the safe walled garden of Coinbase, and the wild west of liquidity farming. Making identity simple and secure is how we bring the next billion people into crypto and how we persuade institutions to deploy trillions of dollars of liquidity.

## DID Registry Lookup

**Authorize transactions by looking up their sender on Fractal's DID Registry.**
* no need to access or manage personal data
* no need to change the user flow
* no need for user interaction (e.g. airdrops)

![did-registry-lookup](https://user-images.githubusercontent.com/365821/166981861-3966c717-ffcc-4162-b6f0-5dd9e0ac4a76.png)

### Interface

A unique human has a unique Fractal ID, each with 1+ addresses and present in 0+ lists.

```
address [*]---[1] fractalId [*]---[*] listId
```

#### Getting the Fractal ID for an address

```solidity
bytes32 fractalId = getFractalId(address walletAddress);
```

#### Looking for a Fractal ID in a list

```solidity
bool presence = isUserInList(bytes32 fractaId, string listId);
```

##### Available lists

Every `fractalId` in the DID Registry corresponds to a unique human. Use cases requiring additional guarantees, such as KYC/AML, can also make use of the following lists.

| `listId` | Meaning |
| :--- | :--- |
| `basic` | Passed KYC level _basic_ |
| `light` | Passed KYC level _light_ |
| `plus` | Passed KYC level _plus_ |
| `residency_xy` | Resident in country _xy_ ([ISO_3166-1_alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country codes).<br>E.g. `residency_ca`, `residency_de`, `residency_us` |

### Setup

1. Import our `FractalRegistry.sol` contract and set its address.
1. Adapt the `requiresRegistry` `modifier` based on your KYC level and country requirements.

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
        /* your transaction logic goes here */
    }
}
```

### Usage

No further steps are required. Fractal keeps the DID Registry up to date. Build your transactions as you normally would.

```javascript
mainContract.methods.main().send({ from: account });
```

### Gas cost

The example above adds approximately 26k gas to the transaction cost. Gas usage increases with the number of lookups.

## Credential Verification

**Authorize transactions by including a Fractal signature in their payload.**
* no need to access or manage personal data
* minimal changes to user flow

![credential-verification](https://user-images.githubusercontent.com/365821/166981914-ed1d1888-9858-4989-8054-014a1937daae.png)

### Setup

1. Import our `CredentialVerifier.sol` contract to inherit its `requiresCredential` modifier.
1. Change the first argument of `requiresCredential` based on your KYC level and country requirements.
    * Format: `<kycLevel>;not:<comma-separated country codes>` ([ISO_3166-1_alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country codes).

```solidity
import "github.com/trustfractal/web3-identity/CredentialVerifier.sol";

contract Main is CredentialVerifier {
    function main(
        uint validUntil,
        bytes calldata signature
    ) external requiresCredential("plus;not:ca,de,us", validUntil, signature) {
        /* your transaction logic goes here */
    }
}
```

### Usage

1. Before a user interacts with your contract, ask them to sign a message authorizing Fractal to respond on their behalf.
1. Send this message and signature to Fractal's API, which returns an expiry timestamp (24 hours in the future) and a proof (Fractal's signature of the user's credential).
1. Use this timestamp and proof as arguments to your contract's method.

```javascript
const message = "I authorize you to get a proof from Fractal that I passed KYC level plus, and am not a resident of the following countries: CA, DE, US";
const signature = await ethereum.request({method: "personal_sign", params: [message, account]});

const { validUntil, proof } = await FractalAPI.getProof(signature);

mainContract.methods.main(validUntil, proof).send({ from: account });
```

### Gas cost

Credential verification adds approximately 26k gas to the transaction cost.

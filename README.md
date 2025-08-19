# sBTC KYC Vault Smart Contract

A Clarity smart contract enabling users to securely store encrypted KYC (Know Your Customer) data and manage access via non-fungible tokens (NFTs). This system empowers users to control and share access to their KYC information in a decentralized, verifiable manner.

---

## ✨ Features

* 🔐 **Encrypted KYC Data Storage**: Users can store and update their encrypted KYC data.
* 🎟️ **NFT-Based Access Control**: NFTs are minted to grant access to others.
* 🚫 **Revocation via Burn**: Access can be revoked by burning the NFT.
* 🔄 **NFT Transferability**: Access tokens (NFTs) can be transferred between principals.
* 📦 **Batch Access Granting**: Grant access to multiple users in a single transaction.
* 🔍 **Data Ownership & Access Verification**: Check who owns data or has access.
* 🧹 **KYC Data Deletion**: Users can delete their data and revoke access.
* ⏸️ **Pause Capability**: Contract can be paused for emergency shutdown (extensible with admin logic).

---

## 🧩 Smart Contract Components

### ✅ NFT Definition

```clarity
(define-non-fungible-token kyc-access uint)
```

* NFT used to grant access to a user's KYC data.

---

## 🗃️ Data Structures

| Name              | Type                        | Purpose                            |
| ----------------- | --------------------------- | ---------------------------------- |
| `kyc-vault`       | `map principal (buff 1024)` | Stores encrypted KYC data          |
| `access-grants`   | `map uint principal`        | Maps token ID to data owner        |
| `token-owners`    | `map uint principal`        | Tracks who holds each access token |
| `next-token-id`   | `data-var uint`             | Keeps track of NFT token IDs       |
| `contract-paused` | `data-var bool`             | Global pause flag for contract     |

---

## 📘 Function Overview

### 🔐 Data Management

| Function          | Description                       |
| ----------------- | --------------------------------- |
| `store-kyc-data`  | Stores user's encrypted KYC data  |
| `update-kyc-data` | Updates the user's encrypted data |
| `delete-kyc-data` | Deletes user's KYC data           |

---

### 🎟️ NFT Access Control

| Function             | Description                                |
| -------------------- | ------------------------------------------ |
| `grant-access`       | Mints NFT and grants access to a principal |
| `batch-grant-access` | Grants access to multiple principals       |
| `revoke-access`      | Revokes access by burning the token        |
| `transfer-access`    | Transfers NFT to another principal         |

---

### 🔎 Query Functions

| Function             | Description                                      |
| -------------------- | ------------------------------------------------ |
| `get-kyc-data`       | Retrieves KYC data if caller owns valid NFT      |
| `has-kyc-data`       | Checks if a user has KYC data                    |
| `get-token-owner`    | Gets NFT owner for given token ID                |
| `get-data-owner`     | Returns original data owner tied to token        |
| `has-access-to`      | Checks if a principal has access to a data owner |
| `get-total-tokens`   | Returns total NFTs minted                        |
| `is-contract-paused` | Returns if contract is paused                    |
| `can-store-data`     | Checks if storing is allowed (not paused)        |

---

## 🚨 Errors

| Constant             | Code | Meaning                                |
| -------------------- | ---- | -------------------------------------- |
| `ERR-NOT-AUTHORIZED` | 100  | Caller is not authorized               |
| `ERR-NOT-FOUND`      | 101  | Requested data not found               |
| `ERR-ALREADY-EXISTS` | 102  | Data already exists (unused currently) |
| `ERR-INVALID-TOKEN`  | 103  | Token ID is invalid or doesn't exist   |

---

## 🛑 Contract Pausing

* The `contract-paused` flag allows disabling certain features (like storing data) in emergencies.
* Admin controls can be extended for full pause/resume capabilities.

---

## 🔧 Example Workflow

1. **User stores encrypted KYC data**

   ```clarity
   (store-kyc-data 0x<encrypted-buff>)
   ```

2. **User grants access to another principal**

   ```clarity
   (grant-access 'SP...')
   ```

3. **Accessor retrieves data**

   ```clarity
   (get-kyc-data u1)
   ```

4. **User revokes access**

   ```clarity
   (revoke-access u1)
   ```

---

## ⚙️ Deployment Notes

* Ensure Clarity 2.0 is supported.
* NFT interface must be supported on the network.
* Use secure encryption standards off-chain; only encrypted blobs are stored on-chain.

---

## ✅ To-Do / Suggestions

* Add admin roles for pausing/resuming contract
* Add expiration for access tokens
* Improve batch-grant scalability (e.g. pagination)
* Add events for access changes

---

## 📝 License

MIT or GPL (choose according to your preference)

---

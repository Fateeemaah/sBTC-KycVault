
;; sBTC-KYCVault

;; KYC Vault Smart Contract
;; Users can store encrypted KYC info and grant access via NFTs

;; NFT for access control
(define-non-fungible-token kyc-access uint)

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-EXISTS (err u102))
(define-constant ERR-INVALID-TOKEN (err u103))

;; Data variables
(define-data-var next-token-id uint u1)

;; Maps
(define-map kyc-vault principal (buff 1024))
(define-map access-grants uint principal)
(define-map token-owners uint principal)
(define-map token-expiry uint uint)
(define-map token-metadata uint {created-at: uint, purpose: (string-ascii 50)})
(define-map access-history principal (list 50 {token-id: uint, accessed-at: uint, accessor: principal}))

;; Store encrypted KYC data
(define-public (store-kyc-data (encrypted-data (buff 1024)))
  (begin
    (map-set kyc-vault tx-sender encrypted-data)
    (ok true)))

;; Mint access NFT and grant access to specific principal
(define-public (grant-access (to principal))
  (let ((token-id (var-get next-token-id)))
    (asserts! (is-some (map-get? kyc-vault tx-sender)) ERR-NOT-FOUND)
    (try! (nft-mint? kyc-access token-id to))
    (map-set access-grants token-id tx-sender)
    (map-set token-owners token-id to)
    (var-set next-token-id (+ token-id u1))
    (ok token-id)))

;; Grant access with expiration and purpose
(define-public (grant-access-with-expiry (to principal) (expires-at uint) (purpose (string-ascii 50)))
  (let ((token-id (var-get next-token-id)))
    (asserts! (is-some (map-get? kyc-vault tx-sender)) ERR-NOT-FOUND)
    (asserts! (> expires-at block-height) ERR-NOT-AUTHORIZED)
    (try! (nft-mint? kyc-access token-id to))
    (map-set access-grants token-id tx-sender)
    (map-set token-owners token-id to)
    (map-set token-expiry token-id expires-at)
    (map-set token-metadata token-id {created-at: block-height, purpose: purpose})
    (var-set next-token-id (+ token-id u1))
    (ok token-id)))

;; Revoke access by burning NFT
(define-public (revoke-access (token-id uint))
  (let ((owner (unwrap! (map-get? token-owners token-id) ERR-INVALID-TOKEN))
        (data-owner (unwrap! (map-get? access-grants token-id) ERR-INVALID-TOKEN)))
    (asserts! (is-eq tx-sender data-owner) ERR-NOT-AUTHORIZED)
    (try! (nft-burn? kyc-access token-id owner))
    (map-delete access-grants token-id)
    (map-delete token-owners token-id)
    (ok true)))

;; Access KYC data using NFT (checks expiration)
(define-read-only (get-kyc-data (token-id uint))
  (let ((data-owner (unwrap! (map-get? access-grants token-id) ERR-INVALID-TOKEN))
        (expiry (map-get? token-expiry token-id)))
    (asserts! (is-eq (some tx-sender) (nft-get-owner? kyc-access token-id)) ERR-NOT-AUTHORIZED)
    (match expiry
      some-expiry (asserts! (< block-height some-expiry) ERR-NOT-AUTHORIZED)
      true)
    (ok (map-get? kyc-vault data-owner))))

;; Check if user has KYC data stored
(define-read-only (has-kyc-data (user principal))
  (is-some (map-get? kyc-vault user)))

;; Get NFT owner
(define-read-only (get-token-owner (token-id uint))
  (ok (nft-get-owner? kyc-access token-id)))

;; Get data owner for a token
(define-read-only (get-data-owner (token-id uint))
  (ok (map-get? access-grants token-id)))

;; Get token metadata
(define-read-only (get-token-metadata (token-id uint))
  (ok (map-get? token-metadata token-id)))

;; Get token expiry
(define-read-only (get-token-expiry (token-id uint))
  (ok (map-get? token-expiry token-id)))

;; Check if token is expired
(define-read-only (is-token-expired (token-id uint))
  (match (map-get? token-expiry token-id)
    some-expiry (ok (>= block-height some-expiry))
    (ok false)))

;; Update KYC data (only by data owner)
(define-public (update-kyc-data (encrypted-data (buff 1024)))
  (begin
    (asserts! (is-some (map-get? kyc-vault tx-sender)) ERR-NOT-FOUND)
    (map-set kyc-vault tx-sender encrypted-data)
    (ok true)))
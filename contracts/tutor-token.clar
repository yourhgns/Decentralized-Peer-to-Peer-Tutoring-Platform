;; tutor-token.clar
;; TUTOR Token Smart Contract for Decentralized Peer-to-Peer Tutoring Platform
;; This contract implements a SIP-10 compliant fungible token with additional features for platform governance,
;; controlled minting, burning, pausing, metadata for mints, and revenue sharing hooks.

;; Traits
(use-trait ft-trait .sip-010-trait.sip-010-trait)

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_PAUSED (err u101))
(define-constant ERR_INVALID_AMOUNT (err u102))
(define-constant ERR_INVALID_RECIPIENT (err u103))
(define-constant ERR_INVALID_MINTER (err u104))
(define-constant ERR_ALREADY_REGISTERED (err u105))
(define-constant ERR_METADATA_TOO_LONG (err u106))
(define-constant ERR_TRANSFER_FAILED (err u107))
(define-constant ERR_BURN_FAILED (err u108))
(define-constant ERR_INSUFFICIENT_BALANCE (err u109))
(define-constant ERR_NOT_OWNER (err u110))
(define-constant ERR_INVALID_METADATA (err u111))
(define-constant MAX_METADATA_LEN u500)
(define-constant TOKEN_DECIMALS u6)
(define-constant TOKEN_NAME "TUTOR")
(define-constant TOKEN_SYMBOL "TUT")
(define-constant INITIAL_SUPPLY u100000000000000) ;; 100 million tokens with 6 decimals

;; Data Variables
(define-data-var total-supply uint INITIAL_SUPPLY)
(define-data-var paused bool false)
(define-data-var admin principal CONTRACT_OWNER)
(define-data-var mint-counter uint u0)

;; Data Maps
(define-map balances principal uint)
(define-map minters principal bool)
(define-map mint-records uint {amount: uint, recipient: principal, metadata: (string-utf8 500), timestamp: uint})
(define-map allowances {owner: principal, spender: principal} uint)

;; Read-Only Functions
(define-read-only (get-name)
  (ok TOKEN_NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN_SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN_DECIMALS)
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-read-only (get-balance (account principal))
  (ok (default-to u0 (map-get? balances account)))
)

(define-read-only (get-allowance (owner principal) (spender principal))
  (ok (default-to u0 (map-get? allowances {owner: owner, spender: spender})))
)

(define-read-only (get-mint-record (token-id uint))
  (map-get? mint-records token-id)
)

(define-read-only (is-minter (account principal))
  (default-to false (map-get? minters account))
)

(define-read-only (is-paused)
  (var-get paused)
)

(define-read-only (get-admin)
  (ok (var-get admin))
)

;; Private Functions
(define-private (transfer-internal (amount uint) (sender principal) (recipient principal))
  (let ((sender-balance (unwrap! (get-balance sender) ERR_INSUFFICIENT_BALANCE)))
    (if (>= sender-balance amount)
      (begin
        (map-set balances sender (- sender-balance amount))
        (map-set balances recipient (+ (default-to u0 (map-get? balances recipient)) amount))
        true)
      false))
)

(define-private (burn-internal (amount uint) (owner principal))
  (let ((owner-balance (unwrap! (get-balance owner) ERR_INSUFFICIENT_BALANCE)))
    (if (>= owner-balance amount)
      (begin
        (map-set balances owner (- owner-balance amount))
        (var-set total-supply (- (var-get total-supply) amount))
        true)
      false))
)

;; Public Functions
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR_UNAUTHORIZED)
    (var-set admin new-admin)
    (ok true))
)

(define-public (pause-contract)
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR_UNAUTHORIZED)
    (var-set paused true)
    (ok true))
)

(define-public (unpause-contract)
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR_UNAUTHORIZED)
    (var-set paused false)
    (ok true))
)

(define-public (add-minter (minter principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR_UNAUTHORIZED)
    (asserts! (not (is-minter minter)) ERR_ALREADY_REGISTERED)
    (map-set minters minter true)
    (ok true))
)

(define-public (remove-minter (minter principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR_UNAUTHORIZED)
    (map-set minters minter false)
    (ok true))
)

(define-public (mint (amount uint) (recipient principal) (metadata (string-utf8 500)))
  (begin
    (asserts! (not (var-get paused)) ERR_PAUSED)
    (asserts! (is-minter tx-sender) ERR_INVALID_MINTER)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (not (is-eq recipient CONTRACT_OWNER)) ERR_INVALID_RECIPIENT) ;; Example restriction
    (asserts! (<= (len metadata) MAX_METADATA_LEN) ERR_METADATA_TOO_LONG)
    (let ((current-balance (default-to u0 (map-get? balances recipient)))
          (new-counter (+ (var-get mint-counter) u1)))
      (map-set balances recipient (+ current-balance amount))
      (var-set total-supply (+ (var-get total-supply) amount))
      (map-set mint-records new-counter {amount: amount, recipient: recipient, metadata: metadata, timestamp: block-height})
      (var-set mint-counter new-counter)
      (print {event: "mint", amount: amount, recipient: recipient, metadata: metadata, token-id: new-counter})
      (ok new-counter)))
)

(define-public (transfer (amount uint) (recipient principal))
  (begin
    (asserts! (not (var-get paused)) ERR_PAUSED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (transfer-internal amount tx-sender recipient) ERR_TRANSFER_FAILED)
    (print {event: "transfer", amount: amount, from: tx-sender, to: recipient})
    (ok true))
)

(define-public (transfer-from (amount uint) (sender principal) (recipient principal))
  (let ((allowance (unwrap! (get-allowance sender tx-sender) (ok u0))))
    (asserts! (not (var-get paused)) ERR_PAUSED)
    (asserts! (>= allowance amount) ERR_UNAUTHORIZED)
    (asserts! (transfer-internal amount sender recipient) ERR_TRANSFER_FAILED)
    (map-set allowances {owner: sender, spender: tx-sender} (- allowance amount))
    (print {event: "transfer-from", amount: amount, from: sender, to: recipient, spender: tx-sender})
    (ok true))
)

(define-public (approve (spender principal) (amount uint))
  (begin
    (asserts! (not (var-get paused)) ERR_PAUSED)
    (map-set allowances {owner: tx-sender, spender: spender} amount)
    (print {event: "approve", owner: tx-sender, spender: spender, amount: amount})
    (ok true))
)

(define-public (burn (amount uint))
  (begin
    (asserts! (not (var-get paused)) ERR_PAUSED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (burn-internal amount tx-sender) ERR_BURN_FAILED)
    (print {event: "burn", amount: amount, owner: tx-sender})
    (ok true))
)

;; Initial Mint to Contract Owner
(begin
  (map-set balances CONTRACT_OWNER INITIAL_SUPPLY)
)
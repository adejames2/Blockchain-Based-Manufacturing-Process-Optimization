;; Facility Verification Contract
;; Validates production sites and their certification status

(define-data-var admin principal tx-sender)

;; Data structure for facilities
(define-map facilities
  { facility-id: (string-ascii 32) }
  {
    owner: principal,
    name: (string-ascii 100),
    location: (string-ascii 100),
    certified: bool,
    certification-date: uint,
    certification-expiry: uint
  }
)

;; Public function to register a new facility
(define-public (register-facility (facility-id (string-ascii 32)) (name (string-ascii 100)) (location (string-ascii 100)))
  (let ((caller tx-sender))
    (if (map-insert facilities
                    { facility-id: facility-id }
                    {
                      owner: caller,
                      name: name,
                      location: location,
                      certified: false,
                      certification-date: u0,
                      certification-expiry: u0
                    })
        (ok true)
        (err u1))))

;; Admin function to certify a facility
(define-public (certify-facility (facility-id (string-ascii 32)) (certification-period uint))
  (let ((caller tx-sender)
        (current-time block-height))
    (if (is-eq caller (var-get admin))
        (match (map-get? facilities { facility-id: facility-id })
          facility (begin
            (map-set facilities
                     { facility-id: facility-id }
                     (merge facility {
                       certified: true,
                       certification-date: current-time,
                       certification-expiry: (+ current-time certification-period)
                     }))
            (ok true))
          (err u2))
        (err u3))))

;; Read-only function to check if a facility is certified
(define-read-only (is-facility-certified (facility-id (string-ascii 32)))
  (match (map-get? facilities { facility-id: facility-id })
    facility (and (get certified facility)
                 (<= block-height (get certification-expiry facility)))
    false))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
        (begin
          (var-set admin new-admin)
          (ok true))
        (err u4))))

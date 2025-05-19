;; Optimization Contract
;; Manages continuous improvement initiatives

(define-data-var admin principal tx-sender)

;; Data structure for optimization initiatives
(define-map optimization-initiatives
  { initiative-id: (string-ascii 32) }
  {
    name: (string-ascii 100),
    target-process: (string-ascii 32),
    start-date: uint,
    end-date: uint,
    status: (string-ascii 20),
    owner: principal,
    expected-improvement: uint,
    actual-improvement: uint
  }
)

;; Create a new optimization initiative
(define-public (create-initiative
                (initiative-id (string-ascii 32))
                (name (string-ascii 100))
                (target-process (string-ascii 32))
                (duration uint)
                (expected-improvement uint))
  (let ((caller tx-sender)
        (current-time block-height))
    (if (map-insert optimization-initiatives
                    { initiative-id: initiative-id }
                    {
                      name: name,
                      target-process: target-process,
                      start-date: current-time,
                      end-date: (+ current-time duration),
                      status: "active",
                      owner: caller,
                      expected-improvement: expected-improvement,
                      actual-improvement: u0
                    })
        (ok true)
        (err u1))))

;; Complete an optimization initiative
(define-public (complete-initiative
                (initiative-id (string-ascii 32))
                (actual-improvement uint))
  (let ((caller tx-sender))
    (match (map-get? optimization-initiatives { initiative-id: initiative-id })
      initiative (if (is-eq caller (get owner initiative))
                    (begin
                      (map-set optimization-initiatives
                               { initiative-id: initiative-id }
                               (merge initiative {
                                 status: "completed",
                                 actual-improvement: actual-improvement
                               }))
                      (ok true))
                    (err u3))
      (err u2))))

;; Get initiative details
(define-read-only (get-initiative (initiative-id (string-ascii 32)))
  (map-get? optimization-initiatives { initiative-id: initiative-id }))

;; Calculate ROI for an initiative (simplified)
(define-read-only (calculate-roi (initiative-id (string-ascii 32)))
  (match (map-get? optimization-initiatives { initiative-id: initiative-id })
    initiative (let ((expected (get expected-improvement initiative))
                     (actual (get actual-improvement initiative)))
                 (if (is-eq actual u0)
                     u0
                     (/ (* actual u100) expected)))
    u0))

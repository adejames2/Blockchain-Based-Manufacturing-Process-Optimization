;; Quality Outcome Contract
;; Records product specifications and quality metrics

;; Data structure for quality outcomes
(define-map quality-outcomes
  {
    batch-id: (string-ascii 32)
  }
  {
    process-id: (string-ascii 32),
    timestamp: uint,
    pass-rate: uint,
    defect-rate: uint,
    inspector: principal,
    notes: (string-ascii 200)
  }
)

;; Record quality outcome
(define-public (record-quality
                (batch-id (string-ascii 32))
                (process-id (string-ascii 32))
                (pass-rate uint)
                (defect-rate uint)
                (notes (string-ascii 200)))
  (let ((caller tx-sender)
        (current-time block-height))
    (if (map-insert quality-outcomes
                    { batch-id: batch-id }
                    {
                      process-id: process-id,
                      timestamp: current-time,
                      pass-rate: pass-rate,
                      defect-rate: defect-rate,
                      inspector: caller,
                      notes: notes
                    })
        (ok true)
        (err u1))))

;; Update quality outcome
(define-public (update-quality
                (batch-id (string-ascii 32))
                (pass-rate uint)
                (defect-rate uint)
                (notes (string-ascii 200)))
  (let ((caller tx-sender)
        (current-time block-height))
    (match (map-get? quality-outcomes { batch-id: batch-id })
      outcome (begin
        (map-set quality-outcomes
                 { batch-id: batch-id }
                 (merge outcome {
                   timestamp: current-time,
                   pass-rate: pass-rate,
                   defect-rate: defect-rate,
                   inspector: caller,
                   notes: notes
                 }))
        (ok true))
      (err u2))))

;; Get quality outcome for a batch
(define-read-only (get-quality (batch-id (string-ascii 32)))
  (map-get? quality-outcomes { batch-id: batch-id }))

;; Check if quality meets standards (simplified)
(define-read-only (meets-quality-standards (pass-rate uint) (defect-rate uint))
  (and (>= pass-rate u90) (<= defect-rate u5)))

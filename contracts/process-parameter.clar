;; Process Parameter Contract
;; Tracks production settings and parameters

;; Data structure for process parameters
(define-map process-parameters
  {
    process-id: (string-ascii 32),
    timestamp: uint
  }
  {
    equipment-id: (string-ascii 32),
    temperature: int,
    pressure: int,
    speed: int,
    duration: uint,
    operator: principal
  }
)

;; Record process parameters
(define-public (record-parameters
                (process-id (string-ascii 32))
                (equipment-id (string-ascii 32))
                (temperature int)
                (pressure int)
                (speed int)
                (duration uint))
  (let ((caller tx-sender)
        (current-time block-height))
    (if (map-insert process-parameters
                    {
                      process-id: process-id,
                      timestamp: current-time
                    }
                    {
                      equipment-id: equipment-id,
                      temperature: temperature,
                      pressure: pressure,
                      speed: speed,
                      duration: duration,
                      operator: caller
                    })
        (ok true)
        (err u1))))

;; Get the latest process parameters
(define-read-only (get-latest-parameters (process-id (string-ascii 32)))
  (map-get? process-parameters { process-id: process-id, timestamp: block-height }))

;; Check if parameters are within acceptable range (simplified example)
(define-read-only (are-parameters-valid
                   (temperature int)
                   (pressure int)
                   (speed int))
  (and
    (< temperature 100)
    (> temperature 0)
    (< pressure 1000)
    (> pressure 0)
    (< speed 500)
    (> speed 0)))

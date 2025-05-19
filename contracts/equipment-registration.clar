;; Equipment Registration Contract
;; Records manufacturing assets and their status

(define-data-var admin principal tx-sender)

;; Data structure for equipment
(define-map equipment
  { equipment-id: (string-ascii 32) }
  {
    facility-id: (string-ascii 32),
    name: (string-ascii 100),
    type: (string-ascii 50),
    installation-date: uint,
    last-maintenance: uint,
    status: (string-ascii 20)
  }
)

;; Public function to register new equipment
(define-public (register-equipment
                (equipment-id (string-ascii 32))
                (facility-id (string-ascii 32))
                (name (string-ascii 100))
                (type (string-ascii 50)))
  (let ((caller tx-sender)
        (current-time block-height))
    ;; Check if facility exists and caller is authorized (simplified)
    (if (map-insert equipment
                    { equipment-id: equipment-id }
                    {
                      facility-id: facility-id,
                      name: name,
                      type: type,
                      installation-date: current-time,
                      last-maintenance: current-time,
                      status: "operational"
                    })
        (ok true)
        (err u1))))

;; Update equipment maintenance status
(define-public (update-maintenance (equipment-id (string-ascii 32)))
  (let ((current-time block-height))
    (match (map-get? equipment { equipment-id: equipment-id })
      equip (begin
        (map-set equipment
                 { equipment-id: equipment-id }
                 (merge equip { last-maintenance: current-time }))
        (ok true))
      (err u2))))

;; Update equipment operational status
(define-public (update-equipment-status (equipment-id (string-ascii 32)) (new-status (string-ascii 20)))
  (match (map-get? equipment { equipment-id: equipment-id })
    equip (begin
      (map-set equipment
               { equipment-id: equipment-id }
               (merge equip { status: new-status }))
      (ok true))
    (err u3)))

;; Read-only function to get equipment details
(define-read-only (get-equipment-details (equipment-id (string-ascii 32)))
  (map-get? equipment { equipment-id: equipment-id }))

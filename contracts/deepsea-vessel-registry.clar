;; DeepSea Vessel Registry
;; A blockchain-based certification system for deep ocean research vessels

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u1))
(define-constant ERR_VESSEL_NOT_FOUND (err u2))
(define-constant ERR_VESSEL_EXISTS (err u3))
(define-constant ERR_INVALID_CERTIFICATION (err u4))
(define-constant ERR_INSUFFICIENT_SIGNATURES (err u5))
(define-constant ERR_ALREADY_SIGNED (err u6))
(define-constant ERR_INVALID_STATUS (err u7))

;; Data structures
(define-map vessels
  { vessel-id: uint }
  {
    name: (string-ascii 50),
    owner: principal,
    registration-date: uint,
    vessel-type: (string-ascii 20),
    max-depth: uint,
    crew-capacity: uint,
    status: (string-ascii 20),
    certification-level: uint,
    last-maintenance: uint,
    is-active: bool
  }
)

(define-map crew-certifications
  { vessel-id: uint, crew-member: principal }
  {
    certification-type: (string-ascii 30),
    issue-date: uint,
    expiry-date: uint,
    certifying-authority: principal,
    is-valid: bool
  }
)

(define-map equipment-validation
  { vessel-id: uint, equipment-id: uint }
  {
    equipment-name: (string-ascii 40),
    validation-date: uint,
    validator: principal,
    certification-hash: (buff 32),
    next-inspection: uint,
    is-certified: bool
  }
)

(define-map maintenance-records
  { vessel-id: uint, record-id: uint }
  {
    maintenance-type: (string-ascii 30),
    date: uint,
    technician: principal,
    description: (string-ascii 100),
    cost: uint,
    next-due: uint
  }
)

(define-map deployment-approvals
  { vessel-id: uint, deployment-id: uint }
  {
    mission-name: (string-ascii 50),
    requested-by: principal,
    approval-count: uint,
    required_signatures: uint,
    deployment-date: uint,
    return-date: uint,
    status: (string-ascii 20),
    created-at: uint
  }
)

(define-map approval-signatures
  { vessel-id: uint, deployment-id: uint, approver: principal }
  { signed-at: uint, signature-hash: (buff 32) }
)

(define-map maritime-authorities
  { authority: principal }
  { 
    name: (string-ascii 50),
    jurisdiction: (string-ascii 30),
    is-active: bool,
    registered-at: uint
  }
)

;; Data variables
(define-data-var vessel-counter uint u0)
(define-data-var equipment-counter uint u0)
(define-data-var record-counter uint u0)
(define-data-var deployment-counter uint u0)
(define-data-var required-approvers uint u3)

;; Read-only functions
(define-read-only (get-vessel (vessel-id uint))
  (map-get? vessels { vessel-id: vessel-id })
)

(define-read-only (get-crew-certification (vessel-id uint) (crew-member principal))
  (map-get? crew-certifications { vessel-id: vessel-id, crew-member: crew-member })
)

(define-read-only (get-equipment-validation (vessel-id uint) (equipment-id uint))
  (map-get? equipment-validation { vessel-id: vessel-id, equipment-id: equipment-id })
)

(define-read-only (get-maintenance-record (vessel-id uint) (record-id uint))
  (map-get? maintenance-records { vessel-id: vessel-id, record-id: record-id })
)

(define-read-only (get-deployment-approval (vessel-id uint) (deployment-id uint))
  (map-get? deployment-approvals { vessel-id: vessel-id, deployment-id: deployment-id })
)

(define-read-only (get-vessel-count)
  (var-get vessel-counter)
)

(define-read-only (is-maritime-authority (authority principal))
  (is-some (map-get? maritime-authorities { authority: authority }))
)

(define-read-only (get-required-approvers)
  (var-get required-approvers)
)

;; Public functions
(define-public (register-vessel 
  (name (string-ascii 50))
  (vessel-type (string-ascii 20))
  (max-depth uint)
  (crew-capacity uint))
  (let 
    ((vessel-id (+ (var-get vessel-counter) u1)))
    (asserts! (is-none (map-get? vessels { vessel-id: vessel-id })) ERR_VESSEL_EXISTS)
    (map-set vessels
      { vessel-id: vessel-id }
      {
        name: name,
        owner: tx-sender,
        registration-date: stacks-block-height,
        vessel-type: vessel-type,
        max-depth: max-depth,
        crew-capacity: crew-capacity,
        status: "registered",
        certification-level: u1,
        last-maintenance: u0,
        is-active: true
      }
    )
    (var-set vessel-counter vessel-id)
    (ok vessel-id)
  )
)

(define-public (certify-crew 
  (vessel-id uint)
  (crew-member principal)
  (certification-type (string-ascii 30))
  (expiry-date uint))
  (let
    ((vessel (unwrap! (get-vessel vessel-id) ERR_VESSEL_NOT_FOUND)))
    (asserts! (or (is-eq tx-sender (get owner vessel)) 
                  (is-maritime-authority tx-sender)) ERR_UNAUTHORIZED)
    (map-set crew-certifications
      { vessel-id: vessel-id, crew-member: crew-member }
      {
        certification-type: certification-type,
        issue-date: stacks-block-height,
        expiry-date: expiry-date,
        certifying-authority: tx-sender,
        is-valid: true
      }
    )
    (ok true)
  )
)

(define-public (validate-equipment
  (vessel-id uint)
  (equipment-name (string-ascii 40))
  (certification-hash (buff 32))
  (next-inspection uint))
  (let
    ((vessel (unwrap! (get-vessel vessel-id) ERR_VESSEL_NOT_FOUND))
     (equipment-id (+ (var-get equipment-counter) u1)))
    (asserts! (or (is-eq tx-sender (get owner vessel))
                  (is-maritime-authority tx-sender)) ERR_UNAUTHORIZED)
    (map-set equipment-validation
      { vessel-id: vessel-id, equipment-id: equipment-id }
      {
        equipment-name: equipment-name,
        validation-date: stacks-block-height,
        validator: tx-sender,
        certification-hash: certification-hash,
        next-inspection: next-inspection,
        is-certified: true
      }
    )
    (var-set equipment-counter equipment-id)
    (ok equipment-id)
  )
)

(define-public (add-maintenance-record
  (vessel-id uint)
  (maintenance-type (string-ascii 30))
  (description (string-ascii 100))
  (cost uint)
  (next-due uint))
  (let
    ((vessel (unwrap! (get-vessel vessel-id) ERR_VESSEL_NOT_FOUND))
     (record-id (+ (var-get record-counter) u1)))
    (asserts! (is-eq tx-sender (get owner vessel)) ERR_UNAUTHORIZED)
    (map-set maintenance-records
      { vessel-id: vessel-id, record-id: record-id }
      {
        maintenance-type: maintenance-type,
        date: stacks-block-height,
        technician: tx-sender,
        description: description,
        cost: cost,
        next-due: next-due
      }
    )
    ;; Update vessel's last maintenance
    (map-set vessels
      { vessel-id: vessel-id }
      (merge vessel { last-maintenance: stacks-block-height })
    )
    (var-set record-counter record-id)
    (ok record-id)
  )
)

(define-public (request-deployment-approval
  (vessel-id uint)
  (mission-name (string-ascii 50))
  (deployment-date uint)
  (return-date uint))
  (let
    ((vessel (unwrap! (get-vessel vessel-id) ERR_VESSEL_NOT_FOUND))
     (deployment-id (+ (var-get deployment-counter) u1)))
    (asserts! (is-eq tx-sender (get owner vessel)) ERR_UNAUTHORIZED)
    (asserts! (get is-active vessel) ERR_INVALID_STATUS)
    (map-set deployment-approvals
      { vessel-id: vessel-id, deployment-id: deployment-id }
      {
        mission-name: mission-name,
        requested-by: tx-sender,
        approval-count: u0,
        required_signatures: (var-get required-approvers),
        deployment-date: deployment-date,
        return-date: return-date,
        status: "pending",
        created-at: stacks-block-height
      }
    )
    (var-set deployment-counter deployment-id)
    (ok deployment-id)
  )
)

(define-public (approve-deployment
  (vessel-id uint)
  (deployment-id uint)
  (signature-hash (buff 32)))
  (let
    ((deployment (unwrap! (get-deployment-approval vessel-id deployment-id) ERR_VESSEL_NOT_FOUND)))
    (asserts! (is-maritime-authority tx-sender) ERR_UNAUTHORIZED)
    (asserts! (is-none (map-get? approval-signatures 
                               { vessel-id: vessel-id, deployment-id: deployment-id, approver: tx-sender })) 
              ERR_ALREADY_SIGNED)
    
    ;; Add signature
    (map-set approval-signatures
      { vessel-id: vessel-id, deployment-id: deployment-id, approver: tx-sender }
      { signed-at: stacks-block-height, signature-hash: signature-hash }
    )
    
    ;; Update approval count
    (let ((new-count (+ (get approval-count deployment) u1)))
      (map-set deployment-approvals
        { vessel-id: vessel-id, deployment-id: deployment-id }
        (merge deployment { 
          approval-count: new-count,
          status: (if (>= new-count (get required_signatures deployment)) "approved" "pending")
        })
      )
      (ok new-count)
    )
  )
)

(define-public (register-maritime-authority
  (authority principal)
  (name (string-ascii 50))
  (jurisdiction (string-ascii 30)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set maritime-authorities
      { authority: authority }
      {
        name: name,
        jurisdiction: jurisdiction,
        is-active: true,
        registered-at: stacks-block-height
      }
    )
    (ok true)
  )
)

(define-public (update-vessel-status
  (vessel-id uint)
  (new-status (string-ascii 20)))
  (let
    ((vessel (unwrap! (get-vessel vessel-id) ERR_VESSEL_NOT_FOUND)))
    (asserts! (or (is-eq tx-sender (get owner vessel))
                  (is-maritime-authority tx-sender)) ERR_UNAUTHORIZED)
    (map-set vessels
      { vessel-id: vessel-id }
      (merge vessel { status: new-status })
    )
    (ok true)
  )
)

(define-public (set-required-approvers (count uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (var-set required-approvers count)
    (ok true)
  )
)
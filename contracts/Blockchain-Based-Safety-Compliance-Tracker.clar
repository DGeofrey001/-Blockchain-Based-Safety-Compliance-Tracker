(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-invalid-inspector (err u103))
(define-constant err-certification-expired (err u104))
(define-constant err-unauthorized (err u105))
(define-constant err-invalid-input (err u106))

(define-data-var next-inspection-id uint u1)
(define-data-var next-hazard-id uint u1)
(define-data-var next-certification-id uint u1)

(define-map inspectors principal 
  {
    id: uint,
    name: (string-ascii 50),
    license-number: (string-ascii 20),
    active: bool,
    certifications: (list 10 uint)
  }
)

(define-map inspections uint
  {
    inspector: principal,
    mine-id: (string-ascii 50),
    inspection-type: (string-ascii 30),
    timestamp: uint,
    status: (string-ascii 20),
    findings: (string-ascii 500),
    evidence-hash: (string-ascii 64),
    next-inspection-due: uint
  }
)

(define-map hazard-reports uint
  {
    reporter: principal,
    mine-id: (string-ascii 50),
    hazard-type: (string-ascii 30),
    severity: uint,
    description: (string-ascii 500),
    timestamp: uint,
    status: (string-ascii 20),
    evidence-hash: (string-ascii 64),
    resolved: bool
  }
)

(define-map safety-certifications uint
  {
    mine-id: (string-ascii 50),
    certification-type: (string-ascii 30),
    issuer: principal,
    issue-date: uint,
    expiry-date: uint,
    certificate-hash: (string-ascii 64),
    active: bool
  }
)

(define-map mine-compliance (string-ascii 50)
  {
    owner: principal,
    name: (string-ascii 100),
    location: (string-ascii 100),
    compliance-score: uint,
    last-inspection: uint,
    active-hazards: uint,
    certifications: (list 20 uint)
  }
)

(define-read-only (get-inspector (inspector principal))
  (map-get? inspectors inspector)
)

(define-read-only (get-inspection (inspection-id uint))
  (map-get? inspections inspection-id)
)

(define-read-only (get-hazard-report (hazard-id uint))
  (map-get? hazard-reports hazard-id)
)

(define-read-only (get-certification (cert-id uint))
  (map-get? safety-certifications cert-id)
)

(define-read-only (get-mine-compliance (mine-id (string-ascii 50)))
  (map-get? mine-compliance mine-id)
)

(define-read-only (get-next-inspection-id)
  (var-get next-inspection-id)
)

(define-read-only (get-next-hazard-id)
  (var-get next-hazard-id)
)

(define-read-only (get-next-certification-id)
  (var-get next-certification-id)
)

(define-read-only (is-certification-expired (cert-id uint))
  (match (map-get? safety-certifications cert-id)
    certification 
      (< (get expiry-date certification) burn-block-height)
    false
  )
)

(define-read-only (get-expired-certifications (mine-id (string-ascii 50)))
  (match (map-get? mine-compliance mine-id)
    mine-data
      (get certifications mine-data)
    (list)
  )
)

(define-public (register-inspector (name (string-ascii 50)) (license-number (string-ascii 20)))
  (begin
    (asserts! (is-none (map-get? inspectors tx-sender)) err-already-exists)
    (asserts! (> (len name) u0) err-invalid-input)
    (asserts! (> (len license-number) u0) err-invalid-input)
    (map-set inspectors tx-sender
      {
        id: u1,
        name: name,
        license-number: license-number,
        active: true,
        certifications: (list)
      }
    )
    (ok u1)
  )
)

(define-public (register-mine (mine-id (string-ascii 50)) (name (string-ascii 100)) (location (string-ascii 100)))
  (begin
    (asserts! (is-none (map-get? mine-compliance mine-id)) err-already-exists)
    (asserts! (> (len mine-id) u0) err-invalid-input)
    (asserts! (> (len name) u0) err-invalid-input)
    (map-set mine-compliance mine-id
      {
        owner: tx-sender,
        name: name,
        location: location,
        compliance-score: u100,
        last-inspection: u0,
        active-hazards: u0,
        certifications: (list)
      }
    )
    (ok mine-id)
  )
)

(define-public (submit-inspection 
  (mine-id (string-ascii 50))
  (inspection-type (string-ascii 30))
  (status (string-ascii 20))
  (findings (string-ascii 500))
  (evidence-hash (string-ascii 64))
  (next-due uint)
)
  (let ((inspection-id (var-get next-inspection-id)))
    (asserts! (is-some (map-get? inspectors tx-sender)) err-invalid-inspector)
    (asserts! (is-some (map-get? mine-compliance mine-id)) err-not-found)
    (asserts! (> (len inspection-type) u0) err-invalid-input)
    (asserts! (> next-due burn-block-height) err-invalid-input)
    
    (map-set inspections inspection-id
      {
        inspector: tx-sender,
        mine-id: mine-id,
        inspection-type: inspection-type,
        timestamp: burn-block-height,
        status: status,
        findings: findings,
        evidence-hash: evidence-hash,
        next-inspection-due: next-due
      }
    )
    
    (match (map-get? mine-compliance mine-id)
      mine-data
        (map-set mine-compliance mine-id
          (merge mine-data {
            last-inspection: burn-block-height,
            compliance-score: (if (is-eq status "PASSED") u100 u50)
          })
        )
      false
    )
    
    (var-set next-inspection-id (+ inspection-id u1))
    (ok inspection-id)
  )
)

(define-public (report-hazard
  (mine-id (string-ascii 50))
  (hazard-type (string-ascii 30))
  (severity uint)
  (description (string-ascii 500))
  (evidence-hash (string-ascii 64))
)
  (let ((hazard-id (var-get next-hazard-id)))
    (asserts! (is-some (map-get? mine-compliance mine-id)) err-not-found)
    (asserts! (and (>= severity u1) (<= severity u5)) err-invalid-input)
    (asserts! (> (len hazard-type) u0) err-invalid-input)
    
    (map-set hazard-reports hazard-id
      {
        reporter: tx-sender,
        mine-id: mine-id,
        hazard-type: hazard-type,
        severity: severity,
        description: description,
        timestamp: burn-block-height,
        status: "OPEN",
        evidence-hash: evidence-hash,
        resolved: false
      }
    )
    
    (match (map-get? mine-compliance mine-id)
      mine-data
        (map-set mine-compliance mine-id
          (merge mine-data {
            active-hazards: (+ (get active-hazards mine-data) u1),
            compliance-score: (if (> severity u3) u25 u75)
          })
        )
      false
    )
    
    (var-set next-hazard-id (+ hazard-id u1))
    (ok hazard-id)
  )
)

(define-public (issue-certification
  (mine-id (string-ascii 50))
  (certification-type (string-ascii 30))
  (expiry-date uint)
  (certificate-hash (string-ascii 64))
)
  (let ((cert-id (var-get next-certification-id)))
    (asserts! (is-some (map-get? inspectors tx-sender)) err-invalid-inspector)
    (asserts! (is-some (map-get? mine-compliance mine-id)) err-not-found)
    (asserts! (> expiry-date burn-block-height) err-invalid-input)
    (asserts! (> (len certification-type) u0) err-invalid-input)
    
    (map-set safety-certifications cert-id
      {
        mine-id: mine-id,
        certification-type: certification-type,
        issuer: tx-sender,
        issue-date: burn-block-height,
        expiry-date: expiry-date,
        certificate-hash: certificate-hash,
        active: true
      }
    )
    
    (match (map-get? mine-compliance mine-id)
      mine-data
        (map-set mine-compliance mine-id
          (merge mine-data {
            certifications: (unwrap! (as-max-len? (append (get certifications mine-data) cert-id) u20) err-invalid-input)
          })
        )
      false
    )
    
    (var-set next-certification-id (+ cert-id u1))
    (ok cert-id)
  )
)

(define-public (resolve-hazard (hazard-id uint) (resolution (string-ascii 20)))
  (match (map-get? hazard-reports hazard-id)
    hazard
      (begin
        (asserts! (or (is-eq tx-sender (get reporter hazard)) 
                     (is-some (map-get? inspectors tx-sender))) err-unauthorized)
        (asserts! (not (get resolved hazard)) err-invalid-input)
        
        (map-set hazard-reports hazard-id
          (merge hazard {
            status: resolution,
            resolved: true
          })
        )
        
        (match (map-get? mine-compliance (get mine-id hazard))
          mine-data
            (map-set mine-compliance (get mine-id hazard)
              (merge mine-data {
                active-hazards: (if (> (get active-hazards mine-data) u0) 
                                  (- (get active-hazards mine-data) u1) 
                                  u0),
                compliance-score: (if (> (+ (get compliance-score mine-data) u10) u100) 
                                   u100 
                                   (+ (get compliance-score mine-data) u10))
              })
            )
          false
        )
        
        (ok true)
      )
    err-not-found
  )
)

(define-public (deactivate-inspector (inspector principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (match (map-get? inspectors inspector)
      inspector-data
        (begin
          (map-set inspectors inspector
            (merge inspector-data { active: false })
          )
          (ok true)
        )
      err-not-found
    )
  )
)

(define-public (update-compliance-score (mine-id (string-ascii 50)) (new-score uint))
  (begin
    (asserts! (is-some (map-get? inspectors tx-sender)) err-invalid-inspector)
    (asserts! (is-some (map-get? mine-compliance mine-id)) err-not-found)
    (asserts! (<= new-score u100) err-invalid-input)
    
    (match (map-get? mine-compliance mine-id)
      mine-data
        (begin
          (map-set mine-compliance mine-id
            (merge mine-data { compliance-score: new-score })
          )
          (ok true)
        )
      err-not-found
    )
  )
)

(define-public (revoke-certification (cert-id uint))
  (match (map-get? safety-certifications cert-id)
    certification
      (begin
        (asserts! (or (is-eq tx-sender (get issuer certification))
                     (is-eq tx-sender contract-owner)) err-unauthorized)
        (map-set safety-certifications cert-id
          (merge certification { active: false })
        )
        (ok true)
      )
    err-not-found
  )
)

(define-read-only (get-mine-inspections (mine-id (string-ascii 50)))
  (ok "use get-inspection with specific IDs")
)

(define-read-only (get-mine-hazards (mine-id (string-ascii 50)))
  (ok "use get-hazard-report with specific IDs")
)

(define-read-only (get-active-hazards (mine-id (string-ascii 50)))
  (ok "use get-hazard-report with specific IDs")
)

(define-read-only (check-compliance-status (mine-id (string-ascii 50)))
  (match (map-get? mine-compliance mine-id)
    mine-data
      (let (
        (expired-certs (get-expired-certifications mine-id))
        (active-hazards (get active-hazards mine-data))
        (compliance-score (get compliance-score mine-data))
      )
        (some {
          compliance-score: compliance-score,
          expired-certifications: (len expired-certs),
          active-hazards: active-hazards,
          status: (if (and (is-eq (len expired-certs) u0) 
                          (is-eq active-hazards u0) 
                          (>= compliance-score u80))
                     "COMPLIANT"
                     "NON-COMPLIANT")
        })
      )
    none
  )
)

(define-read-only (get-inspector-inspections (inspector principal))
  (ok "use get-inspection with specific IDs")
)

(define-read-only (validate-inspector-active (inspector principal))
  (match (map-get? inspectors inspector)
    inspector-data (get active inspector-data)
    false
  )
)

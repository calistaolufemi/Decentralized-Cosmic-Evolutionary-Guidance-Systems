;; Evolutionary Bottleneck Prevention Contract
;; Prevents evolutionary bottlenecks in species

(define-map bottleneck-risks
  { id: uint }
  {
    species-id: uint,
    risk-type: (string-ascii 50),
    risk-level: uint,
    description: (string-ascii 200),
    detection-time: uint,
    detector: principal,
    status: (string-ascii 20)
  }
)

(define-map intervention-plans
  { risk-id: uint }
  {
    plan-name: (string-ascii 100),
    description: (string-ascii 200),
    intervention-type: (string-ascii 50),
    estimated-success-rate: uint,
    creation-time: uint,
    creator: principal,
    status: (string-ascii 20)
  }
)

(define-map intervention-outcomes
  { risk-id: uint }
  {
    success: bool,
    outcome-description: (string-ascii 200),
    new-risk-level: uint,
    completion-time: uint,
    executor: principal
  }
)

(define-data-var next-risk-id uint u1)

(define-public (register-bottleneck-risk
  (species-id uint)
  (risk-type (string-ascii 50))
  (risk-level uint)
  (description (string-ascii 200)))
  (let ((risk-id (var-get next-risk-id)))
    (map-set bottleneck-risks
      { id: risk-id }
      {
        species-id: species-id,
        risk-type: risk-type,
        risk-level: risk-level,
        description: description,
        detection-time: block-height,
        detector: tx-sender,
        status: "detected"
      }
    )
    (var-set next-risk-id (+ risk-id u1))
    (ok risk-id)
  )
)

(define-public (create-intervention-plan
  (risk-id uint)
  (plan-name (string-ascii 100))
  (description (string-ascii 200))
  (intervention-type (string-ascii 50))
  (estimated-success-rate uint))
  (begin
    ;; Create intervention plan
    (map-set intervention-plans
      { risk-id: risk-id }
      {
        plan-name: plan-name,
        description: description,
        intervention-type: intervention-type,
        estimated-success-rate: estimated-success-rate,
        creation-time: block-height,
        creator: tx-sender,
        status: "created"
      }
    )

    ;; Update risk status
    (let ((risk (default-to
                  {
                    species-id: u0,
                    risk-type: "",
                    risk-level: u0,
                    description: "",
                    detection-time: u0,
                    detector: tx-sender,
                    status: ""
                  }
                  (map-get? bottleneck-risks { id: risk-id }))))

      (map-set bottleneck-risks
        { id: risk-id }
        (merge risk { status: "plan-created" })
      )
    )

    (ok true)
  )
)

(define-public (execute-intervention
  (risk-id uint)
  (success bool)
  (outcome-description (string-ascii 200))
  (new-risk-level uint))
  (begin
    ;; Record intervention outcome
    (map-set intervention-outcomes
      { risk-id: risk-id }
      {
        success: success,
        outcome-description: outcome-description,
        new-risk-level: new-risk-level,
        completion-time: block-height,
        executor: tx-sender
      }
    )

    ;; Update risk status and level
    (let ((risk (default-to
                  {
                    species-id: u0,
                    risk-type: "",
                    risk-level: u0,
                    description: "",
                    detection-time: u0,
                    detector: tx-sender,
                    status: ""
                  }
                  (map-get? bottleneck-risks { id: risk-id }))))

      (map-set bottleneck-risks
        { id: risk-id }
        (merge risk {
          status: (if success "resolved" "intervention-failed"),
          risk-level: new-risk-level
        })
      )
    )

    ;; Update intervention plan status
    (let ((plan (default-to
                  {
                    plan-name: "",
                    description: "",
                    intervention-type: "",
                    estimated-success-rate: u0,
                    creation-time: u0,
                    creator: tx-sender,
                    status: ""
                  }
                  (map-get? intervention-plans { risk-id: risk-id }))))

      (map-set intervention-plans
        { risk-id: risk-id }
        (merge plan { status: (if success "successful" "failed") })
      )
    )

    (ok true)
  )
)

(define-read-only (get-bottleneck-risk (risk-id uint))
  (map-get? bottleneck-risks { id: risk-id })
)

(define-read-only (get-intervention-plan (risk-id uint))
  (map-get? intervention-plans { risk-id: risk-id })
)

(define-read-only (get-intervention-outcome (risk-id uint))
  (map-get? intervention-outcomes { risk-id: risk-id })
)

(define-read-only (calculate-species-risk-level (species-id uint))
  ;; In a real implementation, this would aggregate all risks for a species
  ;; For simplicity, we'll just return a placeholder value
  u50
)


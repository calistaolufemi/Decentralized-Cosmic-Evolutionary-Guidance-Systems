;; Civilization Advancement Milestone Contract
;; Tracks milestones in civilization advancement

(define-map civilizations
  { id: uint }
  {
    name: (string-ascii 100),
    species-id: uint,
    home-planet: (string-ascii 100),
    technological-level: uint,
    social-complexity: uint,
    energy-utilization: uint,
    current-era: (string-ascii 50),
    last-assessment: uint,
    assessor: principal
  }
)

(define-map advancement-milestones
  { civilization-id: uint, milestone-id: uint }
  {
    milestone-name: (string-ascii 100),
    description: (string-ascii 200),
    category: (string-ascii 50),
    achievement-time: uint,
    validator: principal
  }
)

(define-map kardashev-classifications
  { civilization-id: uint }
  {
    kardashev-level: (string-ascii 20),
    energy-rating: uint,
    classification-time: uint,
    classifier: principal
  }
)

(define-data-var next-civilization-id uint u1)
(define-data-var next-milestone-id uint u1)

(define-public (register-civilization
  (name (string-ascii 100))
  (species-id uint)
  (home-planet (string-ascii 100))
  (technological-level uint)
  (social-complexity uint)
  (energy-utilization uint)
  (current-era (string-ascii 50)))
  (let ((civilization-id (var-get next-civilization-id)))
    (map-set civilizations
      { id: civilization-id }
      {
        name: name,
        species-id: species-id,
        home-planet: home-planet,
        technological-level: technological-level,
        social-complexity: social-complexity,
        energy-utilization: energy-utilization,
        current-era: current-era,
        last-assessment: block-height,
        assessor: tx-sender
      }
    )
    (var-set next-civilization-id (+ civilization-id u1))
    (ok civilization-id)
  )
)

(define-public (update-civilization-metrics
  (civilization-id uint)
  (technological-level uint)
  (social-complexity uint)
  (energy-utilization uint)
  (current-era (string-ascii 50)))
  (let ((civilization-data (default-to
                            {
                              name: "",
                              species-id: u0,
                              home-planet: "",
                              technological-level: u0,
                              social-complexity: u0,
                              energy-utilization: u0,
                              current-era: "",
                              last-assessment: u0,
                              assessor: tx-sender
                            }
                            (map-get? civilizations { id: civilization-id }))))

    ;; Update civilization data
    (map-set civilizations
      { id: civilization-id }
      {
        name: (get name civilization-data),
        species-id: (get species-id civilization-data),
        home-planet: (get home-planet civilization-data),
        technological-level: technological-level,
        social-complexity: social-complexity,
        energy-utilization: energy-utilization,
        current-era: current-era,
        last-assessment: block-height,
        assessor: tx-sender
      }
    )

    (ok true)
  )
)

(define-public (record-advancement-milestone
  (civilization-id uint)
  (milestone-name (string-ascii 100))
  (description (string-ascii 200))
  (category (string-ascii 50)))
  (let ((milestone-id (var-get next-milestone-id)))

    ;; Record milestone
    (map-set advancement-milestones
      { civilization-id: civilization-id, milestone-id: milestone-id }
      {
        milestone-name: milestone-name,
        description: description,
        category: category,
        achievement-time: block-height,
        validator: tx-sender
      }
    )

    (var-set next-milestone-id (+ milestone-id u1))
    (ok milestone-id)
  )
)

(define-public (classify-kardashev-scale
  (civilization-id uint)
  (kardashev-level (string-ascii 20))
  (energy-rating uint))
  (begin
    ;; Record Kardashev classification
    (map-set kardashev-classifications
      { civilization-id: civilization-id }
      {
        kardashev-level: kardashev-level,
        energy-rating: energy-rating,
        classification-time: block-height,
        classifier: tx-sender
      }
    )

    (ok true)
  )
)

(define-read-only (get-civilization (civilization-id uint))
  (map-get? civilizations { id: civilization-id })
)

(define-read-only (get-advancement-milestone (civilization-id uint) (milestone-id uint))
  (map-get? advancement-milestones { civilization-id: civilization-id, milestone-id: milestone-id })
)

(define-read-only (get-kardashev-classification (civilization-id uint))
  (map-get? kardashev-classifications { civilization-id: civilization-id })
)

(define-read-only (calculate-advancement-index (civilization-id uint))
  (let ((civilization-data (default-to
                            {
                              name: "",
                              species-id: u0,
                              home-planet: "",
                              technological-level: u0,
                              social-complexity: u0,
                              energy-utilization: u0,
                              current-era: "",
                              last-assessment: u0,
                              assessor: tx-sender
                            }
                            (map-get? civilizations { id: civilization-id }))))

    ;; Simple advancement index calculation
    (+ (+ (get technological-level civilization-data)
          (get social-complexity civilization-data))
       (get energy-utilization civilization-data))
  )
)


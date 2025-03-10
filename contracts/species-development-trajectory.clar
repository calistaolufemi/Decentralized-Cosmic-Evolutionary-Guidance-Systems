;; Species Development Trajectory Contract
;; Tracks and guides the development trajectory of species

(define-map species
  { id: uint }
  {
    name: (string-ascii 100),
    planet: (string-ascii 100),
    genetic-complexity: uint,
    intelligence-level: uint,
    adaptability-score: uint,
    current-stage: (string-ascii 50),
    last-assessment: uint,
    assessor: principal
  }
)

(define-map development-milestones
  { species-id: uint, milestone-id: uint }
  {
    milestone-name: (string-ascii 100),
    description: (string-ascii 200),
    achievement-time: uint,
    validator: principal
  }
)

(define-data-var next-species-id uint u1)
(define-data-var next-milestone-id uint u1)

(define-public (register-species
  (name (string-ascii 100))
  (planet (string-ascii 100))
  (genetic-complexity uint)
  (intelligence-level uint)
  (adaptability-score uint)
  (current-stage (string-ascii 50)))
  (let ((species-id (var-get next-species-id)))
    (map-set species
      { id: species-id }
      {
        name: name,
        planet: planet,
        genetic-complexity: genetic-complexity,
        intelligence-level: intelligence-level,
        adaptability-score: adaptability-score,
        current-stage: current-stage,
        last-assessment: block-height,
        assessor: tx-sender
      }
    )
    (var-set next-species-id (+ species-id u1))
    (ok species-id)
  )
)

(define-public (update-species-metrics
  (species-id uint)
  (genetic-complexity uint)
  (intelligence-level uint)
  (adaptability-score uint)
  (current-stage (string-ascii 50)))
  (let ((species-data (default-to
                        {
                          name: "",
                          planet: "",
                          genetic-complexity: u0,
                          intelligence-level: u0,
                          adaptability-score: u0,
                          current-stage: "",
                          last-assessment: u0,
                          assessor: tx-sender
                        }
                        (map-get? species { id: species-id }))))

    ;; Update species data
    (map-set species
      { id: species-id }
      {
        name: (get name species-data),
        planet: (get planet species-data),
        genetic-complexity: genetic-complexity,
        intelligence-level: intelligence-level,
        adaptability-score: adaptability-score,
        current-stage: current-stage,
        last-assessment: block-height,
        assessor: tx-sender
      }
    )

    (ok true)
  )
)

(define-public (record-milestone
  (species-id uint)
  (milestone-name (string-ascii 100))
  (description (string-ascii 200)))
  (let ((milestone-id (var-get next-milestone-id)))

    ;; Record milestone
    (map-set development-milestones
      { species-id: species-id, milestone-id: milestone-id }
      {
        milestone-name: milestone-name,
        description: description,
        achievement-time: block-height,
        validator: tx-sender
      }
    )

    (var-set next-milestone-id (+ milestone-id u1))
    (ok milestone-id)
  )
)

(define-read-only (get-species (species-id uint))
  (map-get? species { id: species-id })
)

(define-read-only (get-milestone (species-id uint) (milestone-id uint))
  (map-get? development-milestones { species-id: species-id, milestone-id: milestone-id })
)

(define-read-only (calculate-development-potential (species-id uint))
  (let ((species-data (default-to
                        {
                          name: "",
                          planet: "",
                          genetic-complexity: u0,
                          intelligence-level: u0,
                          adaptability-score: u0,
                          current-stage: "",
                          last-assessment: u0,
                          assessor: tx-sender
                        }
                        (map-get? species { id: species-id }))))

    ;; Simple potential calculation based on key metrics
    (+ (+ (get genetic-complexity species-data)
          (get intelligence-level species-data))
       (get adaptability-score species-data))
  )
)


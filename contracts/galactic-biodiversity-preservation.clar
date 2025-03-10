;; Galactic Biodiversity Preservation Contract
;; Preserves biodiversity across the galaxy

(define-map biodiversity-regions
  { id: uint }
  {
    name: (string-ascii 100),
    location: (string-ascii 100),
    species-count: uint,
    ecosystem-complexity: uint,
    preservation-status: (string-ascii 20),
    registration-time: uint,
    registrar: principal
  }
)

(define-map preserved-species
  { region-id: uint, species-id: uint }
  {
    preservation-level: uint,
    genetic-samples: uint,
    habitat-replicas: uint,
    last-update: uint,
    curator: principal
  }
)

(define-map preservation-initiatives
  { id: uint }
  {
    name: (string-ascii 100),
    region-id: uint,
    description: (string-ascii 200),
    initiative-type: (string-ascii 50),
    start-time: uint,
    end-time: (optional uint),
    coordinator: principal,
    status: (string-ascii 20)
  }
)

(define-data-var next-region-id uint u1)
(define-data-var next-initiative-id uint u1)

(define-public (register-biodiversity-region
  (name (string-ascii 100))
  (location (string-ascii 100))
  (species-count uint)
  (ecosystem-complexity uint))
  (let ((region-id (var-get next-region-id)))
    (map-set biodiversity-regions
      { id: region-id }
      {
        name: name,
        location: location,
        species-count: species-count,
        ecosystem-complexity: ecosystem-complexity,
        preservation-status: "registered",
        registration-time: block-height,
        registrar: tx-sender
      }
    )
    (var-set next-region-id (+ region-id u1))
    (ok region-id)
  )
)

(define-public (register-preserved-species
  (region-id uint)
  (species-id uint)
  (preservation-level uint)
  (genetic-samples uint)
  (habitat-replicas uint))
  (begin
    ;; Register preserved species
    (map-set preserved-species
      { region-id: region-id, species-id: species-id }
      {
        preservation-level: preservation-level,
        genetic-samples: genetic-samples,
        habitat-replicas: habitat-replicas,
        last-update: block-height,
        curator: tx-sender
      }
    )

    (ok true)
  )
)

(define-public (update-preservation-status
  (region-id uint)
  (new-status (string-ascii 20)))
  (let ((region (default-to
                  {
                    name: "",
                    location: "",
                    species-count: u0,
                    ecosystem-complexity: u0,
                    preservation-status: "",
                    registration-time: u0,
                    registrar: tx-sender
                  }
                  (map-get? biodiversity-regions { id: region-id }))))

    ;; Update region status
    (map-set biodiversity-regions
      { id: region-id }
      (merge region { preservation-status: new-status })
    )

    (ok true)
  )
)

(define-public (create-preservation-initiative
  (name (string-ascii 100))
  (region-id uint)
  (description (string-ascii 200))
  (initiative-type (string-ascii 50)))
  (let ((initiative-id (var-get next-initiative-id)))

    ;; Create initiative
    (map-set preservation-initiatives
      { id: initiative-id }
      {
        name: name,
        region-id: region-id,
        description: description,
        initiative-type: initiative-type,
        start-time: block-height,
        end-time: none,
        coordinator: tx-sender,
        status: "active"
      }
    )

    (var-set next-initiative-id (+ initiative-id u1))
    (ok initiative-id)
  )
)

(define-public (complete-preservation-initiative
  (initiative-id uint))
  (let ((initiative (default-to
                      {
                        name: "",
                        region-id: u0,
                        description: "",
                        initiative-type: "",
                        start-time: u0,
                        end-time: none,
                        coordinator: tx-sender,
                        status: ""
                      }
                      (map-get? preservation-initiatives { id: initiative-id }))))

    ;; Update initiative status
    (map-set preservation-initiatives
      { id: initiative-id }
      (merge initiative {
        status: "completed",
        end-time: (some block-height)
      })
    )

    (ok true)
  )
)

(define-read-only (get-biodiversity-region (region-id uint))
  (map-get? biodiversity-regions { id: region-id })
)

(define-read-only (get-preserved-species (region-id uint) (species-id uint))
  (map-get? preserved-species { region-id: region-id, species-id: species-id })
)

(define-read-only (get-preservation-initiative (initiative-id uint))
  (map-get? preservation-initiatives { id: initiative-id })
)

(define-read-only (calculate-biodiversity-index (region-id uint))
  (let ((region (default-to
                  {
                    name: "",
                    location: "",
                    species-count: u0,
                    ecosystem-complexity: u0,
                    preservation-status: "",
                    registration-time: u0,
                    registrar: tx-sender
                  }
                  (map-get? biodiversity-regions { id: region-id }))))

    ;; Simple biodiversity index calculation
    (* (get species-count region) (get ecosystem-complexity region))
  )
)


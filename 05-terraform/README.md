📁 terraform-enterprise-infra/
│
├── 📁 modules/                      # MÓDULOS INTERNOS REUTILIZABLES
│   ├── 📁 networking/               # Infraestructura de Red
│   │   ├── main.tf, variables.tf, outputs.tf
│   ├── 📁 storage/                  # Almacenamiento S3
│   │   ├── main.tf, variables.tf, outputs.tf
│   ├── 📁 compute/                  # Instancias EC2 / Autoscaling
│   │   ├── main.tf, variables.tf, outputs.tf
│   └── 📁 database/                 # Persistencia de Datos (RDS PostgreSQL)
│       ├── main.tf, variables.tf, outputs.tf
│
└── 📁 environments/                 # ENTORNOS DE EJECUCIÓN
    ├── 📁 qa/                       # Entorno de Calidad (Económico)
    │   ├── main.tf                  # Orquestación de módulos para QA
    │   ├── variables.tf             # Declaración de variables
    │   ├── terraform.tfvars         # Valores específicos de QA
    │   └── config.backend.tfvars    # Parámetros del estado de QA
    │
    └── 📁 prod/                     # Entorno de Producción (Alta Disponibilidad)
        ├── main.tf                  # Orquestación de módulos para Prod
        ├── variables.tf             # Declaración de variables
        ├── terraform.tfvars         # Valores específicos de Prod
        └── config.backend.tfvars    # Parámetros del estado de Prod

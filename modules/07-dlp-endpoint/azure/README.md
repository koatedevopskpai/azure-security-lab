# SDCI Lab 07 — Data Loss Prevention & Endpoint Security (Azure)

DLP lab using Microsoft Purview to discover and classify sensitive data. For SDCI 300-745.

## Architecture

```
Sample PII (customers.csv) → Storage Account → Purview Scan → Data Map → Classification
```

## Deploy

```powershell
cd terraform
terraform init
terraform plan -var="creator=you@example.com"
terraform apply -var="creator=you@example.com" -auto-approve
```

## Test

Navigate to Purview Studio: `terraform output purview_portal_url`

1. **Data Map → Sources** — Register the Storage Account as a data source
2. **Data Map → Scan** — Create a new scan to classify sensitive content
3. **Data Catalog** — View the classified assets and sensitivity labels

## Cost

Purview 60-day free trial. Storage Account ~$0.02/day.

## Docs

- [01 — Introduction & Architecture](docs/01-introduction-and-architecture.md)
- [02 — Free Tier & Cost Analysis](docs/02-free-tier-cost-analysis.md)
- [03 — Guided Walkthrough](docs/03-guided-walkthrough.md)

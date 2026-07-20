# SDCI Lab 07 — Azure: Introduction & Architecture

## Objective

Deploy a DLP pipeline using Microsoft Purview to discover and classify sensitive data — mapping to **SDCI 300-745 objective 7.0**.

## Purview Pipeline

### 1. Data Storage — Storage Account

A Storage Account with a `sampledata` container stores a `customers.csv` file containing synthetic PII (credit cards, SSNs, emails). The blob is tagged with `sensitivity=confidential`.

### 2. Governance — Purview Account

Microsoft Purview provides a unified data governance solution:

- **Data Map** — Register and scan data sources across your estate
- **Data Catalog** — Search and browse classified assets
- **Data Insights** — Reports on sensitive data distribution
- **Data Sharing** — Share data in-place without copying

### 3. Scan — Classification

After deploying Terraform, register the Storage Account in Purview Studio and run a full scan. Purview's auto-classification will detect:

- Credit card numbers
- Email addresses
- Phone numbers
- Person names

## Architecture

```
                    ┌──────────────────────────┐
                    │  Storage Account         │
                    │  (sampledata/customers.csv) │
                    └────────────┬─────────────┘
                                 │
                    ┌────────────▼─────────────┐
                    │   Purview Account        │
                    │   (SystemAssigned Id.)   │
                    └────────────┬─────────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                  │
     ┌────────▼────────┐ ┌──────▼──────┐ ┌─────────▼──────┐
     │ Data Map        │ │ Scan        │ │ Data Catalog   │
     │ (sources)       │ │ (classify)  │ │ (browse)       │
     └─────────────────┘ └─────────────┘ └────────────────┘
```

## References

- [Purview Overview](https://learn.microsoft.com/en-us/purview/)
- [Purview Scan Best Practices](https://learn.microsoft.com/en-us/purview/concept-best-practices-scanning)

# SDCI Lab 07 — Azure: Guided Walkthrough

## Step 1 — Deploy

```powershell
cd modules\07-dlp-endpoint\azure\terraform
terraform init
terraform plan -var="creator=student@example.com"
terraform apply -var="creator=student@example.com" -auto-approve
```

## Step 2 — Open Purview Studio

Navigate to the Purview portal URL:

```
terraform output purview_portal_url
```

## Step 3 — Register and Scan the Storage Account

1. In Purview Studio, go to **Data Map → Sources**
2. Register: **Azure Blob Storage** → select your Storage Account
3. Once registered, click **New Scan**
4. Select the `sampledata` container
5. Run a **Full Scan**
6. Purview will auto-classify the CSV content

## Step 4 — View Classified Data

1. Go to **Data Catalog**
2. Search for `customers.csv`
3. View the **Schema** tab — columns should show detected classifications
4. View **Data Insights** for sensitive data distribution reports

## Step 5 — Cleanup

```powershell
.\cleanup.ps1
```

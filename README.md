# Synthetic Data Generator

A simple project that:
1. Generates synthetic customer data into a CSV file.
2. Uploads that file to ADLS Gen2.

## Project layout

- `src/data_generator.py`: Entry point that runs simulation and ADLS upload.
- `src/simulate.py`: Core 100-day simulation loop.
- `src/generate_initial_snapshot.py`: Day-0 population generation.
- `src/clustered_modify.py`: Daily clustered profile change logic.
- `src/generate_new_users.py`: Daily new-user generation.
- `src/upload_snapshots_to_adls.py`: ADLS Gen2 upload logic.
- `pipelines/regenerate-data-into-datalake.yml`: CI pipeline to run generator and upload.
- `requirements.txt`: Python dependencies.

## Required secrets

- `DATALAKE_CONNECTION_STRING`
- `DATALAKE_KEY` (kept in pipeline env because you already store it)

## Database CI/CD (Schema-Only Promotion)

This repository now includes a database deployment structure under `db/`.

The deployment model is schema-only promotion:
- Dev and Prod receive the same SQL artifacts from source control.
- Data is not copied from Dev to Prod.

### Folder structure

- `db/schema/`: Schema creation scripts (`raw`, `stg`, `dw`, `ctl`)
- `db/tables/`: Table DDL for control, staging, and warehouse tables
- `db/indexes/`: Index definitions
- `db/views/`: View definitions
- `db/stored_procedures/`: Stored procedure definitions
- `scripts/deploy_db.ps1`: Ordered SQL deployment script

### GitHub Actions workflows

- `.github/workflows/deploy-db-dev.yml`
	- Triggers on changes under `db/**` and manual dispatch
	- Deploys DB artifacts to the Dev database

- `.github/workflows/deploy-db-prod.yml`
	- Manual trigger only (`workflow_dispatch`)
	- Deploys the same DB artifacts to the Prod database

### Required GitHub secrets

Shared server/user:
- `DB_SERVER`
- `DB_USER`
- `DB_PASSWORD`

Dev:
- `DEV_DB_NAME`

Prod:
- `PROD_DB_NAME`

### Orphan cleanup behavior

The deployment script supports orphan cleanup (`-CleanupOrphans`) and both workflows enable it.

- Objects managed in source control are detected from SQL files under `db/**`.
- Objects in the database that are not present in source control are dropped.
- `temp` schema is always excluded from cleanup.
- System schemas (`sys`, `INFORMATION_SCHEMA`) are excluded.

This gives you source-controlled schema parity while preserving any temporary objects under `temp`.

### Recommended environment protection

- Use GitHub Environments: `dev`, `prod`
- Configure required reviewers for `prod` to enforce manual approval

## Quick start

```bash
python -m venv .venv
. .venv/Scripts/activate
pip install -r requirements.txt
python src/data_generator.py
```

## Optional environment overrides

```bash
DATALAKE_FILE_SYSTEM=generated-data
DATALAKE_DIRECTORY=daily
DATALAKE_FILE_NAME=generated_customers.csv
```

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

## Database CI/CD (DACPAC Promotion)

This repository now includes a DACPAC-based database project under `db/dacpac/`.

The deployment model is artifact-based schema promotion:
- Dev and Prod receive the same SQL artifacts from source control.
- Data is not copied from Dev to Prod.
- A DACPAC is built once in CI and then published to each environment.

### DACPAC project structure

- `db/dacpac/DataWarehouse.sqlproj`: SQL project file
- `db/dacpac/src/Schemas/`: schema objects
- `db/dacpac/src/Tables/`: table objects
- `db/dacpac/src/Views/`: view objects
- `db/dacpac/src/StoredProcedures/`: stored procedures

### GitHub Actions workflows

- `.github/workflows/deploy-db-dev.yml`
  - Manual dispatch or pull request to `main`
  - Lints SQL first, then builds DACPAC, then publishes to Dev only

- `.github/workflows/deploy-db.yml`
  - Triggers on push to `main`
  - Lints SQL first, then builds DACPAC once, then publishes to Prod only
  - No manual dispatch for this workflow

### Required GitHub secrets

- `DB_SERVER`
- `DB_USER`
- `DB_PASSWORD`
- `DEV_DB_NAME`
- `PROD_DB_NAME`

### Drop behavior

Current DACPAC publish arguments use:

- `/p:DropObjectsNotInSource=false`

This means missing objects are not dropped automatically. If you later want controlled cleanup, you can switch this to true and add additional safety gates.

### SQLFluff linting

SQLFluff configuration is stored in [ .sqlfluff](.sqlfluff).

- Dialect: `tsql`
- Lint target: `db/dacpac/src/`
- Linting runs as the first job inside the DB deployment workflows, so deployment fails if lint fails

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

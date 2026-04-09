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

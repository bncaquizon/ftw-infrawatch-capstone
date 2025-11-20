# dlt/unemployment_pipeline.py
import dlt
import pandas as pd
import os

# -------------------------------
# Unemployment data resource
# -------------------------------
@dlt.resource(write_disposition="append", name="unemployment_data")
def unemployment_data():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging")
    FILE_PATH = os.path.join(STAGING_DIR, "raw__psa_unemployment.csv")
    
    # Read CSV and cast everything to string for safe loading
    yield pd.read_csv(FILE_PATH).astype(str)


# -------------------------------
# Run pipeline
# -------------------------------
def run():
    pipeline = dlt.pipeline(
        pipeline_name="unemployment-pipeline",
        destination="clickhouse",   # DLT reads creds from env variables
        dataset_name="raw_grp3",
    )

    print("Fetching and loading unemployment data...")
    info = pipeline.run(unemployment_data())
    print("✅ Records loaded:", info)


if __name__ == "__main__":
    run()

import dlt
import pandas as pd
import os
import clickhouse_connect

client = clickhouse_connect.get_client(
    host='54.87.106.52',
    port=8123,
    username='default',
    password='',
    connect_timeout=60,    # connection setup
    send_receive_timeout=120  # data transfer
)


@dlt.resource(write_disposition="append", name="dpwh_contracts")
def dpwh_contracts():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "contracts_2016-2025_progress.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="doh_hospital")
def doh_hospital():
    FILE_PATH = "/Users/louellarespuesto/ftw-infrawatch-capstone/dlt/extract-loads/doh_hospitals_combined.csv"
    print(f"📥 Loading DOH Hospital CSV from {FILE_PATH}...")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="psa_deped_schools")
def psa_deped_schools():
    FILE_PATH = "/Users/louellarespuesto/ftw-infrawatch-capstone/dlt/extract-loads/psa_deped_2019_2023.csv"
    print(f"📥 Loading PSA Schools CSV from {FILE_PATH}...")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="ched_schools")
def ched_schools():
    FILE_PATH = "/Users/louellarespuesto/ftw-infrawatch-capstone/dlt/extract-loads/ched_23_25.csv"
    print(f"📥 Loading CHED Schools CSV from {FILE_PATH}...")
    yield pd.read_csv(FILE_PATH).astype(str)

def run():
    print("✅ Connecting to ClickHouse (HTTP)...")
    client = clickhouse_connect.get_client(
        host="54.87.106.52",
        port=8123,
        username="ftw_grp3",
        password="Squirtle#007_FTW",
        database="raw_grp3",
        secure=False,
    )
    print("✅ Connection successful!")

    # Local staging path for DLT filesystem output
    STAGING_PATH = os.path.join(os.path.dirname(__file__), "staging_output")
    os.makedirs(STAGING_PATH, exist_ok=True)

    # Path to store schemas locally
    SCHEMA_PATH = os.path.join(os.path.dirname(__file__), ".dlt_schemas")
    os.makedirs(SCHEMA_PATH, exist_ok=True)

    # ✅ Correct DLT pipeline setup
    p = dlt.pipeline(
        pipeline_name="capstone-pipeline",
        destination=dlt.destinations.filesystem(bucket_url=f"file://{STAGING_PATH}"),
        dataset_name="capstone",
        import_schema_path=SCHEMA_PATH,  # ✅ must be a folder path, not True
    )

    print("📥 Extracting resources...")
    info = p.run([dpwh_contracts(), doh_hospital(), psa_deped_schools(), ched_schools()])
    print("✅ DLT extracted data:", info)

    # ✅ Load extracted data manually into ClickHouse
        # ✅ Load extracted data manually into ClickHouse
        # ✅ Load extracted data manually into ClickHouse
    for resource in [ "dpwh_contracts", "doh_hospital", "psa_deped_schools", "ched_schools"]:
        print(f"📤 Preparing {resource} data from DLT output...")

        # ✅ Correct modern DLT dataframe call
        df = p.dataset().table(resource).df()

        table_name = f"raw___{resource}"

        print(f"📤 Loading {resource} to ClickHouse table `{table_name}` ...")

        # Auto-create table if needed
        client.command(
            f"CREATE TABLE IF NOT EXISTS {table_name} "
            f"({', '.join(f'`{c}` String' for c in df.columns)}) "
            "ENGINE = MergeTree() ORDER BY tuple()"
        )

        client.insert_df(table_name, df)
        print(f"✅ {resource} uploaded successfully ({len(df)} rows)")

    print("🎉 All resources loaded to ClickHouse!")

if __name__ == "__main__":
    run()

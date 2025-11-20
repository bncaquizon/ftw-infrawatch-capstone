# dlt/pipeline.py
import dlt, pandas as pd
import os

# https://archive.ics.uci.edu/dataset/9/auto+mpg
# @dlt.resource(name="capstone")
# def mpg():
   
    
#     yield pd.read_csv("").astype(str)
    
    # How to load a local CSV
    # Place file in staging\auto-mpg folder
    #ROOT_DIR = os.path.dirname(__file__)
    #STAGING_DIR = os.path.join(ROOT_DIR, "staging", "auto-mpg")
    #FILE_PATH = os.path.join(STAGING_DIR, "mpg.csv")
    # yield pd.read_csv(FILE_PATH).astype(str)
    
    # How to load an excel file
    #FILE_PATH = os.path.join(STAGING_DIR, "mpg.xlsx")
    #yield pd.read_excel(FILE_PATH).astype(str)

# # --- GRDP resource ---
# @dlt.resource(write_disposition="append", name="grdp")
# def grdp():
#     ROOT_DIR = os.path.dirname(__file__)
#     STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
#     FILE_PATH = os.path.join(STAGING_DIR, "grdp.csv")
#     yield pd.read_csv(FILE_PATH).astype(str)


@dlt.resource(write_disposition="append", name="pdc_disaster_index")
def pdc_disaster_index():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "pdc_disaster_index.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="replace", name="pdc_multihazard")
def pdc_multihazard():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "pdc_multihazard.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

def run():
    p = dlt.pipeline(
        pipeline_name="capstone-pipeline",
        destination="clickhouse",
        dataset_name="raw",
    )
    print("Fetching and loading...")
    # info1 = p.run(grdp())          # dlt pulls creds from env-vars
    # print("records loaded:", info1)


    info1 = p.run((pdc_disaster_index))          # dlt pulls creds from env-vars
    print("records loaded:", info1)
    info2 = p.run((pdc_multihazard))          # dlt pulls creds from env-vars
    print("records loaded:", info2)
  

if __name__ == "__main__":
    run()
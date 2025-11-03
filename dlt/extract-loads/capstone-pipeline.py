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


# --- GRDP by Industry resource ---
@dlt.resource(write_disposition="append", name="grdp_by_industry")
def grdp_by_industry():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "grdp_by_industry.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

# --- GRDP per capita resource ---
@dlt.resource(write_disposition="append", name="grdp_per_capita")
def grdp_per_capita():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "grdp_per_capita.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

# --- Population Growth Rate resource ---
@dlt.resource(write_disposition="append", name="population_growth_rate")
def population_growth_rate():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "population_growth_rate.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

# --- Population Density resource ---
@dlt.resource(write_disposition="append", name="population_density")
def population_density():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "population_density.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

# --- DPWH Road Density resource ---
@dlt.resource(write_disposition="append", name="dpwh_road_density")
def dpwh_road_density():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "dpwh_road_density.csv")
    yield pd.read_csv(FILE_PATH).astype(str)


def run():
    p = dlt.pipeline(
        pipeline_name="capstone-pipeline",
        destination="clickhouse",
        dataset_name="capstone",
    )
    print("Fetching and loading...")
    # info1 = p.run(grdp())          # dlt pulls creds from env-vars
    # print("records loaded:", info1)

    info2 = p.run(grdp_by_industry())          # dlt pulls creds from env-vars
    print("records loaded:", info2)
    info3 = p.run(grdp_per_capita())          # dlt pulls creds from env-vars
    print("records loaded:", info3)
    info4 = p.run(population_growth_rate())          # dlt pulls creds from env-vars
    print("records loaded:", info4)
    info5 = p.run(population_density())          # dlt pulls creds from env-vars
    print("records loaded:", info5)
    info6 = p.run(dpwh_road_density())          # dlt pulls creds from env-vars
    print("records loaded:", info6)

if __name__ == "__main__":
    run()
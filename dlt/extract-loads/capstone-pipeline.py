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
@dlt.resource(write_disposition="append", name="psa_grdp_by_industry")
def psa_grdp_by_industry():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "grdp_by_industry.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

# --- GRDP per capita resource ---
@dlt.resource(write_disposition="append", name="psa_grdp_per_capita")
def psa_grdp_per_capita():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "grdp_per_capita.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

# --- Population Growth Rate resource ---
@dlt.resource(write_disposition="append", name="psa_population_growth_rate")
def psa_population_growth_rate():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "population_growth_rate.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

# --- Population Density resource ---
@dlt.resource(write_disposition="append", name="psa_population_density")
def psa_population_density():
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

@dlt.resource(write_disposition="append", name="cmci_AvailabilityofBasicUtilities")
def cmci_availability_of_basic_utilities():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "cmci_AvailabilityofBasicUtilities.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="cmci_BasicInternetService")
def cmci_basic_internet_service():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "cmci_BasicInternetService.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="cmci_Distance_Ports")
def cmci_distance_ports():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "cmci_Distance_Ports.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="cmci_economicdyna")
def cmci_economic_dynamics():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "cmci_economicdyna.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="cmci_employee_population")
def cmci_employee_population():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "cmci_employee_population.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="cmci_health")
def cmci_health():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "cmci_health.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="cmci_internetcapability")
def cmci_internet_capability():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "cmci_internetcapability.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="cmci_pbpo")
def cmci_pbpo():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "cmci_pbpo.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="cmci_road")
def cmci_road():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "cmci_road.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="cmci_school")
def cmci_school():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "cmci_school.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="cmci_trans")
def cmci_transportation():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "cmci_trans.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="cmci_util")
def cmci_utilities():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "cmci_util.csv")
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

    info2 = p.run(psa_grdp_by_industry())          # dlt pulls creds from env-vars
    print("records loaded:", info2)
    info3 = p.run(psa_grdp_per_capita())          # dlt pulls creds from env-vars
    print("records loaded:", info3)
    info4 = p.run(psa_population_growth_rate())          # dlt pulls creds from env-vars
    print("records loaded:", info4)
    info5 = p.run(psa_population_density())          # dlt pulls creds from env-vars
    print("records loaded:", info5)
    info6 = p.run(dpwh_road_density())          # dlt pulls creds from env-vars
    print("records loaded:", info6)
    info7 = p.run(cmci_availability_of_basic_utilities())          # dlt pulls creds from env-vars
    print("records loaded:", info7)
    info8 = p.run((cmci_basic_internet_service))          # dlt pulls creds from env-vars
    print("records loaded:", info8)
    info9 = p.run((cmci_distance_ports))          # dlt pulls creds from env-vars
    print("records loaded:", info9)
    info10 = p.run((cmci_economic_dynamics))          # dlt pulls creds from env-vars
    print("records loaded:", info10)
    info11 = p.run((cmci_employee_population))          # dlt pulls creds from env-vars
    print("records loaded:", info11)
    info12 = p.run((cmci_health))          # dlt pulls creds from env-vars
    print("records loaded:", info12)
    info13 = p.run((cmci_internet_capability))          # dlt pulls creds from env-vars
    print("records loaded:", info13)
    info14 = p.run((cmci_pbpo))          # dlt pulls creds from env-vars
    print("records loaded:", info14)
    info15 = p.run((cmci_road))          # dlt pulls creds from env-vars
    print("records loaded:", info15)
    info16 = p.run((cmci_school))          # dlt pulls creds from env-vars
    print("records loaded:", info16)
    info17 = p.run((cmci_transportation))          # dlt pulls creds from
    print("records loaded:", info17)
    info18 = p.run((cmci_utilities))          # dlt pulls creds from
    print("records loaded:", info18)

if __name__ == "__main__":
    run()
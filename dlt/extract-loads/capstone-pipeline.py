# dlt/unemployment_pipeline.py
import dlt
import pandas as pd
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

# --- GRDP resource ---
@dlt.resource(write_disposition="append", name="psa_grdp")
def grdp():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "psa_grdp.csv")
    yield pd.read_csv(FILE_PATH).astype(str)


# --- GRDP by Industry resource ---
@dlt.resource(write_disposition="append", name="psa_grdp_by_industry")
def grdp_by_industry():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "psa_grdp_by_industry.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

# --- GRDP per capita resource ---
@dlt.resource(write_disposition="append", name="psa_grdp_per_capita")
def grdp_per_capita():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "psa_grdp_per_capita.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

# --- Population Growth Rate resource ---
@dlt.resource(write_disposition="append", name="psa_population_growth_rate")
def population_growth_rate():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "psa_population_growth_rate.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

# --- Population Density resource ---
@dlt.resource(write_disposition="append", name="psa_population_density")
def population_density():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "psa_population_density.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

# --- DPWH Road Density resource ---
@dlt.resource(write_disposition="append", name="dpwh_road_density")
def dpwh_road_density():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "dpwh_road_density.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

# # --- Poverty Incidence resource ---
@dlt.resource(write_disposition="append", name="psa_poverty_incidence")
def poverty_incidence():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "psa_poverty_incidence.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

# --- Labor Force Participation resource ---
@dlt.resource(write_disposition="append", name="psa_labor_force_participation")
def labor_force_participation():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "psa_labor_force_participation.csv")
    yield pd.read_csv(FILE_PATH).astype(str)


# --- DPWH Bridge Condition resource ---
@dlt.resource(write_disposition="append", name="dpwh_bridge_condition")
def bridge_condition():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "dpwh_bridge_condition_change.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

# --- DPWH Avg IRI resource ---
@dlt.resource(write_disposition="append", name="dpwh_avg_iri")
def avg_iri():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "dpwh_avg_iri.csv")
    yield pd.read_csv(FILE_PATH).astype(str)

# --- LTO Motor Vehicles resource ---
@dlt.resource(write_disposition="append", name="lto_motor_vehicles")
def motor_vehicles():
    ROOT_DIR = os.path.dirname(__file__)
    STAGING_DIR = os.path.join(ROOT_DIR, "staging", "capstone")
    FILE_PATH = os.path.join(STAGING_DIR, "lto_motor_vehicles.csv")
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

@dlt.resource(write_disposition="append", name="doh_hospital")
def doh_hospital():
    FILE_PATH = "/var/dlt/extract-loads/doh_hospital_total_counts.csv"
    print(f"📥 Loading DOH Hospital CSV from {FILE_PATH}...")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="psa_basic_water_access")
def psa_basic_water_access():
    FILE_PATH = "/var/dlt/extract-loads/psa_basic_water_access.csv"
    print(f"📥 Loading DOH Hospital CSV from {FILE_PATH}...")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="psa_deped_schools")
def psa_deped_schools():
    FILE_PATH = "/var/dlt/extract-loads/psa_deped_sch_2019_2023.csv"
    print(f"📥 Loading PSA DepEd Schools CSV from {FILE_PATH}...")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="deped_enrollees_21_22")
def deped_enrollees_21_22():
    FILE_PATH = "/var/dlt/extract-loads/deped_enrollees_21_22.xlsx"
    print(f"📥 Loading DEPED Enrollees (2021–2021) CSV from {FILE_PATH}...")
    yield pd.read_excel(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="deped_enrollees_22_23")
def deped_enrollees_22_23():
    FILE_PATH = "/var/dlt/extract-loads/deped_enrollees_22_23.xlsx"
    print(f"📥 Loading DEPED Enrollees (2022–2023) CSV from {FILE_PATH}...")
    yield pd.read_excel(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="ched_schools_22_25")
def ched_schools_22_25():
    FILE_PATH = "/var/dlt/extract-loads/ched_schools_22_25.csv"
    print(f"📥 Loading CHED Schools (2022–2025) CSV from {FILE_PATH}...")
    yield pd.read_csv(FILE_PATH).astype(str)

@dlt.resource(write_disposition="append", name="ched_enrollees_20_24")
def ched_enrollees_20_24():
    FILE_PATH = "/var/dlt/extract-loads/ched_enrollees_20_24.csv"
    print(f"📥 Loading CHED Enrollees (2020–2024) CSV from {FILE_PATH}...")
    yield pd.read_csv(FILE_PATH).astype(str)

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
>>>>>>> 90a19a1 (Add fact_transport table for mart)

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
    info19 = p.run((doh_hospital))         
    print("records loaded:", info19)
    info20 = p.run((psa_deped_schools))         
    print("records loaded:", info20)
    info21 = p.run((deped_enrollees_21_22))         
    print("records loaded:", info21)
    info22 = p.run((deped_enrollees_22_23))         
    print("records loaded:", info22)
    info23 = p.run((ched_enrollees_20_24))         
    print("records loaded:", info23)
    info24 = p.run((ched_schools_22_25))         
    print("records loaded:", info24)
    info25 = p.run((psa_basic_water_access))         
    print("records loaded:", info25)


    info26 = p.run(grdp_per_capita())          # dlt pulls creds from env-vars
    print("records loaded:", info26)
    info27 = p.run(population_growth_rate())          # dlt pulls creds from env-vars
    print("records loaded:", info27)
    info28 = p.run(population_density())          # dlt pulls creds from env-vars
    print("records loaded:", info28)
    info29 = p.run(dpwh_road_density())          # dlt pulls creds from env-vars
    print("records loaded:", info29)
    info30 = p.run(labor_force_participation())          # dlt pulls creds from env-vars
    print("records loaded:", info30)
    info31 = p.run(bridge_condition())          # dlt pulls creds from env-vars
    print("records loaded:", info31)
    info32 = p.run(avg_iri())          # dlt pulls creds from env-vars
    print("records loaded:", info32)
    info33 = p.run(motor_vehicles())          # dlt pulls creds from env-vars
    print("records loaded:", info33)



if __name__ == "__main__":
    run()

# InfraWATCH Data Pipeline Documentation

## 🚧 What is InfraWATCH?

InfraWATCH is a capstone project designed to solve a real-world issue:  
**scattered, inconsistent, and manually maintained government datasets**.

We built an end-to-end data pipeline using:

- **Python** (extraction, cleaning)
- **Selenium** (web scraping)
- **dbt** (transforms & modeling)
- **ClickHouse** (analytical storage)
- **HTML??** (dashboards)

---
                       ┌─────────────────────────────────────────────────────────┐
                       │        Government Data Sources Integrated               │
                       │       DPWH • DOH • DTI • PSA • DepEd • CHED             │
                       └──────────────────────────┬──────────────────────────────┘
                                                  │
                                                  ▼
                            ┌────────────────────────────────────────────────┐
                            │                    Extract                     │
                            │ Python • Selenium • API/Downloads • Requests   │
                            └──────────────────────────-─────────────────────┘
                                                   │
                                                   ▼
                           ┌────────────────────────────────────────────────┐
                           │                     Clean                      │
                           │ Pandas • Standardization • DQ Checks           │
                           └──────────────────────────-─────────────────────┘
                                                   │
                                                   ▼
                          ┌────────────────────────────────────────────────┐
                          │                  Transform                     │
                          │ dbt Models • Aggregations • Business Metrics   │
                          └──────────────────────────-─────────────────────┘
                                                   │
                                                   ▼
                          ┌────────────────────────────────────────────────┐
                          │                      Load                      │
                          │     ClickHouse Analytical Warehouse            │
                          └──────────────────────────-─────────────────────┘
                                                   │
                                                   ▼
                          ┌────────────────────────────────────────────────┐
                          │            Visualize & Analyze                 │
                          │    Power BI • Superset • Streamlit • Python    │
                          └────────────────────────────────────────────────┘

 
## 1️⃣ Extract Stage – Data Collection
Location: dlt/extract-loads/
Purpose: Gather raw datasets from official web sources.
Tools: Python, Selenium, requests, pandas
•	Scrapers extract infrastructure project data from the DPWH website and other data portals.
•	Scripts are executed periodically to update raw datasets.
•	Extracted outputs are saved as .csv files for traceability and ingestion.
## Example Output:

 
## 2️⃣ Clean Stage – Data Standardization and Quality Checks
Location: dbt/transforms/capstone_/models/clean/
Key Script: clean_dpwh_projects.py
Tools: Python, pandas, clickhouse_connect
This stage processes raw datasets to ensure data consistency, completeness, and quality before modeling.
Processes:
•	Handles missing or invalid values (e.g., missing cost or project status)
•	Converts inconsistent date formats to ISO standard
•	Validates numeric fields like project_cost and physical_progress
•	Generates a Data Quality Report (dpwh_dq_report.csv)
•	Loads the cleaned dataset to ClickHouse under clean_grp3
## Destination in ClickHouse:

 
## 3️⃣ Transform Stage – Modeling and Aggregation
Location: dbt/transforms/capstone_/models/mart/
Tool: dbt (Data Build Tool)
This stage performs data modeling, aggregation, and business logic transformation to prepare analytics-ready datasets.
It connects directly to ClickHouse using the clickhouse-dbt adapter.
Key Model:
•	dpwh_summary.sql — aggregates projects by region and status.
Example Logic:
SELECT
    region,
    status,
    COUNT(*) AS total_projects,
    SUM(project_cost) AS total_cost,
    ROUND(AVG(physical_progress), 2) AS avg_progress
FROM clean_grp3.clean_dpwh_projects
GROUP BY region, status
ORDER BY region, status;
Destination in ClickHouse:
mart_grp3.dpwh_summary
 
## 4️⃣ Load Stage – Analytics & Reporting
Purpose: Store final transformed data for visualization, analysis, and dashboarding.
Destination in ClickHouse:
mart_grp3 database — analytical layer for BI tools.
Integration Options:
•	Power BI
•	Apache Superset
•	Streamlit dashboards
 
## 5️⃣ Monitor Stage – Data Quality & Validation
Tools: dbt tests, Python DQ Report
Automated checks:
•	not_null → ensures key fields are not missing
•	unique → validates unique project codes
•	accepted_range → ensures progress between 0–100%
•	accepted_values → restricts project status to defined categories
Outputs:
•	Data Quality CSV reports (Python)
•	dbt Test Logs (SQL-level validation)
 
🚀 Summary Workflow
[DPWH / DOH / PSA Sources]
        │
        ▼
🧠 Extract  →  raw_grp3.raw_dpwh_projects
        │
        ▼
🧹 Clean    →  clean_grp3.clean_dpwh_projects
        │
        ▼
📊 Transform (dbt) →  mart_grp3.dpwh_summary
        │
        ▼
📈 Load/Visualize →  Power BI / Superset / Streamlit
 
💡 Key Advantages
•	Reproducibility: All data transformations are script-driven and version-controlled.
•	Scalability: Modular dbt models and Python pipelines can easily handle additional sources.
•	Transparency: Every transformation is traceable from raw → clean → mart layers.
•	Performance: ClickHouse enables fast analytical queries across large datasets.
 
📍 Current Focus:
As of this stage, the pipeline fully automates the clean and mart layers for DPWH project data.
Future development will integrate DOH and PSA datasets for cross-sectoral infrastructure analysis.


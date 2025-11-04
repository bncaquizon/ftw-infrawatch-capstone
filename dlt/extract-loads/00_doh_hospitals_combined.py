#!/usr/bin/env python3
"""
00_doh_hospitals_combined.py
Combines two local DOH hospital CSV files (Government + Private)
into one cleaned dataset: doh_hospitals_combined.csv
"""

import pandas as pd
from pathlib import Path

# === CONFIG ===
BASE_DIR = Path("/Users/louellarespuesto/ftw-infrawatch-capstone/dlt/extract-loads")

GOV_FILE = BASE_DIR / "doh_hospitals_government.csv"
PRIVATE_FILE = BASE_DIR / "doh_hospitals_private.csv"
OUTPUT_FILE = BASE_DIR / "doh_hospitals_combined.csv"

print("🏥  DOH Hospital Combiner Started")
print(f"📂  Base directory: {BASE_DIR}")

# === LOAD BOTH FILES ===
dfs = []

try:
    gov_df = pd.read_csv(GOV_FILE)
    gov_df["Hospital_Ownership"] = "Government"
    print(f"✅  Loaded {len(gov_df)} rows from Government file.")
    dfs.append(gov_df)
except Exception as e:
    print(f"❌  Failed to load Government file: {e}")

try:
    priv_df = pd.read_csv(PRIVATE_FILE)
    priv_df["Hospital_Ownership"] = "Private"
    print(f"✅  Loaded {len(priv_df)} rows from Private file.")
    dfs.append(priv_df)
except Exception as e:
    print(f"❌  Failed to load Private file: {e}")

# === COMBINE ===
if not dfs:
    raise SystemExit("⚠️  No CSVs loaded. Please check file paths.")

combined = pd.concat(dfs, ignore_index=True)

# === CLEAN COLUMN NAMES ===
def clean_column(name):
    name = name.strip().lower().replace(" ", "_")
    name = name.replace("/", "_").replace("-", "_")
    return name

combined.columns = [clean_column(c) for c in combined.columns]
combined.drop_duplicates(inplace=True)

# === SAVE COMBINED FILE ===
combined.to_csv(OUTPUT_FILE, index=False)

print(f"\n💾  Combined dataset saved as: {OUTPUT_FILE}")
print(f"📊  Total rows: {len(combined)} | Columns: {len(combined.columns)}")
print(f"🏷️  Ownership types: {combined['hospital_ownership'].unique().tolist()}")
print("✅  DOH Hospitals combined successfully.")

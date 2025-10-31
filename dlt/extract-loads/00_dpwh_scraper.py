from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait, Select
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException, StaleElementReferenceException, WebDriverException
import pandas as pd
import time
import datetime
import os
import re

# =============================
# CONFIGURATION
# =============================
START_YEAR = 2016
END_YEAR = 2025
MAX_RETRIES = 2
BASE_TIMEOUT = 15
URL = "https://apps2.dpwh.gov.ph/infra_projects/"
OUTPUT_FILENAME = f"contracts_{START_YEAR}-{END_YEAR}.xlsx"
PROGRESS_FILE = OUTPUT_FILENAME.replace(".xlsx", "_progress.csv")

HEADERS = [
    "Year", "Region", "Index", "Contract ID", "Contract Description", "Contractor",
    "Implementing Office", "Source of Funds", "Contract Cost", "Effectivity Date",
    "Expiry Date", "Status", "Percentage"
]

CONTRACT_ID_SPAN = "Repeater1_lblCustomerId_"
REGION_SELECT_ID = "ddlRegion"
YEAR_SELECT_ID = "ddlYear"

# =============================
# HELPERS
# =============================
def clean_dataframe_for_excel(df):
    """Remove illegal Excel characters."""
    def clean_str(s):
        if isinstance(s, str):
            return re.sub(r"[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]", "", s)
        return s
    return df.applymap(clean_str)

def initialize_driver():
    """Initialize Chrome WebDriver."""
    print("[INFO] 🚀 Launching Chrome...")
    options = webdriver.ChromeOptions()
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    # You can uncomment this once stable
    # options.add_argument("--headless=new")
    driver = webdriver.Chrome(options=options)
    driver.get(URL)
    return driver

def clean_text(element):
    """Clean text and remove hidden characters."""
    if not element:
        return ""
    text = element.text.strip()
    return re.sub(r"[\x00-\x1F\x7F]", "", text)

def scrape_current_table_rows(driver, year, region):
    """Extract rows from current table."""
    rows_data = []
    try:
        table_rows = driver.find_elements(By.XPATH, "//table/tbody/tr")
    except NoSuchElementException:
        return rows_data

    for tr in table_rows:
        try:
            th = tr.find_element(By.XPATH, "./th[@scope='row']")
            idx = clean_text(th).replace(".", "")
            elements = {
                "Contract ID": tr.find_element(By.CSS_SELECTOR, f"span[id^='{CONTRACT_ID_SPAN}']"),
                "Contract Description": tr.find_element(By.CSS_SELECTOR, "span[id^='Repeater1_lblContactName_']"),
                "Contractor": tr.find_element(By.CSS_SELECTOR, "span[id^='Repeater1_lblCountry_']"),
                "Implementing Office": tr.find_element(By.CSS_SELECTOR, "span[id^='Repeater1_Label5_']"),
                "Source of Funds": tr.find_element(By.CSS_SELECTOR, "span[id^='Repeater1_Label6_']"),
                "Contract Cost": tr.find_element(By.CSS_SELECTOR, "span[id^='Repeater1_Label2_']"),
                "Effectivity Date": tr.find_element(By.CSS_SELECTOR, "span[id^='Repeater1_Label3_']"),
                "Expiry Date": tr.find_element(By.CSS_SELECTOR, "span[id^='Repeater1_Label4_']"),
                "Status": tr.find_element(By.CSS_SELECTOR, "span[id^='Repeater1_Label7_']"),
                "Percentage": tr.find_element(By.CSS_SELECTOR, "span[id^='Repeater1_Label1_']"),
            }

            row = [
                year, region, idx,
                clean_text(elements["Contract ID"]),
                clean_text(elements["Contract Description"]),
                clean_text(elements["Contractor"]),
                clean_text(elements["Implementing Office"]),
                clean_text(elements["Source of Funds"]),
                clean_text(elements["Contract Cost"]),
                clean_text(elements["Effectivity Date"]),
                clean_text(elements["Expiry Date"]),
                clean_text(elements["Status"]),
                clean_text(elements["Percentage"]),
            ]
            rows_data.append(row)
        except (NoSuchElementException, StaleElementReferenceException):
            continue

    return rows_data

def load_existing_progress():
    """Resume from last progress if exists."""
    if os.path.exists(PROGRESS_FILE):
        df = pd.read_csv(PROGRESS_FILE)
        done_pairs = set(zip(df["Year"], df["Region"]))
        print(f"[INFO] Resuming... Found {len(done_pairs)} completed (Year, Region) pairs.")
        return df, done_pairs
    else:
        return pd.DataFrame(columns=HEADERS), set()

def append_to_progress(df_existing, new_rows):
    """Append and save progress."""
    df_new = pd.DataFrame(new_rows, columns=HEADERS)
    df_combined = pd.concat([df_existing, df_new], ignore_index=True)
    df_combined.to_csv(PROGRESS_FILE, index=False)
    print(f"  💾 Progress saved ({len(df_new)} new rows).")
    return df_combined

# =============================
# MAIN SCRAPER
# =============================
def main_scraper():
    df_existing, done_pairs = load_existing_progress()
    process_start = datetime.datetime.now()
    driver = initialize_driver()

    try:
        WebDriverWait(driver, 30).until(EC.presence_of_element_located((By.ID, YEAR_SELECT_ID)))

        for year in range(START_YEAR, END_YEAR + 1):
            print(f"\n--- Processing Year: {year} ---")

            try:
                Select(driver.find_element(By.ID, YEAR_SELECT_ID)).select_by_value(str(year))
                time.sleep(2)
            except WebDriverException:
                print("  ⚠️ Driver lost — restarting Chrome...")
                driver.quit()
                driver = initialize_driver()
                continue

            region_select = Select(driver.find_element(By.ID, REGION_SELECT_ID))
            region_values = []

            for opt in region_select.options:
                value = opt.get_attribute("value")
                if not value or value.strip() == "0" or opt.get_attribute("disabled"):
                    continue
                region_values.append(value)

            for region_value in region_values:
                if (year, region_value) in done_pairs:
                    print(f"  ⏭️ Skipping already done: {region_value} ({year})")
                    continue

                print(f"  🏗️ Scraping {region_value} ({year}) ...")

                # --- Safe region selection with retry ---
                for attempt in range(3):
                    try:
                        region_select = Select(driver.find_element(By.ID, REGION_SELECT_ID))
                        option = None
                        for opt in region_select.options:
                            if opt.get_attribute("value") == region_value:
                                option = opt
                                break

                        if option is None:
                            print(f"  ⚠️ Option {region_value} not found (attempt {attempt+1}/3)")
                            time.sleep(2)
                            continue

                        if option.get_attribute("disabled"):
                            print(f"  ⚠️ Option {region_value} temporarily disabled (attempt {attempt+1}/3)")
                            time.sleep(2)
                            continue

                        region_select.select_by_value(region_value)
                        time.sleep(3)
                        break  # ✅ success
                    except WebDriverException as e:
                        print(f"  [Retry {attempt+1}/3] Selenium issue while selecting {region_value}: {e}")
                        time.sleep(2)
                else:
                    print(f"  ⏭️ Skipping {region_value} ({year}) after 3 failed attempts.")
                    continue

                # Once successfully selected, scrape
                rows = scrape_current_table_rows(driver, year, region_value)
                if rows:
                    df_existing = append_to_progress(df_existing, rows)
                    done_pairs.add((year, region_value))
                    print(f"  ✅ Collected {len(rows)} rows for {region_value} ({year})")
                else:
                    print(f"  (empty) {region_value} ({year})")

            # Save after each year
            df_clean = clean_dataframe_for_excel(df_existing)
            df_clean.to_excel(OUTPUT_FILENAME, index=False)
            df_clean.to_csv(PROGRESS_FILE, index=False)
            print(f"  💾 Cleaned data saved to Excel & CSV.")

    finally:
        driver.quit()
        print(f"\n✅ Data exported to {OUTPUT_FILENAME}")
        duration = (datetime.datetime.now() - process_start).total_seconds() / 60
        print(f"Total Duration: {duration:.1f} minutes")

# =============================
# RUN
# =============================
if __name__ == "__main__":
    main_scraper()

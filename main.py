import pandas as pd
import requests as r

## Data collection ##
url = "https://en.wikipedia.org/wiki/Template:COVID-19_pandemic_data"
req = r.get(url)

# Get the specfic table data from the url
data_list = pd.read_html(req.text)
target_df = data_list[0] # data is in index 0

## Data Cleaning ##
# Change columns names
target_df.columns = ["Col0", "Country Name", "Total Cases", "Total Deaths", "Total Recoveries", "Col5"]

# Get only the columns we want
target_df = target_df[["Country Name", "Total Cases", "Total Deaths", "Total Recoveries"]]

# Remove/Drop last 2 rows as they contain random text (not hard coded)
last_idx = target_df.index[-1]
target_df = target_df.drop([last_idx, last_idx -1])

# Replace random sqaure brackets in country names with nothing (using a regex expression)
target_df["Country Name"] = target_df["Country Name"].str.replace("\[.*]","")

# Replace No data rows (total recoveries) with 0, and replace any other redundant data
target_df["Total Recoveries"] = target_df["Total Recoveries"].str.replace("No data", "0")
target_df["Total Cases"] = target_df["Total Cases"].str.replace("No data", "0")
target_df["Total Deaths"] = target_df["Total Deaths"].str.replace("No data", "0")
target_df["Total Deaths"] = target_df["Total Deaths"].str.replace("+", "")

# Fix the data types of numbers from string to integer
target_df["Total Cases"] = pd.to_numeric(target_df["Total Cases"])
target_df["Total Recoveries"] = pd.to_numeric(target_df["Total Recoveries"])
target_df["Total Deaths"] = pd.to_numeric(target_df["Total Deaths"])

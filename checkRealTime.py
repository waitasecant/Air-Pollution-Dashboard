import pandas as pd
from datetime import datetime, timedelta

# Copy-on-write enabled
pd.options.mode.copy_on_write = True 

df = pd.read_csv("myApp//data//realTimeDelhi.csv")
df["Date"] = [datetime.strptime(d, "%Y-%m-%d %H:%M:%S") for d in df["Date"]]

current_time = datetime.strftime(datetime.today(), "%Y-%m-%d %H:%M:00")
current_time = datetime.strptime(current_time, "%Y-%m-%d %H:%M:%S")
limit_time = current_time - timedelta(days=1)

tempdf = df[df["Date"] >= limit_time]
tempdf.sort_values(by=["Site", "Date"], inplace=True)
tempdf.to_csv("myApp//data//realTimeDelhi.csv", index=False)

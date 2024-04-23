import pandas as pd
from datetime import datetime, timedelta

# Copy-on-write enabled
pd.options.mode.copy_on_write = True 

df1 = pd.read_csv("myApp//data//realTimeDelhi.csv")
df2 = pd.read_csv("myApp//data//monthlyDelhi.csv")

df1["Date"] = [datetime.strptime(d, "%Y-%m-%d %H:%M:%S") for d in df1["Date"]]
df2["Date"] = [datetime.strptime(d, "%Y-%m-%d %H:%M:%S") for d in df2["Date"]]

current_time = datetime.strftime(datetime.today(), "%Y-%m-%d %H:%M:00")
current_time = datetime.strptime(current_time, "%Y-%m-%d %H:%M:%S")

limit_time1 = current_time - timedelta(days=1)
limit_time2 = current_time - timedelta(days=30)

tempdf1 = df1[df1["Date"] >= limit_time1]
tempdf2 = df2[df2["Date"] >= limit_time2]

tempdf1.sort_values(by=["Site", "Date"], inplace=True)
tempdf2.sort_values(by=["Site", "Date"], inplace=True)

tempdf1.to_csv("myApp//data//realTimeDelhi.csv", index=False)
tempdf2.to_csv("myApp//data//monthlyDelhi.csv", index=False)
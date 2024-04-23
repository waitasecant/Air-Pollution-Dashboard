from bs4 import BeautifulSoup
import requests
import numpy as np
import pandas as pd
from datetime import datetime
import pickle

# Copy-on-write enabled
pd.options.mode.copy_on_write = True 

# ITO not here
newSite = [
    "Bawana",
    "Nehru Nagar",
    # "Jawaharlal Nehru Stadium",
    "Dr. Karni Singh Shooting Range",
    "Major Dhyan Chand National Stadium",
    "Patparganj",
    "Vivek Vihar",
    "Sonia Vihar",
    "Narela",
    "Najafgarh",
    "Rohini",
    "Okhla Phase-2",
    "Ashok Vihar",
    "Wazirpur",
    "Jahangirpuri",
    "Dwarka Sector-8",
    "Alipur",
    "Pusa",
    "Sri Aurobindo Marg",
    "Mundka",
    "Anand Vihar",
    "Mandir Marg",
    "Punjabi Bagh",
    "R K Puram",
]

delhiSiteDetails = {
    "Alipur": [28.815691, 77.15301],
    "Anand Vihar": [28.647622, 77.315809],
    "Ashok Vihar": [28.695381, 77.181665],
    "Bawana": [28.7762, 77.051074],
    "Dr. Karni Singh Shooting Range": [28.498571, 77.26484],
    "Dwarka Sector-8": [28.5710274, 77.0719006],
    "Jahangirpuri": [28.73282, 77.170633],
    # "Jawaharlal Nehru Stadium": [28.58028, 77.233829],
    "Major Dhyan Chand National Stadium": [28.611281, 77.237738],
    "Mandir Marg": [28.636429, 77.201067],
    "Mundka": [28.684678, 77.076574],
    "Najafgarh": [28.570173, 76.933762],
    "Narela": [28.822836, 77.101981],
    "Nehru Nagar": [28.56789, 77.250515],
    "Okhla Phase-2": [28.530785, 77.271255],
    "Patparganj": [28.623763, 77.287209],
    "Punjabi Bagh": [28.674045, 77.131023],
    "Pusa": [28.639645, 77.146262],
    "R K Puram": [28.563262, 77.186937],
    "Rohini": [28.732528, 77.11992],
    "Sonia Vihar": [28.710508, 77.249485],
    "Sri Aurobindo Marg": [28.531346, 77.190156],
    "Vivek Vihar": [28.672342, 77.31526],
    "Wazirpur": [28.699793, 77.165453],
}

weblinks = {
    "Alipur": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=QWxpcHVy",
    "Anand Vihar": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=QW5hbmRWaWhhcg==",
    "Ashok Vihar": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=QXNob2tWaWhhcg==",
    "Bawana": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=UG9vdGhLaHVyZEJhd2FuYQ==",
    "Dr. Karni Singh Shooting Range": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=S2FybmlTaW5naFNob290aW5nUmFuZ2U=",
    "Dwarka Sector-8": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=RHdhcmthU2VjdHJvOA==",
    "Jahangirpuri": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=SmFoYW5naXJwdXJp",
    # "Jawaharlal Nehru Stadium": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=SkxOU3RhZGl1bQ==",
    "Major Dhyan Chand National Stadium": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=TmF0aW9uYWxTdGFkaXVt",
    "Mandir Marg": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=TWFuZGlybWFyZw==",
    "Mundka": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=TXVuZGth",
    "Najafgarh": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=TmFqYWZnYXJo",
    "Narela": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=TmFyZWxh",
    "Nehru Nagar": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=TmVocnVOYWdhcg==",
    "Okhla Phase-2": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=T2tobGFQaGFzZTI=",
    "Patparganj": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=UGF0cGFyZ2Fuag==",
    "Punjabi Bagh": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=UHVuamFiaUJhZ2g=",
    "Pusa": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=UHVzYQ==",
    "R K Puram": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=UktQdXJhbQ==",
    "Rohini": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=Um9oaW5pU2VjdG9yMTY=",
    "Sonia Vihar": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=U29uaWFWaWhhcg==",
    "Sri Aurobindo Marg": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=U3JpQXVyYmluZG9NYXJn",
    "Vivek Vihar": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=Vml2ZWtWaWhhcg==",
    "Wazirpur": "https://www.dpccairdata.com/dpccairdata/display/AallStationView5MinData.php?stName=V2F6aXJwdXI=",
}


def getVal(a):
    if "." not in a:
        return -1
    else:
        a = a.split(".")
        return eval(a[0] + "." + a[1][0])


data = []
for site in weblinks:
    r = requests.get(weblinks[site]).text
    soup = BeautifulSoup(r, "lxml")
    table1 = soup.find_all("tr", class_="tdcolor1")
    table2 = soup.find_all("tr", class_="tdcolor2")

    temp = table2[6].find_all("td")[1].getText().split(", ")
    temp = temp[1] + " " + temp[2]

    Date = (
        str(datetime.strptime(temp, "%B %d %Y"))[:10]
        + " "
        + table2[6].find_all("td")[2].getText()
    )

    pm25val = getVal(table2[6].find_all("td")[3].getText())
    pm10val = getVal(table1[6].find_all("td")[3].getText())
    nh3val = getVal(table1[0].find_all("td")[3].getText())
    so2val = getVal(table1[4].find_all("td")[3].getText())
    data.append(
        [
            Date,
            site,
            "Delhi",
            delhiSiteDetails[site][0],
            delhiSiteDetails[site][1],
            pm25val,
            pm10val,
            nh3val,
            so2val,
        ]
    )
df = pd.DataFrame(
    data,
    columns=[
        "Date",
        "Site",
        "State",
        "Latitude",
        "Longitude",
        "PM2.5",
        "PM10",
        "NH3",
        "SO2",
    ],
)

df["AQI"] = -1
df_old1 = pd.read_csv("myApp//data//realTimeDelhi.csv")
df_old2 = pd.read_csv("myApp//data//monthlyDelhi.csv")

df1 = pd.concat([df_old1, df], axis=0)
df2 = pd.concat([df_old2, df], axis=0)

df1.drop_duplicates(inplace=True)
df2.drop_duplicates(inplace=True)

df1.sort_values(by=["Site", "Date"], inplace=True)
df2.sort_values(by=["Site", "Date"], inplace=True)

# Imputing PM10 values since only they are being used in pickle model
pm10Impute = []
for st in df1["Site"].unique():
    series = df1[df1["Site"]==st]["PM10"]
    series.replace(-1.0,np.mean(series), inplace=True)
    pm10Impute.extend(series.values)
pm10Impute = [round(i,1) for i in pm10Impute]
df1["PM10"] = pm10Impute

pm10Impute = []
for st in df2["Site"].unique():
    series = df2[df2["Site"]==st]["PM10"]
    series.replace(-1.0,np.mean(series), inplace=True)
    pm10Impute.extend(series.values)
pm10Impute = [round(i,1) for i in pm10Impute]
df2["PM10"] = pm10Impute


model = pickle.load(open("DTAQI.pkl", "rb"))

aqiVal1 = model.predict(df1[["PM10"]])
aqiVal1 = [int(i) for i in aqiVal1]

aqiVal2 = model.predict(df2[["PM10"]])
aqiVal2 = [int(i) for i in aqiVal2]

df1["AQI"] = aqiVal1
df2["AQI"] = aqiVal2

df1.to_csv("myApp//data//realTimeDelhi.csv", index=False)
df2.to_csv("myApp//data//monthlyDelhi.csv", index=False)
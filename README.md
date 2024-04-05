# Air-Pollution-Dashboard
[![build](https://github.com/waitasecant/Air-Pollution-Dashboard/actions/workflows/main.yml/badge.svg)](https://github.com/waitasecant/Air-Pollution-Dashboard/actions/workflows/main.yml)
[![License](https://img.shields.io/github/license/waitasecant/Air-Pollution-Dashboard?color=neon)](LICENSE)
[![Website](https://img.shields.io/website?url=https%3A%2F%2Fgoogle.com&up_message=dashboard&up_color=neon&down_message=dashboard&down_color=neon&label=shiny)](https://waitasecant.shinyapps.io/myapp)

*An interactive shiny dashboard to help you monitor ambient air quality in Delhi*

![alt text](https://github.com/waitasecant/Air-Pollution-Dashboard/blob/main/dashboard.png?raw=true)

The real-time dashboard mainly feautres two types of visualization

### 1. Choropleth Maps

Maps displaying spatial distribution of monthly average of the pollution concentration choropleth maps built using Inverse Weighted Interpolation over $10\times 10$ km grid, taking into account data from stations nearby Delhi in Haryana and UP.

*A representation of what went behind creating the maps.
![alt text](https://github.com/waitasecant/Air-Pollution-Dashboard/blob/main/choropleth.png?raw=true)

### 2. Time Series Plots

Color-coded plots showing temporal variation of the pollutant levels over the last 24-hrs using the National Ambient Air Quality Standards (NAAQS) indicating severity of the pollution.

![alt text](https://github.com/waitasecant/Air-Pollution-Dashboard/blob/main/plot.png?raw=true)

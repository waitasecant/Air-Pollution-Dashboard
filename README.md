# Air-Pollution-Dashboard
[![build](https://github.com/waitasecant/Air-Pollution-Dashboard/actions/workflows/main.yml/badge.svg)](https://github.com/waitasecant/Air-Pollution-Dashboard/actions/workflows/main.yml)
[![License](https://img.shields.io/github/license/waitasecant/Air-Pollution-Dashboard)](LICENSE)
[![Website](https://img.shields.io/website?url=https%3A%2F%2Fwaitasecant.shinyapps.io%2Fmyapp&up_message=dashboard&label=shiny&link=https%3A%2F%2Fwaitasecant.shinyapps.io%2Fmyapp)](https://waitasecant.shinyapps.io/myapp)

*An interactive shiny dashboard to help you monitor ambient air quality in Delhi*

The real-time dashboard mainly feautres two types of visualization

### 1. Choropleth Maps

Maps displaying sppatial distribution of monthly average of the pollution concentration choropleth maps built using Inverse Weighted Interpolation over $10\times 10$ km grid, taking into account data from stations nearby Delhi in Haryana and UP.

### 2. Time Series Plots
Color-coded plots showing temporal variation of the pollutant levels over the last 24-hrs using the National Ambient Air Quality Standards (NAAQS) indicating severity of the pollution.

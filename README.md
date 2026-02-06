# HRS-project-data
Health and Retirement Study (HRS) Data Cleaning & Preparation

Project Overview

This project cleans and subsets data from the RAND Health and Retirement Study (HRS), a nationally representative longitudinal survey of older Americans, to create a reproducible analytic dataset for downstream statistical analysis.
The workflow focuses on extracting, reshaping, and preparing demographic, labor, health, stress, sleep, and physical activity variables from a high-dimensional, multi-wave dataset.
This project demonstrates skills in data wrangling, longitudinal data management, and reproducible analysis using real-world survey data.

Data Source
RAND Health and Retirement Study (HRS), 1992–2022
Public-use longitudinal survey data
Unit of observation: individual respondent observed across multiple survey waves
Raw HRS data are not included in this document due to data use restrictions.

Objective
The primary objectives of this project are to:
- Subset relevant variables from a large-scale longitudinal dataset
- Reshape data from wide to long format for panel analysis
- Apply inclusion criteria to define a consistent analytic sample
- Construct derived variables related to physical activity behavior
- Produce a clean, analysis-ready dataset using a fully reproducible workflow

Methods
Key data preparation steps include:
- Importing and subsetting variables from the RAND HRS longitudinal file
- Reshaping multi-wave data from wide to long format
- Applying sample restrictions
- Declaring panel structure for longitudinal analysis
- Creating a physical activity frequency indicator

Tools & Technologies
Stata
RAND HRS documentation
Longitudinal survey data methods

Repository Structure
- hrs_data_cleaning.do: Main data cleaning and preparation script
- README.md: Project documentation
- .gitignore: Excludes restricted data and log files

Reproducibility Notes
File paths must be updated locally before running the script.
Log files are generated to track all data processing steps.
Raw data are intentionally excluded to comply with HRS data use policies.

Potential Extensions
Regression analysis of post-retirement health outcomes; Longitudinal analysis of stress, sleep, and physical activity; Policy-relevant research on aging and labor force exit

Author
Katie Francis

# SQL Layoffs during Covid - Data Cleaning & Analysis Project 

## Project Overview
This project demonstrates a complete SQL workflow on a real-world layoffs dataset:
- Raw data → Cleaning → Standardization → Exploratory Insights
- Focused on global tech layoffs between 2020 and 2023

## Objectives
1️. Clean and standardize the messy raw dataset  
2️. Handle duplicates, blanks, and inconsistent values  
3️. Convert fields to correct data types  
4️. Analyze layoffs by company, industry, year, country, and trend

## Tools Used
- MySQL Workbench
- CSV dataset (imported into MySQL)

## Data Cleaning
- Created staging tables to avoid modifying raw data
- Removed duplicate rows using ROW_NUMBER + CTE
- Standardized fields using TRIM, date conversion, and text cleanup
- Handled NULL & blank values via inference and deletion
- Dropped helper columns after cleanup

## Exploratory Data Analysis
- Total layoffs by company
- Layoffs by industry & country
- Year-wise layoffs trend
- Monthly pattern + running totals
- Top 5 companies affected per year

## Key Insights
- Layoffs peaked during the funding downturn
- Startups in “Tech & Crypto” were impacted the most
- Some companies laid off 100% of their workforce
- Major impact observed in US-based companies


# Dominos-SQL-Analytics-Project
I am writing a complete professional README file for your GitHub repository. Just copy this into a new file named  Dominos-SQL-Analytics-Project
🍕 Domino’s Pizza Sales Analytics – SQL Project

This is an end-to-end SQL project where I performed data cleaning, transformation, and business analytics for a Domino’s-style pizza ordering system.
The project covers 20 real-world business problem statements from various stakeholders like Operations, Finance, Marketing, Product, and Customer Insights teams.


Main Folders
dominos-sql-analytics-project/
│
├── README.md
├── data/
│    ├── customers.csv
│    ├── orders.csv
│    ├── order_details.csv
│    ├── pizzas.csv
│    └── pizza_types.csv
│
├── sql/
│    └── DominosProject.sql
│
└── visuals/
     └── (Screenshots of dashboards/outputs - optional)

📌 🔹 Project Overview

This project demonstrates:

✔ Cleaning raw e-commerce/pizza store data
✔ Removing duplicates, nulls, inconsistent formats
✔ Performing advanced SQL analysis
✔ Using window functions, aggregation, ranking
✔ Solving 20 business questions
✔ Creating actionable insights for real stakeholders

Tech Used: SQL Server (SSMS)

📁 Project Structure
.
├── sql/
│    └── DominosProject.sql    # Complete SQL code
│
├── data/                      # Optional - sample CSVs
│
└── README.md

🧹 1. Data Cleaning Steps Performed
✔ Remove duplicate customers

Identified using email

Applied ROW_NUMBER & MIN techniques

✔ Handle NULL values

Replaced null phone numbers

Cleaned missing fields

✔ Fix negative values

Set quantity < 0 → 0

✔ Correct date formats

Identified invalid/NULL dates

✔ Validate email formats
✔ Check and correct data types
📊 2. Business Analysis (20 SQL Queries Solved)

Below are the key problems solved:

🔹 Orders & Customer Analytics

Total unique orders

Month-over-month and year-over-year growth

Day-of-week order trends

Average orders per customer

Repeat customer frequency

Forecasting using cumulative trends

🔹 Revenue Insights

Total revenue

Revenue by pizza size

Top 3 pizzas by revenue

% contribution of each pizza

🔹 Menu & Product Analytics

Highest-priced pizza

Most ordered pizza size

Category-wise distribution

Top 5 pizza types

Category-based ranking (top 3)

🔹 Operational Insights

Orders by time of day

Seasonal trends

Average order size

🔹 Customer Segmentation

High-value vs regular customers

Repeat customer rate

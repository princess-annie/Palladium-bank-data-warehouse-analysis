## Palladium Bank — Data Warehouse Project

## Project Overview
This project delivers a data warehouse for Palladium Bank's retail banking operations. Built entirely in PostgreSQL using a star schema dimensional model, the warehouse holds transaction-level data across 
customers, products, branches, channels, and dates giving the bank a single source of truth for revenue analysis, churn detection, and product performance monitoring over an 18-month reporting window and beyond.

## Problem Satement
Palladium Bank's operational database was designed for daily transactions, not analytics. 
Running business intelligence queries against a normalised transactional system is slow, complex, and unreliable especially at scale. The bank needed a dedicated analytical layer that could answer questions like: 
1. Which customer tier drove the most revenue in 2024?
2. Which products are pulling deposits vs withdrawals?
3. Which high-value customers haven't transacted in 30 days?
4. The core Problem: Build a warehouse that is fast enough for real-time querying, accurate enough for historical reporting, and clean enough to trust.



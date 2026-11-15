# Olist E-Commerce Logistics, Pricing & Fulfilment Analysis

**Tech Stack:** SQL (DuckDB / SQLite), Python (Pandas, Matplotlib, Seaborn), Power BI  
**Author:** Kamidi Vinitha

## Project Structure
- `data/` — Complete relational Olist datasets (`orders`, `order_items`, `customers`, `sellers`, `products`, `reviews`).
- `sql/olist_duckdb_analysis.sql` — Production-ready DuckDB SQL queries covering stage-wise turnaround times, state SLA breaches, freight-to-price ratios, and review score degradation.
- `scripts/run_olist_pipeline.py` — End-to-end Python pipeline that ingests raw CSVs into DuckDB and builds the denormalized Power BI dataset.
- `outputs/` — Pre-generated SQL analysis summary CSVs and high-resolution Matplotlib/Seaborn charts ready for GitHub or presentations.
- `powerbi/` — Ready-to-load `olist_powerbi_master_model.csv` and `PowerBI_Setup_and_DAX_Guide.md` with copy-paste DAX formulas.
- `olist_analytics.db` — Pre-built SQLite database with all 6 tables loaded and ready to query.

## How to Use
1. **Upload to GitHub:** Upload this entire folder to a new GitHub repository (`olist-ecommerce-analytics`) so recruiters can inspect your SQL, Python, and charts immediately.
2. **Open in Power BI Desktop:** Click **Get Data -> Text/CSV**, select `powerbi/olist_powerbi_master_model.csv`, and paste the DAX measures from `powerbi/PowerBI_Setup_and_DAX_Guide.md`.
3. **Scale to Full 100K Kaggle Dataset:** Replace the CSVs in `data/` with the Kaggle Olist files and run `python scripts/run_olist_pipeline.py` — all queries work identically without changing a single line of code.

# Olist E-Commerce Analytics (SQL + DuckDB + Streamlit)

> **Status: work in progress.** Core pipeline and dashboard are in place. I am currently verifying the queries, fixing issues I found, and adding my own analysis (see the checklist below).

## Business problem
A marketplace wants one source of truth for its core KPIs (revenue, orders, average order value, growth), answers on whether customers come back, which categories drive revenue, and how delivery performance varies by region.

## Dataset
[Olist Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle): 9 relational tables, about 100k orders from 2016 to 2018.

Schema note: `customer_id` is generated per order. The stable person-level key is `customer_unique_id`, so all retention and repeat-purchase queries use that.

## Tech stack
| Layer | Tool |
|---|---|
| Storage | DuckDB (single file) |
| ETL | Python |
| Analysis | SQL (DuckDB dialect) |
| Notebook charts | Matplotlib, Seaborn |
| Dashboard | Streamlit, Plotly |

## How to run
```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# needs a Kaggle API token at ~/.kaggle/kaggle.json
python download_data.py       # downloads the 9 CSVs into ./data/
python load_to_duckdb.py      # builds ./data/olist.duckdb
jupyter notebook analysis.ipynb
streamlit run app.py
```

## Project structure
- `download_data.py`: downloads the raw CSVs from Kaggle
- `load_to_duckdb.py`: loads the 9 CSVs into one DuckDB file
- `queries.sql`: all analytical queries as named blocks
- `db.py`: connects to DuckDB and runs named queries
- `analysis.ipynb`: walkthrough with charts and interpretation
- `app.py`: Streamlit dashboard

## Key findings
_To be filled in with the numbers from my own run._

- Headline KPIs: [orders / customers / revenue / AOV]
- Revenue trend: [your observation]
- Repeat purchase rate: [your number and what it means]
- Delivery: [average days, late %, which states are worst]

## My additions and fixes (checklist)
- [ ] Reconciled the customer count difference between the KPI and repeat-purchase queries
- [ ] Checked the category query for row duplication caused by the review join
- [ ] Defined "revenue" consistently (with or without freight)
- [ ] Fixed the late-delivery chart ordering
- [ ] Cleaned the cohort heatmap (2017 onwards, months 0 to 12)
- [ ] Extra analysis 1: [question]
- [ ] Extra analysis 2: [question]
- [ ] Extra analysis 3: [question]

## Dashboard
![Dashboard](./screenshots/dashboard.png)

## Credits
Based on the public Olist dataset. The initial project structure was adapted from [source / creator]; fixes, extended analysis and write-up are my own.

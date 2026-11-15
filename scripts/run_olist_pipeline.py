import os
import duckdb
import pandas as pd

con = duckdb.connect('olist_duckdb.db')

tables = ['orders', 'order_items', 'reviews', 'customers', 'sellers', 'products']
for t in tables:
    con.execute(f"CREATE OR REPLACE TABLE {t} AS SELECT * FROM read_csv_auto('data/olist_{t}_dataset.csv');")

print("All tables loaded into DuckDB successfully.")

master_df = con.execute("""
    SELECT 
        o.order_id, o.customer_id, c.customer_state, o.order_status,
        o.order_purchase_timestamp, o.order_approved_at,
        o.order_delivered_carrier_date, o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        DATE_DIFF('day', CAST(o.order_approved_at AS TIMESTAMP), CAST(o.order_delivered_carrier_date AS TIMESTAMP)) AS seller_handling_days,
        DATE_DIFF('day', CAST(o.order_delivered_carrier_date AS TIMESTAMP), CAST(o.order_delivered_customer_date AS TIMESTAMP)) AS carrier_transit_days,
        DATE_DIFF('day', CAST(o.order_estimated_delivery_date AS TIMESTAMP), CAST(o.order_delivered_customer_date AS TIMESTAMP)) AS delay_days,
        CASE WHEN CAST(o.order_delivered_customer_date AS TIMESTAMP) > CAST(o.order_estimated_delivery_date AS TIMESTAMP) THEN 'Delayed' ELSE 'On-Time' END AS sla_status,
        oi.order_item_id, oi.product_id, p.product_category_name, p.product_weight_g,
        oi.seller_id, s.seller_state, oi.price, oi.freight_value,
        ROUND(oi.freight_value / NULLIF(oi.price, 0), 4) AS freight_to_price_ratio,
        r.review_score
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    JOIN sellers s ON oi.seller_id = s.seller_id
    LEFT JOIN reviews r ON o.order_id = r.order_id
""").df()

os.makedirs('powerbi', exist_ok=True)
master_df.to_csv('powerbi/olist_powerbi_master_model.csv', index=False)
print("Exported powerbi/olist_powerbi_master_model.csv with", len(master_df), "rows.")

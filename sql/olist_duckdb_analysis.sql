-- ============================================================================
-- OLIST E-COMMERCE LOGISTICS, PRICING & FULFILMENT ANALYSIS (DUCKDB SQL)
-- Author: Kamidi Vinitha
-- Compatible with both the included CSVs and Kaggle's full 100K Olist CSVs
-- ============================================================================

-- 1. Load Raw CSVs into DuckDB Tables
CREATE OR REPLACE TABLE orders AS SELECT * FROM read_csv_auto('data/olist_orders_dataset.csv');
CREATE OR REPLACE TABLE order_items AS SELECT * FROM read_csv_auto('data/olist_order_items_dataset.csv');
CREATE OR REPLACE TABLE reviews AS SELECT * FROM read_csv_auto('data/olist_order_reviews_dataset.csv');
CREATE OR REPLACE TABLE customers AS SELECT * FROM read_csv_auto('data/olist_customers_dataset.csv');
CREATE OR REPLACE TABLE sellers AS SELECT * FROM read_csv_auto('data/olist_sellers_dataset.csv');
CREATE OR REPLACE TABLE products AS SELECT * FROM read_csv_auto('data/olist_products_dataset.csv');

-- 2. Stage-Wise Fulfilment Turnaround & State SLA Breach Rate
WITH stage_times AS (
    SELECT 
        o.order_id,
        c.customer_state,
        DATE_DIFF('hour', CAST(o.order_purchase_timestamp AS TIMESTAMP), CAST(o.order_approved_at AS TIMESTAMP)) AS approval_hours,
        DATE_DIFF('day', CAST(o.order_approved_at AS TIMESTAMP), CAST(o.order_delivered_carrier_date AS TIMESTAMP)) AS seller_handling_days,
        DATE_DIFF('day', CAST(o.order_delivered_carrier_date AS TIMESTAMP), CAST(o.order_delivered_customer_date AS TIMESTAMP)) AS carrier_transit_days,
        DATE_DIFF('day', CAST(o.order_estimated_delivery_date AS TIMESTAMP), CAST(o.order_delivered_customer_date AS TIMESTAMP)) AS delay_vs_est_days,
        CASE WHEN CAST(o.order_delivered_customer_date AS TIMESTAMP) > CAST(o.order_estimated_delivery_date AS TIMESTAMP) THEN 1 ELSE 0 END AS is_sla_breach
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
)
SELECT 
    customer_state,
    COUNT(*) AS delivered_orders,
    SUM(is_sla_breach) AS delayed_orders,
    ROUND(100.0 * SUM(is_sla_breach) / COUNT(*), 2) AS sla_breach_pct,
    ROUND(AVG(seller_handling_days), 2) AS avg_seller_handling_days,
    ROUND(AVG(carrier_transit_days), 2) AS avg_carrier_transit_days
FROM stage_times
GROUP BY customer_state
ORDER BY sla_breach_pct DESC;

-- 3. Category Pricing, GMV & Freight-to-Price Ratio (Margin Drag Analysis)
SELECT 
    p.product_category_name AS category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_gmv,
    ROUND(SUM(oi.freight_value), 2) AS total_freight,
    ROUND(100.0 * SUM(oi.freight_value) / SUM(oi.price), 2) AS freight_to_price_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY total_gmv DESC;

-- 4. Delivery Delay Cohort vs. Customer Review Score Impact
SELECT 
    CASE 
        WHEN DATE_DIFF('day', CAST(o.order_estimated_delivery_date AS TIMESTAMP), CAST(o.order_delivered_customer_date AS TIMESTAMP)) <= 0 THEN 'On-Time / Early'
        WHEN DATE_DIFF('day', CAST(o.order_estimated_delivery_date AS TIMESTAMP), CAST(o.order_delivered_customer_date AS TIMESTAMP)) <= 5 THEN 'Minor Delay (1-5 Days)'
        ELSE 'Severe Delay (>5 Days)'
    END AS delivery_tier,
    COUNT(*) AS orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    ROUND(100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_detractors
FROM orders o
JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_tier
ORDER BY avg_review_score DESC;

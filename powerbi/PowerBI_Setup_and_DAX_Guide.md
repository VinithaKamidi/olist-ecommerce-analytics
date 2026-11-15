# POWER BI DASHBOARD BUILD GUIDE & DAX MEASURES
File to import into Power BI Desktop: `powerbi/olist_powerbi_master_model.csv`

## 1. Key DAX Measures (Copy & Paste into Power BI -> New Measure)

Total GMV (Revenue) = SUM(olist_powerbi_master_model[price])

Total Freight Cost = SUM(olist_powerbi_master_model[freight_value])

Total Delivered Orders = 
CALCULATE(
    DISTINCTCOUNT(olist_powerbi_master_model[order_id]),
    olist_powerbi_master_model[order_status] = "delivered"
)

SLA Breach Orders = 
CALCULATE(
    DISTINCTCOUNT(olist_powerbi_master_model[order_id]),
    olist_powerbi_master_model[sla_status] = "Delayed",
    olist_powerbi_master_model[order_status] = "delivered"
)

SLA Breach Rate % = DIVIDE([SLA Breach Orders], [Total Delivered Orders], 0)

Freight-to-Price Ratio % = DIVIDE([Total Freight Cost], [Total GMV], 0)

Average Review Score = AVERAGE(olist_powerbi_master_model[review_score])

Avg Carrier Transit Days = AVERAGE(olist_powerbi_master_model[carrier_transit_days])

Avg Seller Handling Days = AVERAGE(olist_powerbi_master_model[seller_handling_days])

## 2. Recommended 2-Page Visual Layout
- **Page 1: Executive Commercial & Fulfilment Overview**
  - Top KPI Cards: `Total GMV (Revenue)`, `Total Delivered Orders`, `SLA Breach Rate %`, `Freight-to-Price Ratio %`, `Average Review Score`
  - Bar Chart: `SLA Breach Rate %` by `customer_state`
  - Line/Column Combo Chart: Monthly `Total GMV` & `Total Delivered Orders` by `order_purchase_timestamp`
  - Donut Chart: Order Share by `sla_status` (On-Time vs Delayed)

- **Page 2: Logistics Bottlenecks & Category Margin Analysis**
  - Clustered Bar Chart: `Avg Seller Handling Days` vs `Avg Carrier Transit Days` by `customer_state`
  - Bar Chart: `Freight-to-Price Ratio %` by `product_category_name`
  - Card / Bar Visual: `Average Review Score` split by `sla_status` (proving how SLA breaches drop ratings)
  - Slicers on Top: `customer_state`, `product_category_name`, `sla_status`

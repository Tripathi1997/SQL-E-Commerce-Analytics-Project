📊 Supply Chain / E-Commerce Analytics – Explanation & Notes
🎯 Project Objective

This project focuses on analyzing an end-to-end supply chain dataset (orders, products, inventory, shipments, returns) to derive actionable business insights using SQL.

Key goals:

Understand customer behavior
Optimize inventory and warehouse operations
Identify revenue drivers
Detect anomalies and inefficiencies
🧱 Data Model Overview

The dataset consists of the following core tables:

customers → customer details
orders → order-level information
order_items → product-level details per order
products → product catalog
inventory → stock levels per warehouse
warehouses → location data
shipments → delivery tracking
returns → returned orders
🔗 Relationships
customers → orders (1:M)
orders → order_items (1:M)
products → order_items (1:M)
warehouses → inventory (1:M)
orders → shipments (1:1 or 1:M)
orders → returns (optional relationship)
📌 Key Metrics & Concepts
1️⃣ Revenue Calculation
(oi.quantity * p.price) - oi.discount

👉 Represents net revenue

Includes discounts
Used across all revenue-based analysis
2️⃣ Average Order Value (AOV)
Total Revenue / Total Orders

👉 Measures customer spending behavior

3️⃣ Inventory Turnover
Total Sales / Total Stock

👉 Identifies:

Fast-moving products 🔥
Slow-moving / dead stock ⚠️
4️⃣ Delivery Time Gap
DATEDIFF(delivery_date, order_date)

👉 Measures supply chain efficiency

5️⃣ Return Percentage
Returned Quantity / Total Sold Quantity

👉 Helps detect:

Poor product quality
Logistics issues
🔥 Advanced Analytics Implemented
📊 1. Cohort Analysis (Customer Retention)
Customers grouped by first purchase month
Tracks how many return in subsequent months

Key logic:

TIMESTAMPDIFF(MONTH, first_order_date, order_date)

👉 Insights:

Retention drop patterns
Customer loyalty trends
📈 2. Pareto Analysis (80/20 Rule)
Identifies top contributors to revenue

Key logic:

SUM(revenue) OVER (ORDER BY revenue DESC)

👉 Insights:

Top 20% products drive ~80% revenue
Helps prioritize business focus
⚠️ 3. Anomaly Detection
Detects unusually large orders

Approaches:

Above average
Top percentile (NTILE)
Z-score method

👉 Use cases:

Fraud detection
Bulk order identification
🏆 4. Ranking & Window Functions

Used:

RANK() → handles ties
ROW_NUMBER() → strict ranking
NTILE() → percentile grouping

👉 Applications:

Top products per city
Customer segmentation
Sales ranking
📦 Supply Chain Insights
Inventory Optimization
Identify overstocked vs understocked items
Improve warehouse efficiency
Warehouse Performance
Compare stock levels across cities
Detect imbalance in distribution
Shipment Efficiency
Analyze delayed deliveries
Improve logistics planning
Return Analysis
High return % → quality/logistics issue
Helps reduce revenue loss
🧠 SQL Techniques Used
1. CTEs (Common Table Expressions)

👉 Used for:

Breaking complex queries
Improving readability
2. Window Functions

👉 Used for:

Ranking
Running totals
Cohort calculations
3. Subqueries

👉 Used for:

Filtering
Nested calculations
4. Joins

👉 Types used:

INNER JOIN
LEFT JOIN
⚠️ Common Pitfalls (Learnings)

❌ Using COUNT() instead of SUM() for quantity
❌ Ignoring duplicate rows due to joins
❌ Using ABS() in date differences (hides data issues)
❌ Not handling division by zero

🎯 Business Impact

This analysis helps:

Improve revenue by identifying top-performing products
Increase retention using cohort insights
Reduce inventory costs by optimizing stock
Detect anomalies and prevent potential fraud
Improve delivery performance
🚀 Conclusion

This project demonstrates how SQL can be used to:

Solve real-world business problems
Perform advanced analytics
Generate actionable insights

It bridges the gap between raw data and business decision-making.

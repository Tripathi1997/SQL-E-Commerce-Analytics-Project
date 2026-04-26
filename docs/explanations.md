# 📊 Supply Chain / E-Commerce Analytics

### Explanation & Notes

---

## 🎯 Project Objective

This project analyzes an **end-to-end supply chain dataset** (orders, products, inventory, shipments, returns) to generate **actionable business insights using SQL**.

### Key Goals

* Understand **customer behavior**
* Optimize **inventory & warehouse operations**
* Identify **revenue drivers**
* Detect **anomalies and inefficiencies**

---

## 🧱 Data Model Overview

### Core Tables

| Table         | Description                     |
| ------------- | ------------------------------- |
| `customers`   | Customer details                |
| `orders`      | Order-level information         |
| `order_items` | Product-level details per order |
| `products`    | Product catalog                 |
| `inventory`   | Stock levels per warehouse      |
| `warehouses`  | Warehouse location data         |
| `shipments`   | Delivery tracking               |
| `returns`     | Returned orders                 |

---

## 🔗 Relationships

| Relationship           | Type         |
| ---------------------- | ------------ |
| customers → orders     | 1 : Many     |
| orders → order_items   | 1 : Many     |
| products → order_items | 1 : Many     |
| warehouses → inventory | 1 : Many     |
| orders → shipments     | 1 : 1 / Many |
| orders → returns       | Optional     |

---

## 📌 Key Metrics & Concepts

### 1️⃣ Revenue Calculation

```sql
(oi.quantity * p.price) - oi.discount
```

* Represents **net revenue**
* Includes discounts
* Used across all revenue analysis

---

### 2️⃣ Average Order Value (AOV)

```text
Total Revenue / Total Orders
```

* Measures **customer spending behavior**

---

### 3️⃣ Inventory Turnover

```text
Total Sales / Total Stock
```

* Identifies:

  * 🔥 Fast-moving products
  * ⚠️ Slow-moving / dead stock

---

### 4️⃣ Delivery Time Gap

```sql
DATEDIFF(delivery_date, order_date)
```

* Measures **supply chain efficiency**

---

### 5️⃣ Return Percentage

```text
Returned Quantity / Total Sold Quantity
```

* Helps detect:

  * Product quality issues
  * Logistics inefficiencies

---

## 🔥 Advanced Analytics

### 📊 Cohort Analysis (Customer Retention)

* Groups customers by **first purchase month**
* Tracks repeat activity over time

```sql
TIMESTAMPDIFF(MONTH, first_order_date, order_date)
```

**Insights:**

* Retention drop patterns
* Customer loyalty trends

---

### 📈 Pareto Analysis (80/20 Rule)

* Identifies top revenue contributors

```sql
SUM(revenue) OVER (ORDER BY revenue DESC)
```

**Insights:**

* Top 20% products generate ~80% revenue
* Helps prioritize focus areas

---

### ⚠️ Anomaly Detection

* Detects unusually large or abnormal orders

**Approaches:**

* Above average
* Percentile (`NTILE`)
* Z-score

**Use Cases:**

* Fraud detection
* Bulk order identification

---

### 🏆 Ranking & Window Functions

| Function       | Purpose             |
| -------------- | ------------------- |
| `RANK()`       | Handles ties        |
| `ROW_NUMBER()` | Strict ranking      |
| `NTILE()`      | Percentile grouping |

**Applications:**

* Top products per city
* Customer segmentation
* Sales ranking

---

## 📦 Supply Chain Insights

### Inventory Optimization

* Identify overstocked vs understocked items
* Improve stock efficiency

### Warehouse Performance

* Compare stock distribution across cities
* Detect imbalances

### Shipment Efficiency

* Analyze delayed deliveries
* Improve logistics planning

### Return Analysis

* High return % → product/logistics issues
* Helps reduce revenue loss

---

## 🧠 SQL Techniques Used

### 1. CTEs (Common Table Expressions)

* Simplify complex queries
* Improve readability

### 2. Window Functions

* Ranking
* Running totals
* Cohort calculations

### 3. Subqueries

* Filtering
* Nested logic

### 4. Joins

* INNER JOIN
* LEFT JOIN

---

## ⚠️ Common Pitfalls (Learnings)

* ❌ Using `COUNT()` instead of `SUM()` for quantity
* ❌ Ignoring duplicates caused by joins
* ❌ Using `ABS()` in date differences (hides issues)
* ❌ Not handling division by zero

---

## 🎯 Business Impact

This analysis enables:

* 📈 Revenue growth through top product identification
* 🔁 Improved retention via cohort insights
* 📦 Reduced inventory costs
* ⚠️ Early anomaly/fraud detection
* 🚚 Better delivery performance

---

## 🚀 Conclusion

This project demonstrates how SQL can be used to:

* Solve **real-world business problems**
* Perform **advanced analytics**
* Generate **actionable insights**

It bridges the gap between **raw data and business decision-making**.

---

## 🎤 Interview Summary

> Built a supply chain analytics solution using SQL covering revenue analysis, cohort retention, anomaly detection, and inventory optimization to drive business insights.

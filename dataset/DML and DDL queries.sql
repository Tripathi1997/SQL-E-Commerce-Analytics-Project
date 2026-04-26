#--------------------------------------------------------------------------------------------------------------------
#                                DDL Queries
#--------------------------------------------------------------------------------------------------------------------

# Create DB scmDB as Supply Chain Management Database.
create database scmDB;

# Use scmDB and Create Tables
use scmDB;

-- Customers
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);

-- Suppliers
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100),
    rating DECIMAL(2,1)
);

-- Products
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);


-- Warehouses
CREATE TABLE warehouses (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_name VARCHAR(100),
    city VARCHAR(50)
);

-- Orders
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Order Items
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    discount DECIMAL(5,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
-- Inventory
CREATE TABLE inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    warehouse_id INT,
    stock INT
);

-- Shipments
CREATE TABLE shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    warehouse_id INT,
    shipment_date DATE,
    delivery_date DATE
);

-- Returns
CREATE TABLE returns (
    return_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    return_date DATE,
    reason VARCHAR(100)
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);


#--------------------------------------------------------------------------------------------------------------------
#                                DML Queries
#--------------------------------------------------------------------------------------------------------------------
#Insert into Customer Table
-- Generate 1M customers
INSERT INTO customers (customer_name, city, signup_date)
SELECT 
    CONCAT('Customer_', t.num),
    ELT(FLOOR(1 + RAND()*8),
        'Delhi','Mumbai','Bangalore','Chennai',
        'Hyderabad','Pune','Kolkata','Jaipur'),
    DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*1000) DAY)
FROM (
    SELECT 
        a.n + b.n*10 + c.n*100 + d.n*1000 + e.n*10000 + f.n*100000 AS num
    FROM numbers a
    CROSS JOIN numbers b
    CROSS JOIN numbers c
    CROSS JOIN numbers d
    CROSS JOIN numbers e
    CROSS JOIN numbers f
) t
WHERE t.num BETWEEN 1 AND 1000000;


#insert into Supplier
INSERT INTO suppliers
SELECT 
    t.num,
    CONCAT('Supplier_', t.num),
    ROUND(3 + RAND()*2, 1)  -- 3.0 to 5.0
FROM (
    SELECT a.n + b.n*10 + c.n*100 + d.n*1000 AS num
    FROM numbers a, numbers b, numbers c, numbers d
) t
WHERE t.num BETWEEN 1 AND 1000;


#insert into products
INSERT INTO products (product_name, category, price)
SELECT 
   

    -- Realistic Product Naming
    CONCAT(
        CASE 
            WHEN RAND() < 0.4 THEN ELT(FLOOR(1 + RAND()*5), 
                'iPhone', 'Samsung TV', 'Dell Laptop', 'Boat Headphones', 'Sony Speaker')
            WHEN RAND() < 0.7 THEN ELT(FLOOR(1 + RAND()*5), 
                'Nike Shoes', 'Adidas T-Shirt', 'Levis Jeans', 'Puma Jacket', 'Zara Shirt')
            ELSE ELT(FLOOR(1 + RAND()*5), 
                'Dining Table', 'Office Chair', 'Sofa Set', 'Bed Mattress', 'Kitchen Set')
        END,
        ' ',
        FLOOR(1 + RAND()*100)
    ) AS product_name,

    -- Category Distribution (Amazon-like)
    CASE 
        WHEN RAND() < 0.4 THEN 'Electronics'
        WHEN RAND() < 0.75 THEN 'Fashion'
        ELSE 'Home'
    END AS category,

    -- Pricing Strategy (Realistic Segments)
    ROUND(
        CASE 
            WHEN RAND() < 0.2 THEN RAND()*100000      -- premium
            WHEN RAND() < 0.6 THEN RAND()*20000       -- mid-range
            ELSE RAND()*5000                          -- budget
        END, 2
    ) AS price

FROM (
    SELECT 
        a.n + b.n*10 + c.n*100 + d.n*1000 + e.n*10000 AS num
    FROM numbers a
    CROSS JOIN numbers b
    CROSS JOIN numbers c
    CROSS JOIN numbers d
    CROSS JOIN numbers e
) t
WHERE t.num BETWEEN 1 AND 10000;

#insert into warehouses
INSERT INTO warehouses(warehouse_name,city)
SELECT 
    CONCAT('Warehouse_', t.num),
    ELT(FLOOR(1 + RAND()*6),
        'Delhi','Mumbai','Bangalore','Hyderabad','Kolkata','Chennai')
FROM (
    SELECT a.n + b.n*10 AS num
    FROM numbers a, numbers b
) t
WHERE t.num BETWEEN 1 AND 50;

#insert into Orders
INSERT INTO orders (customer_id, order_date, status)
SELECT 
    c.customer_id,

    -- realistic order date
    DATE_ADD(
        DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*365) DAY),
        INTERVAL FLOOR(RAND()*30) DAY
    ),

    CASE 
        WHEN RAND() < 0.7 THEN 'DELIVERED'
        WHEN RAND() < 0.85 THEN 'PENDING'
        WHEN RAND() < 0.95 THEN 'CANCELLED'
        ELSE 'RETURNED'
    END

FROM customers c
JOIN (
    SELECT 
        a.n + b.n*10 + c.n*100 + d.n*1000 + e.n*10000 + f.n*100000 AS num
    FROM numbers a
    CROSS JOIN numbers b
    CROSS JOIN numbers c
    CROSS JOIN numbers d
    CROSS JOIN numbers e
    CROSS JOIN numbers f
) t
ON t.num <= 1000000
LIMIT 1000000;


#Insert into order item
INSERT INTO order_items (order_id, product_id, quantity, discount)
SELECT 
    o.order_id,

    -- Fast product selection with skew (no subquery)
    CASE 
        WHEN RAND() < 0.6 THEN FLOOR(1 + RAND()*100)   -- top 100 products
        ELSE FLOOR(1 + RAND() * p_max.max_id)          -- full range
    END AS product_id,

    FLOOR(1 + RAND()*5) AS quantity,

    ROUND(
        CASE 
            WHEN RAND() < 0.3 THEN RAND()*30
            ELSE RAND()*10
        END, 2
    ) AS discount

FROM orders o

-- Precompute max product_id (runs once, not per row)
JOIN (SELECT MAX(product_id) AS max_id FROM products) p_max

-- Use numbers table only to expand rows
JOIN numbers n1
JOIN numbers n2

LIMIT 150000;


#insert into inventory
INSERT INTO inventory (product_id, warehouse_id, stock)
SELECT 
    p.product_id,
    w.warehouse_id,

    FLOOR(
        CASE 
            WHEN RAND() < 0.3 THEN RAND()*50     -- low stock
            ELSE RAND()*500                      -- normal stock
        END
    ) AS stock

FROM products p
JOIN warehouses w

-- Expand rows (to reach ~100K)
JOIN numbers n1
JOIN numbers n2

LIMIT 100000;


#insert into shipments
INSERT INTO shipments (order_id, warehouse_id, shipment_date, delivery_date)
SELECT 
    o.order_id,
    w.warehouse_id,

    -- Generate shipment date once
    s.shipment_date,

    -- Delivery = shipment + 1–7 days
    DATE_ADD(s.shipment_date, INTERVAL FLOOR(1 + RAND()*7) DAY) AS delivery_date

FROM orders o
JOIN warehouses w

-- Generate shipment date once per row
JOIN (
    SELECT 
        DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*30) DAY) AS shipment_date
) s

-- Expand rows
JOIN numbers n1
JOIN numbers n2

LIMIT 500000;

#insert into return
INSERT INTO returns (order_id, return_date, reason)
SELECT 
    o.order_id,

    -- Return happens after order_date (realistic)
    DATE_ADD(o.order_date, INTERVAL FLOOR(1 + RAND()*30) DAY) AS return_date,

    ELT(FLOOR(1 + RAND()*4),
        'Defective','Wrong Item','Damaged','Changed Mind'
    ) AS reason

FROM orders o

-- Only some orders are returned (~8%)
WHERE RAND() < 0.08

LIMIT 80000;

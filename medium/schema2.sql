#-----------------------------------------------------------------------------------------------------------------------
#                                        INTERMEDIATE
#-----------------------------------------------------------------------------------------------------------------------

#11. Revenue per Order
#Problem:
#Calculate total revenue for each order.

#oi-o-p->price

select product_id,price from products;
with order_revenue as (
select oi.order_id,oi.order_item_id,oi.quantity,p.product_id,p.price,(oi.quantity*p.price) as product_revenvue
from order_items oi inner join products p on oi.product_id = p.product_id)
select order_id, sum(product_revenvue) from order_revenue group by order_id;

select oi.order_id, SUM((oi.quantity*p.price)-(oi.discount)) as revenuePerOrder
from order_items oi inner join products p
on oi.product_id = p.product_id
group by oi.order_id;


#12. Top 3 Expensive Products
#Problem:
#Return top 3 highest priced products.

select product_id,product_name,price from products
order by price desc limit 3;

SELECT product_id, product_name, price
FROM (
    SELECT 
        product_id, 
        product_name, 
        price,
        DENSE_RANK() OVER (ORDER BY price DESC) AS rnk
    FROM products
) t
WHERE rnk <= 3;

#13. Total Quantity Sold
#Problem:
#Find total quantity sold per product.

select SUM(oi.quantity) as total_quantity_sold,oi.product_id from
order_items oi
group by oi.product_id;

#14. Customers with Multiple Orders
#Problem:
#Find customers who placed more than 1 order.

select o.customer_id,count(o.order_id) as order_count,c.customer_name
from orders o
group by o.customer_id,c.customer_name
having count(o.order_id) > 1;

#15. Average Order Value
#Problem:
#Calculate average order value per customer.
WITH order_value AS (
SELECT
oi.order_id,
SUM((oi.quantity * p.price) - oi.discount) AS order_value
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY oi.order_id
)
SELECT
o.customer_id,
SUM(ov.order_value) AS total_revenue,
COUNT(*) AS total_orders,
AVG(ov.order_value) AS avg_order_value
FROM order_value ov
JOIN orders o
ON ov.order_id = o.order_id
GROUP BY o.customer_id;

#16. Products Never Ordered
#Problem:
#Find products that were never purchased.

select p.product_id, p.product_name from products p
where not exists (select 1 from order_items oi where oi.product_id = p.product_id);


#17. Orders with Discount
#Problem:
#Find orders where discount > 0.

select order_id from order_items where discount > 0 group by order_id;

#18. Delayed Shipments
#Problem:
#Find shipments where delivery took more than 3 days.
select shipment_id, order_id, warehouse_id, DATEDIFF(delivery_date,shipment_date) as ShipmentDays from shipments
where DATEDIFF(delivery_date,shipment_date) > 3;

WITH shipment_delay AS (
    SELECT 
        shipment_id, 
        order_id, 
        warehouse_id, 
        DATEDIFF(delivery_date, shipment_date) AS shipment_days
    FROM shipments
)
SELECT *
FROM shipment_delay
WHERE shipment_days > 3;

#19. Warehouse with Max Stock
#Problem:
#Find warehouse having highest inventory.
WITH total_stocks AS (
    SELECT 
        warehouse_id,
        SUM(stock) AS warehouse_total_stock
    FROM inventory
    GROUP BY warehouse_id
)
SELECT *
FROM total_stocks
WHERE warehouse_total_stock = (
    SELECT MAX(warehouse_total_stock) FROM total_stocks
);

#20. Monthly Orders Trend
#Problem:
#Count orders per month.

select count(*) as Total_Orders_Per_Month,month(order_date) as Order_Month,year(order_date) as Order_Year 
from orders group by Order_Month,Order_Year order by Order_Year,Order_Month;

#21. Category Revenue
#Problem:
#Calculate total revenue per category.

with item_category as
(select SUM((oi.quantity*p.price)-oi.discount) as Category_Revenue,p.category as Category
from order_items oi join products p on oi.product_id = p.product_id
group by p.category)
select * from item_category;

#22. Customers with Returns
#Problem:
#Find customers who returned products.

SELECT DISTINCT 
    c.customer_id,
    c.customer_name
FROM returns r
JOIN orders o 
    ON r.order_id = o.order_id
JOIN customers c 
    ON o.customer_id = c.customer_id;
    
#23. Orders per Supplier
#Problem:
#Count number of orders handled by each supplier.

ALTER TABLE products 
ADD supplier_id INT;

ALTER TABLE products 
ADD FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id);

UPDATE products
SET supplier_id = CASE 
    WHEN RAND() < 0.5 THEN FLOOR(1 + RAND()*3)   -- top suppliers
    ELSE FLOOR(4 + RAND()*7)                     -- others
END;

SELECT 
    s.supplier_id,
    s.supplier_name,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM suppliers s
JOIN products p 
    ON s.supplier_id = p.supplier_id
JOIN order_items oi 
    ON p.product_id = oi.product_id
GROUP BY s.supplier_id, s.supplier_name;

#24. Inventory by Product
#Problem:
#Total stock per product.

select product_id,  sum(stock) as Stock_Per_product
from inventory group by product_id; 

#25. Top Selling Products
#Problem:
#Find top 5 most sold products.

select product_id,sum(quantity) as total_sold_product
from order_items group by product_id order by total_sold_product desc LIMIT 5;

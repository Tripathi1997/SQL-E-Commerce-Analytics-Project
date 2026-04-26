🟢 EASY (10)

#1. Customers in Delhi
#Problem:
#Find all customers located in Delhi.
#Tables: customers
#Output: customer_id, customer_name

select * from customers where city = 'Delhi';

#2. Expensive Products
#Problem:
#Find products with price greater than 50,000.

SELECT * FROM products WHERE price > 50000;

#3. Delivered Orders
#Problem:
#Get all orders with status = 'DELIVERED'.

SELECT * FROM orders WHERE status = 'DELIVERED';

#4. Count Customers per City
#Problem:
#Return city and total customers.

select city, count(customer_id) as total_customer from customers group by 1;

#5. Total Orders
#Problem:
#Find total number of orders.

select count(order_id) as total_order from orders;

#6. Electronics Products
#Problem:
#List all products in Electronics category.

select distinct product_name from products where category = 'Electronics';


#7. High Rated Suppliers
#Problem:
#Find suppliers with rating > 4.

select * from suppliers where rating > 4;

#8. Orders in January
#Problem:
#Find orders placed in January 2024.

select * from orders where month(order_date) = '01' and year(order_date) = '2024'; 

SELECT *
FROM orders
WHERE order_date >= '2024-01-01'
  AND order_date < '2024-02-01';

#9. Warehouse in Mumbai
#Problem:
#Find warehouses located in Mumbai.

select * from warehouses where city = 'Mumbai';

#10. Total Stock
#Problem:
#Find total inventory stock.
select sum(stock) from inventory;

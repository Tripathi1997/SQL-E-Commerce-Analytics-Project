# ------------------------------------------------------------------------------------------------------
#                            HARD
# ------------------------------------------------------------------------------------------------------

#🔥 Window Functions
#26. Rank Products by Sales
#Return product rank based on total quantity sold.
select * from (
select product_id,sum(quantity) as total_sold_product,RANK() OVER (order by sum(quantity) desc) as rnk
from order_items group by product_id) t where rnk <= 5;

#27. Running Revenue
#Calculate cumulative revenue over time.

select oi.order_id,sum((oi.quantity * p.price) - oi.discount) as revenvue_per_order,
sum(sum((oi.quantity * p.price) - oi.discount)) over (order by o.order_date) as cumulative_revenvue
from order_items oi join products p on oi.product_id = p.product_id
join orders o on oi.order_id = o.order_id
group by oi.order_id, o.order_date
order by o.order_date;

#28. Top Product per Category
#Use ROW_NUMBER to find the best product per category.
with top_product_per_category as 
(select p.category, sum(oi.quantity) as total_quantity,ROW_NUMBER() over (PARTITION BY p.category order by sum(oi.quantity)) as rankNumber
from order_items oi join products p on oi.product_id = p.product_id group by p.category,p.product_id)
select category,rankNumber, total_quantity
from top_product_per_category where rankNumber = 1;


#29. Moving Average Sales
#Calculate a 3-day moving average of sales.

WITH daily_sales AS (
    SELECT 
        o.order_date,
        SUM((oi.quantity * p.price) - oi.discount) AS daily_revenue
    FROM order_items oi
    JOIN orders o 
        ON oi.order_id = o.order_id
    JOIN products p 
        ON oi.product_id = p.product_id
    GROUP BY o.order_date
)
SELECT 
    order_date,
    daily_revenue,
    AVG(daily_revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_3_day_avg
FROM daily_sales;

#30. Repeat Customers
#Find customers who ordered more than once.
select customer_id,count(*) as order_per_customer from orders
group by customer_id having count(*) > 1;

#31. High Value Customers
#Customers spending above average.
select * from (
select o.customer_id,
	   sum((oi.quantity * p.price) - oi.discount) as total_spend,
       avg(sum((oi.quantity * p.price) - oi.discount)) over () as avg_spend
from order_items oi join products p on oi.product_id = p.product_id
join orders o on oi.order_id = o.order_id
group by o.customer_id) x
where total_spend > avg_spend;

#32. Stock-Out Risk
#Products with stock < avg stock.
select * from 
(
 select product_id,sum(stock) as total_stock,avg(sum(stock)) over () as avg_stock from inventory group by product_id
) x
where total_stock < avg_stock;

#33. Pareto Analysis
#Find products contributing 80% revenue.

with product_revenvue as
(
	select oi.product_id,
           sum((oi.quantity * p.price) - oi.discount) as product_revenvue
	from order_items oi join products p on oi.product_id = p.product_id
	group by oi.product_id
),
pareto as
(
	select product_id,product_revenvue,
           sum(product_revenvue) over () as total_revenvue,
           sum(product_revenvue) over (order by product_revenvue desc) as running_revenvue
	from product_revenvue
   
)

select product_revenvue,round(running_revenvue / total_revenvue,3) as cum_revenvue
from pareto
where running_revenvue <= 0.8 * total_revenvue;

#34. Above Category Avg Price
#Products priced above category average.
select * from 
(
	select p.product_id,p.category,p.price,
           avg(p.price) over (partition by p.category) as category_avg_price
           from products p
) x
where price > category_avg_price;

#or

select p.product_id,p.category,p.price
from products p where p.price > (select avg(p2.price) from products p2
								 where p2.category = p.category
								);

#35. Customers Without Returns
#Customers who never returned any order.
SELECT 
    c.customer_id,
    c.customer_name
FROM customers c
WHERE c.customer_id NOT IN (
    SELECT o.customer_id
    FROM orders o
    JOIN returns r 
        ON o.order_id = r.order_id
);

#36. Best Supplier
#Supplier with highest total sales.

select * from
(
	select s.supplier_id,sum((oi.quantity * p.price) - oi.discount) as total_sales,
    max(sum((oi.quantity * p.price) - oi.discount)) over () as maximum_sale
	from order_items oi join products p on oi.product_id = p.product_id
	join suppliers s on s.supplier_id = p.supplier_id
	group by s.supplier_id
) x
where total_sales = maximum_sale;

select * from
(
	select s.supplier_id,sum((oi.quantity * p.price) - oi.discount) as total_sales,
    rank() over (order by sum((oi.quantity * p.price) - oi.discount)  DESC)  as rnk
	from order_items oi join products p on oi.product_id = p.product_id
	join suppliers s on s.supplier_id = p.supplier_id
	group by s.supplier_id
) x
where rnk = 1;

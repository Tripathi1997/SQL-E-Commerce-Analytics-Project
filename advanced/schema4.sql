#---------------------------------------------------------------------------------------------------------------------
#                            BUSINESS PROBLEMS
#---------------------------------------------------------------------------------------------------------------------

#37. Return Rate
#Return % per product.

with total_product_order as
(
	select oi.product_id, sum(oi.quantity) as total_product_order
    from order_items oi
    group by oi.product_id
),
return_order_product as
(
	select oi.product_id, sum(oi.quantity) as return_product
    from order_items oi join returns r
    on oi.order_id = r.order_id
    group by oi.product_id
)
select tpo.product_id, coalesce(return_product ,0) * 100 / tpo.total_product_order as return_pct
from return_order_product rop  right join total_product_order tpo
on rop.product_id = tpo.product_id
order by return_pct desc;

#38. Revenue Loss
#Revenue lost due to returns.
SELECT 
    SUM((p.price * oi.quantity) - oi.discount) AS total_revenue_lost
FROM order_items oi 
JOIN products p 
    ON oi.product_id = p.product_id
JOIN returns r 
    ON r.order_id = oi.order_id;
    
#39. Inventory Turnover
#Sales / average inventory.
#1. we need total sales
#2. we need total stocks per product
#3. turnover = sales/total stocks per product

with product_sales as
(
	select oi.product_id,sum((oi.quantity * p.price) - oi.discount) as total_sales
    from order_items oi join products p on oi.product_id = p.product_id
    group by oi.product_id
),
product_stocks as
(
	select product_id,sum(stock) as product_stocks
    from inventory
    group by product_id
)
select ps.product_id, ps.total_sales, sp.product_stocks, ps.total_sales /nullif(sp.product_stocks,0) as product_turnover
from product_sales ps join product_stocks sp on ps.product_id = sp.product_id;

#40. Fast vs Slow Products
#Classify based on sales.
select product_id, total_sales, avg_sales,
case when total_sales > avg_sales then 'FAST'
ELSE 'SLOW' end
from
(
	select oi.product_id, sum((oi.quantity * p.price) - oi.discount) as total_sales,
    round(avg(sum((oi.quantity * p.price) - oi.discount)) over (),2 )as avg_sales
    from order_items oi join products p
    on oi.product_id = p.product_id
    group by oi.product_id
    
)x;

#--------------------------------------------------------------------------------------------------------------------
#                             VERY HARD (INTERVIEW TYPE)
#--------------------------------------------------------------------------------------------------------------------

#41. Cohort Analysis
#Monthly retention of customers.
with first_purchase as 
(
	select customer_id,min(order_date) as first_order_date
	from orders o
	group by customer_id
),
cohort_data as
(
	select o.customer_id,DATE_FORMAT(fp.first_order_date, '%Y-%m') as cohort_month,
	timestampdiff(month,fp.first_order_date,o.order_date) as month_number
	from orders o join first_purchase fp
	on o.customer_id = fp.customer_id
)
select cohort_month, month_number,
count(distinct customer_id) as retained_customer
from cohort_data
group by cohort_month,month_number
order by cohort_month,month_number;

#42. Top 2 Products per City
#Use window function.
select * from 
(
	select i.product_id,w.city,sum(i.stock) as total_stocks,
	rank() over (partition by w.city order by sum(i.stock) desc) as rnk
	from warehouses w join inventory i on w.warehouse_id = i.warehouse_id
	group by i.product_id,w.city
) x
where rnk <= 2;

#43. Duplicate Orders
#Detect duplicate entries.
select order_id,product_id,count(*) as duplicate_order_count
from order_items
group by product_id,order_id
having count(*) > 1;

#44. Delivery Time Gap
#Order → Delivery days.

select o.order_id,o.order_date,s.delivery_date, datediff(delivery_date,order_date) as delivery_time_gap
from orders o join shipments s
on o.order_id = s.order_id;

#45. Anomaly Detection
#Orders with unusually high quantity.
#BASIC AVERAGE APPROACH
SELECT *
FROM (
    SELECT 
        order_id,
        SUM(quantity) AS total_quantity,
        AVG(SUM(quantity)) OVER () AS avg_quantity
    FROM order_items
    GROUP BY order_id
) x
WHERE total_quantity > avg_quantity;
#TOP PERCENTILE (BUSINESS FRIENDLY) - 5%
SELECT *
FROM (
    SELECT 
        order_id,
        SUM(quantity) AS total_quantity,
        NTILE(100) OVER (ORDER BY SUM(quantity) DESC) AS percentile_rank
    FROM order_items
    GROUP BY order_id
) t
WHERE percentile_rank <= 5;

#Z-SCORE - Statistical Anamolies
SELECT *
FROM (
    SELECT 
        order_id,
        SUM(quantity) AS total_quantity,
        AVG(SUM(quantity)) OVER () AS avg_q,
        STDDEV(SUM(quantity)) OVER () AS std_q
    FROM order_items
    GROUP BY order_id
) t
WHERE total_quantity > avg_q + 2 * std_q;

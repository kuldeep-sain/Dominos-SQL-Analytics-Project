----------------------------"Clean E-commerce Database"------------------------------------------------------- 
--Step 1 :- To cheak for Duplicates 
-- Way 1 
Delete from customers
       where custid not in (
       select MIN(custid) 
from orders
Group by email
-- Way 2 
Delete from customers
where custid in (
      select custid
from (
	   select custid,email,
			  ROW_NUMBER () over (partition by email order by custid) as rn 
	   from customers
) t
where t.rn >1

select * from orders
where custid in (102, 103)

--Step 2 :- Cheak  for Null  Values / Treating Null values 
select * from customers

update customers set phone = 0 where phone is null
update  customers set phone = ' _ ' where phone is null

--Step 3 :- Handling Nagative Values 

update order_details 
set quantity = 0 
where quantity < 1

select * from order_details

--Step 4 :- Fixing Inconsistent Date Formats & Invalid Dates 

select  * from orders where order_date is null 

select order_id, order_date from orders
where  order_date = (19|20)\d\d-(
--Step 5 :- Fixing Invalid Email Addresses 
--Step 6 :- Checking the datatype

select * from customers


---------------------------------"Dominos Store"-----------------------------------------------------------------
-- Analysis & Reports 
/*
1. Orders Volume Analysis Queries 
Stakeholder (Operations Manger):

" We are trying to understand our order volume in detail so we can store performance and benchmark growth.
Instead of just knowing the total number of unique orders, I'd likea deeperbreakdown:
what

--- What is the totalnumber of unique order placedso far?
--- How has this order volume changed month-over-month and year-over-year?
--- Can we identify peak and off-peak orderingdays?
--- How do order volumes vary by dayof the week(e.g., weekend vs weekdays)?
--- What is the averagenumber of order per customer?
--- Who are our top repeat customers driving the order volume?
--- Can you also project the expected order growth trend based on historical data?"
*/
--Analysts Tasks:
-- 1.1.Count the total number of unique orders (count(Distinct order_id)).
  Select count(Distinct order_id) from orders
 
-- 1.2.Break down orders by month and year (Group BY Extract(Month/Year From order_date)).
WITH monthly_orders AS (
    SELECT 
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS [month],
        COUNT(order_id) AS order_count
    FROM orders
    GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
)
SELECT 
    [month],
    order_count,
	lag(order_count) over(order by month ) as prev_month,
    ROUND(100.0 * (order_count - lag(order_count) over(order by month)) / nullif(lag(order_count) over(order by month),0),1) AS mom_growth_pct
FROM monthly_orders;

-- 1.3. Find day-wise order distribution (To_char(order_date, 'Day')).
-- Orders by day of week
SELECT 
    DATENAME(WEEKDAY, order_date) AS weekday,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY DATENAME(WEEKDAY, order_date)
ORDER BY total_orders;

-- 1.4.* Comptute average orders per customer (count(order_id)/count(distict custid)).
-- Average Orders per customer 
select 
Round(count(distinct order_id) * 1.0/
count(distinct custid),2) as avg_orderPer_customer
from orders

-- 1.5.Identify repeat cutomers and  and their order frequency (Having count(order_id) >1 ).
-- Repeat Customers(with Frequency)
select 
custid,
count(distinct order_id) as order_count
from orders
group by custid
order by order_count desc

-- 1.6. Use window function to calculate month_over-month growth % (lag(order_cont) over).
-- Mont-over-month Growth using window
WITH monthly_orders AS (
    SELECT 
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS [month],
        COUNT(order_id) AS order_count
    FROM orders
    GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
)
SELECT 
    [month],
    order_count,
	lag(order_count) over(order by month ) as prev_month,
    ROUND(100.0 * (order_count - lag(order_count) over(order by month)) / nullif(lag(order_count) over(order by month),0),1) AS mom_growth_pct
FROM monthly_orders;


-- 1.7. Build a trend projection using cumulative counts or forecasting methods.
-- Cumulative Order Trend 
Select Order_date,
Count(order_id) as daily_orders,
Sum(count(order_id)) over(order by order_date) as cumlative_orders
from orders
Group by order_date
order by order_date


/* 
2. Total Revenue from Pizza Sales
   Stakeholder (Finance Team):

" we need to report monthly revenue to management.
  Can you calculate the total revenue generated from pizza sales,
  considering price  quantity from each order? "

Analyst Task: Join order_details with pizzas and sum ( price * quantity).
*/

Select Sum(od.quantity * p.price) as total_revenue
from order_details od
join pizzas p on od.pizza_id = p.pizza_id


/*
3. Highest-Priced Pizza
   Stakeholder (Menu Manager):

" Our premium pizzas must be correctly priced. Can youfind out which pizza 
  has the highest price on our menu and confirm its category and size?"
Analyst Task: Query the pizza table for the maximum price, joining with pizza_types for details.
*/
select 
pt.name,
p.size,
concat('$', p.price) as price
from pizzas p
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
order by p.price desc


/* 
4. Most Common Pizza size ordered
   Stakeholder (Logistics Manager):
" To optimize packaging and raw material supply, I need to know which 
  pizza size (S, M, L, XL,XXL0 is ordered the most 

Analyst Task: Count and group orders by pizza size from pizza + order_details
*/
Select p.size,count(*) as total_orders
from order_details od
join pizzas p on od.pizza_id =p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
Group by p.size
order by total_orders desc


/*
5. Top 5 Most Ordered Pizza Types
   Stakeholder(Product Head):

" We want to promote our top-selling pizzas. can you provvide the 5 pizza
  types ordered by quantity, along with the exact number of units sold? "

Analyst Task: Join order_details with pizza_types, group by pizza name, and  rank top 5.

*/

select top 5
p.pizza_id,
Sum(od.quantity) as total_qty
from Order_details od
join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
Group by p.pizza_id
order by total_qty desc


/*
6. Total Quantity by Pizza Category
   Stakeholder(Marketing Manager):

" We run promation based on categories (classic, Veggie, supreme, chicken, etc.).
  can you calculate the total number of pizza sold in each category
  so we can plan targeted campaigns? "

Analyst Task; join pizzas with pizza_types and sum quantities by category.

*/

select 
pt.category,
sum(od.quantity) as total_qty
from order_details od 
join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id 
Group by pt.category   


/*
7. Orders by Hour of the Day
   Stakeholder ( Operations Head):

" When are customers ordering the most? Do prefer lunch (12-2 pm ),
  evening (6-9 pm), or late-night? Please give me a distribution 
  of orders by hour of the day so we adjust staffing."

Analyst Task: Extract the hour from the ordertime in orders table and count frequency.

*/

-- it rong ans 

SELECT 
    FORMAT(CAST(order_time AS time), 'HH::00') AS order_hour,
    COUNT(*) AS order_count
FROM orders
GROUP BY FORMAT(CAST(order_time AS time), 'HH::00')
ORDER BY order_hour 



/*
8. Category-wise Pizza Distribution
   Stakeholder (Product Strategy Team):

" Which categories (like Veggiee, Chicken, Supreme) dominate
  Our menu sales? Can you prepare a breakdown of orders per category per category with percentage share?"

Analyst Task: Join tables and calculate share of each category.
*/

select
pt.category Category,
Sum(od.quantity) Quantity,
 ROUND(
        100.0 * SUM(od.quantity) / 
        SUM(SUM(od.quantity)) OVER (), 
    2) AS PercentageShare
from pizza_types pt
join pizzas p on pt.pizza_type_id = p.pizza_type_id 
join order_details od on  od.pizza_id = p.pizza_id
group by pt.category


/* 
9. Average Pzzas Ordered per Day 
   Stakehlder (CEO):

" I want to see if our daily demand is consistent.
can you group orders by date and tell me the average number odf pizzas ordered per Day?"

Analyst TAsk: Aggregate by  Order_date, calculate total pizzas per day, then average.

*/

SELECT 
    ROUND(AVG(daily_total), 2) AS avg_pizzas_per_day
FROM (
    SELECT 
        o.order_date, 
        SUM(od.quantity) AS daily_total
    FROM orders o
    JOIN order_details od 
        ON o.order_id = od.order_id
    GROUP BY o.order_date
) t



/*
10. Top 3 Pizzas by Revenue
    Stakeholder (Finance Team):

" We need to know which pizzas are biggest revenue drivers.
  Please provide the top 3 pizzas by revenue generated."

Analyst Task: Calculate revenue per pizza (Price * quantity) and rank top 3.

*/

with pizza_revenue as (
     
     select 
     pt.name,
     sum(od.quantity * p.price) as revenue,
     Rank() over(order by sum(od.quantity * p.price) desc) as rank
     from order_details od
     join pizzas p on od.pizza_id = p.pizza_id
     join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
     group by pt.name
)
select name, revenue
from pizza_revenue
where rank <=3

/*
11. Revenue Contribution per Pizza 
    Stakeholder (CFO):

" For our revenue mix analysis, I need to know what percentage of 
  Total revenue each pizza contributes.
  This will show which items carry the business."

Analyst Task: Divide revenue of each pizza by total revenue, express in %,
*/

Select  
      pt.name,
      Sum(od.quantity * p.price) as revenue,
      Concat(Round(100.0 * Sum(od.quantity * p.price) / Sum(Sum(od.quantity * p.price)) over(),2),'%') as pct_contribution
From order_details od 
Join pizzas p on od.pizza_id = p.pizza_id
Join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
Group by pt.name
Order by pct_contribution desc

/*
12. Cumulative Revenue Over Time 
    Stakeholder(Board of Directors):

" We want to see how our cumulative revenue has grown moth by month 
  since launch. Can you prepare a cumulative revenue trend line? "

Analyst Task: Aggregate revenue by date/month and calculate running total.

*/

Select 
order_date,
Sum(daily_revenue) over (order by order_date) as cumulative_revenue
from (
       Select
       o.order_date,
       sum(od.quantity * p.price) as daily_revenue
       from orders o
       join order_details od on o.order_id = od.order_id
       join pizzas p on od.pizza_id = p.pizza_id
       group by o.order_date
) t


/*
13. Top 3 Pizzas by category (Revenue-Based)
    Stakeholder (Product Head)

" Within each pizza category, which 3 pizzas bring the most revenue?
  This will help us decide which pizzas to promote ode expand,"

Analyst Task: Partition by catagory, calculate revenue per pizza, rank top 3.

*/

with cat_rank as 
(
select
pt.category,
pt.name,
sum(od.quantity* p.price) as revenue,
rank() over (Partition by pt.category order by sum(od.quantity * p.price) desc) as rnk
from order_details od
join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
Group by pt.category, pt.name
)

select category, name, revenue
from cat_rank
where rnk <= 3

/*
14. Top 10 Customers by spending 
    Stakeholder (Customer Retention Manager):

" Who are our top 10 customers based on total speed?
  We want to reward then loyalty offer. "

*/

SELECT Top 10
    c.custid,
    c.first_name + ' ' + c.last_name AS name,
    SUM(od.quantity * p.price) AS total_spent
FROM Customers c
JOIN Orders o ON c.custid = o.custid
JOIN Order_Details od ON o.order_id = od.order_id
JOIN Pizzas p ON od.pizza_id = p.pizza_id
GROUP BY c.custid, c.first_name, c.last_name
ORDER BY total_spent DESC;


/* 
15. Orders by weekday 
    Stakeholder (Marketing Team):

" Which days of the week are busiest for orders?
  Do customers order more on weekends? "
*/

SELECT 
    DATENAME(WEEKDAY, order_date) AS Weekday,
    COUNT(DISTINCT order_id) AS TotalOrders
FROM orders
GROUP BY DATENAME(WEEKDAY, order_date)
ORDER BY TotalOrders DESC

/* 
16. Average Order size
    Stakeholder (Supplyy chain Manager):

" What's the average number of pizzas per order?
  This helps us in planning inventory and staffing."
*/

Select
Round(avg(order_size),0) as Avg_order_size
from 
(  
select 
od.order_id,
Sum(od.quantity) as order_size
from order_details od
group by od.order_id
) t

/*
17. Seasonal Trends
    Stakeholder (Oprations Manager):

" Do we see peak sales in certain months or holidays?
  This will help us manage seasonal demand."
*/

SELECT 
    MONTH(order_date) AS month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY MONTH(order_date)
ORDER BY month


/*
18. Revenue by Pizza size
    Stakeholder (Finance Head):

" What is the revenue contribution of each pizza
  size (S, M, L, XL, XXL)?"
*/

SELECT 
    p.size AS PizzaSize,
    SUM(od.quantity * p.price) AS Revenue
FROM pizzas p
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY Revenue DESC

/*
19. Customer Segmentation 
    Stakeholder (Customer Insights Team):

" Do our high-value customers prefer premium pizza or 
  regular pizzas? we want to personalize marketing."
*/

WITH cust_spend AS (
    SELECT
        c.custid,
        SUM(od.quantity * p.price) AS total_spent
    FROM customers c
    JOIN orders o ON c.custid = o.custid
    JOIN order_details od ON o.order_id = od.order_id
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY c.custid
)
SELECT 
    CASE 
        WHEN total_spent > 1500 THEN 'High Value'
        ELSE 'Regular'
    END AS segment,
    COUNT(*) AS customer_count
FROM cust_spend
GROUP BY 
    CASE 
        WHEN total_spent > 1500 THEN 'High Value'
        ELSE 'Regular'
    END;



/*
20. Repeat Customer Rate 
    Stakeholder (CRM Head - Customer Relationship Manager):

" We want to measure customer layalty. Can you calculate the percentage 
  of repeat customers (customers who placed more than one order)
  versus one-time buyers? This will help us design retention campaigns."

Analyst Task: 
             From the orders table, count distinct customers.
             Count how many customers have more than one order.
             Calculate repeat rate = (repeat customers + total customers) * 100.
*/

with cust_orders as 
(
      select 
      custid, 
	  count(distinct order_id) as order_count
      from orders
      group by custid
)
select 
      round(
	  100.0 * sum(case when order_count > 1 then 1 else 0 end) / count(*),
	  2) as repeat_rate
from cust_orders
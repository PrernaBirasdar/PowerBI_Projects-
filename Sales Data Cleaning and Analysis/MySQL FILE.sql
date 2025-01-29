
select * from  table1; 

CREATE TABLE table1 (
    order_id INT PRIMARY KEY,
    order_date DATE ,
    ship_mode VARCHAR(20) ,
    segment VARCHAR(20) ,
    country VARCHAR(20) ,
    city VARCHAR(20) ,
    state VARCHAR(20) ,
    postal_code VARCHAR(10),
    region VARCHAR(20) , 
    category VARCHAR(20) ,
    sub_category VARCHAR(20) ,
    product_id VARCHAR(50) ,
    quantity INT ,
    discount_price DECIMAL(10,2) ,
    sale_price DECIMAL(10,2) ,
    profit DECIMAL(10,2)
    ); 

ALTER TABLE table1 
MODIFY COLUMN order_date DATE;

SHOW tables FROM SQL_DATA; 
DESCRIBE table1;


SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'sql_data' AND TABLE_NAME = 'table1';

SHOW DATABASES;
USE sql_data;
SHOW TABLES;

-- 1st find top 10 highest revenue generating products 
select product_id , sum(sales_price) as sales 
from table1
group by product_id 
order by sales desc limit 10;

-- 2nd find top 5 highest selleing products in each region 
select distinct region from table1;

select region, product_id,sum(sales_price) as sales 
from table1
group by region,product_id 
order by region,sales;

with cte as ( -- a Common Table Expression A CTE is like a temporary table that exists only for the duration of the query. It helps to break down complex queries into more manageable parts.
select region, product_id,sum(sales_price) as sales 
from sql_data.table1
group by region,product_id) 
select * from (
select * 
, rank() over(partition by region order by sales desc) as rn 
from cte) A 
where rn<=5;

-- 3rd Find month over month grwoth comparison for 2022 nd 2023 sales eg : jan 2022 vs jan 2023 
select distinct year(order_date) from table1;

with cte as ( 
select  year(order_date) as order_year, month(order_date) as order_month, 
sum(sales_price) as sales from sql_data.table1
group by year (order_date) , month (order_date)
-- order by year (order_date) , month (order_date)
    ) 
select order_month 
, sum(case when order_year=2022 then sales else 0 end ) as sales_2022
, sum(case when order_year=2023 then sales else 0 end ) as sales_2023
from cte 
group by order_month 
order by order_month; 


-- 4th for each category which month had highest sales 

SELECT  category, DATE_FORMAT(order_date, '%Y%m') AS order_year_month
, sum(sales_price) as sales from table1
group by category, DATE_FORMAT(order_date, '%Y%m')
order by category, DATE_FORMAT(order_date, '%Y%m');
-- in output the 202201 so the 01 is january month snd so on 

with cte as (
SELECT  category, DATE_FORMAT(order_date, '%Y%m') AS order_year_month
, sum(sales_price) as sales from table1
group by category, DATE_FORMAT(order_date, '%Y%m')
-- order by category, DATE_FORMAT(order_date, '%Y%m');
) 
select * , 
rank() over(partition by category order by sales desc) as rn 
from cte ;
-- created seprate cte (common table expression) of rank 


with cte as (
SELECT  category, DATE_FORMAT(order_date, '%Y%m') AS order_year_month
, sum(sales_price) as sales from table1
group by category, DATE_FORMAT(order_date, '%Y%m')
-- order by category, DATE_FORMAT(order_date, '%Y%m');
) 
select * from (
select * , 
rank() over(partition by category order by sales desc) as rn 
from cte  
) a 
where rn=1;
-- final answer 

select count(distinct sub_category) from table1;


-- 5th which sub category had highest growth by profit in 2023 compare to 2022 
 
with cte as ( 
select  sub_category,year(order_date) as order_year,
sum(sales_price) as sales from sql_data.table1
group by sub_category,year(order_date) 
-- order by year (order_date) , month (order_date)
    ) 
, cte2 as (
select sub_category 
, sum(case when order_year=2022 then sales else 0 end ) as sales_2022
, sum(case when order_year=2023 then sales else 0 end ) as sales_2023
from cte 
group by sub_category 
)
select * 
, ((sales_2023-sales_2022)*100/sales_2022) as growth_percentage
from cte2  
order by (sales_2023-sales_2022*100/sales_2022) desc limit 1; 
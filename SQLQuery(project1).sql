select *from df_orders;


--qno 1 find top 10 highest revenue genarating products
select  product_id, sum(sales_price) as sales from df_orders group by product_id 
order by sales desc


select top 10 product_id, sum(sales_price) as sales from df_orders group by product_id 
order by sales desc

--qno 2 find top 5 selling product in each region 

select  region, product_id, sum(sales_price) as sales 
from df_orders 
group by region, product_id 
order by region ,sales desc

--no we finfd top 5 of every region with the help of cte 
with cte as (select  region, product_id, sum(sales_price) as sales 
from df_orders 
group by region, product_id )
select *from(
select *
,row_number() over(partition by region order by sales  desc) as rank --every region generate rank
from cte) A
where rank<=5
--qno 3 find month to month growth comparison for 2022 and 2023 sales eg jan 2022 vs jan 2023 
select  year(order_date) as order_year ,month(order_date) as order_month ,sum(sales_price) as sales 
from df_orders
group by  year(order_date),month(order_date)
order by  year(order_date),month(order_date)
 --now we wil move two year data into seprate colmn 
 with cte as (select  year(order_date) as order_year ,month(order_date) as order_month ,sum(sales_price) as sales 
from df_orders
group by  year(order_date),month(order_date)
--order by  year(order_date),month(order_date)
    )
select order_month,order_year,
case when order_year=2022  then sales else 0 end as sales_2022,
case when order_year=2023  then sales else 0 end as  sales_2023

from cte 
order by order_month
--group by order_month

--oper wali query sy colmn mae month wise sale agae hai ab hum iskou ik hi month mae convert karaingay tou aggre func used houga and then phir group by kam karega 
with cte as (select  year(order_date) as order_year ,month(order_date) as order_month ,sum(sales_price) as sales 
from df_orders
group by  year(order_date),month(order_date)
--order by  year(order_date),month(order_date)
    )
select order_month,
sum(case when order_year=2022  then sales else 0 end) as sales_2022,
sum(case when order_year=2023  then sales else 0 end )as  sales_2023

from cte 
group by order_month
order by order_month

--qno 4 for eachh category which month has highest sale 
--select category,sum(sales_price) from df_orders
--group by category this one show overall category sale not individual highest sale 
with cte as (select category, FORMAT(order_date,'yyyyMM') as yearmonth ,sum(sales_price) as sales --first will get data yearmonth combine format 
from df_orders 
group by category, FORMAT(order_date,'yyyyMM')
--order by category, FORMAT(order_date,'yyyyMM')
)
select * from(
select*, row_number() over(partition by category order by sales  desc) as rank 
from cte) a
where  rank<=1
-- qno 5which sub category had highest  growth by profit  in 2023 comape  to 2022

with cte as (select sub_category, year(order_date) as order_year  ,sum(sales_price) as sales 
from df_orders
group by sub_category, year(order_date)
--order by  year(order_date),month(order_date)
    )
	, cte2 as(
select sub_category,
sum(case when order_year=2022  then sales else 0 end) as sales_2022,
sum(case when order_year=2023  then sales else 0 end )as  sales_2023

from cte 
group by sub_category

)
select *,(sales_2023-sales_2022)*100/sales_2022
from cte2
order by (sales_2023-sales_2022)*100/sales_2022 desc 


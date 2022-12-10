
  --Data Cleansing Steps
  --Convert the week_date to a DATE format
  --Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
  --Add a month_number with the calendar month for each week_date value as the 3rd column
  --Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
  --Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
  --Add a new demographic column using the following mapping for the first letter in the segment values:
  --Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns  
  --Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record

 create table clean_weekly_sales
(
week_date date,
week_number int,
month_number int,
calender_year int,
region varchar(50),
platform varchar(50),
segment varchar(50),
age_band varchar(50),
demographic varchar(50),
transactions int,
sales int,
avg_transaction float
)

;with cte as
(
select 
convert(datetime, week_date, 5) as week_date,
datepart(week, convert(datetime, week_date, 5)) as  week_number,
datepart(month, convert(datetime, week_date, 5)) as  month_number,
datepart(year, convert(datetime, week_date, 5)) as  calender_year, 
region, platform, segment, 
case 
when right (segment,1) = '1' then 'Young Adults'
when right (segment,1) = '2' then 'Middle Aged'
when right (segment,1) in ('3','4') then 'Retirees'
else 'Unknown' end as age_band,
case
when left(segment, 1) = 'C' then 'Couples'
when left(segment, 1) = 'F' then 'Families'
else 'Unknown' end as demographic, 
 transactions,sales,
round(sales/transactions,2) as avg_transaction
from weekly_sales
)
insert into clean_weekly_sales
(
week_date, week_number, month_number, calender_year, region,
platform, segment, age_band, demographic, transactions, sales,avg_transaction
)
select * from clean_weekly_sales;

--2. Data Exploration
--1. What day of the week is used for each week_date value?
select distinct(datename(dw,week_date)) as day_used from clean_weekly_sales

--2. What range of week numbers are missing from the dataset?

with counter(current_value) as
(
select 1 union all select current_value + 1
from counter
where current_value < 53
)
select current_value from counter 
where current_value not in (select distinct(week_number) from clean_weekly_sales
)

--3. How many total transactions were there for each year in the dataset?
select  calender_year,sum(transactions) as total_transactions
from clean_weekly_sales
group by calender_year

--4. What is the total sales for each region for each month?
select  region, month_number, sum(cast (sales as bigint)) as total_sales
from clean_weekly_sales
group by region, month_number
order by 1 ,2 

--5. What is the total count of transactions for each platform
select  platform ,sum(transactions) as total_transactions
from clean_weekly_sales
group by platform

--6. What is the percentage of sales for Retail vs Shopify for each month?
with sales as(
select calender_year,month_number,
sum(case when platform='Retail' then cast(sales as bigint) end) as Retail,
sum(case when platform='Shopify' then cast(sales as bigint) end) as Shopify,
sum(cast(sales as bigint))as total_sale
from clean_weekly_sales
group by calender_year,month_number
)
select calender_year,month_number,round(cast((Retail*100.0/total_sale) as float),2) as retail_percent,
round(cast((Shopify*100.0/total_sale ) as float),2) as shopify_percent
from sales
order by 1,2

--7. What is the percentage of sales by demographic for each year in the dataset?
;with demographics_sales as(
select calender_year,
sum(case when demographic='Couples' then cast(sales as bigint) end) as couples_sales,
sum(case when demographic='Families' then cast(sales as bigint) end) as families_sales,
sum(case when demographic='Unknown' then cast(sales as bigint) end) as unknown_sales,
sum(cast(sales as bigint)) as total_sales
from clean_weekly_sales
group by calender_year
)
select calender_year, round(cast((couples_sales*100.0/ total_sales) as float),2) as couples_sales_percent,
round(cast((families_sales*100.0/ total_sales) as float),2) as families_sales_percent,
round(cast((unknown_sales*100.0/ total_sales) as float),2) as unknown_sales_percent
from demographics_sales
order by 1

--8. Which age_band and demographic values contribute the most to Retail sales?

select  age_band, demographic,sum(cast(sales as bigint)) as sales, 
round(cast(sum(cast(sales as bigint))*100.0 /(select sum(cast(sales as bigint)) from clean_weekly_sales where  platform='Retail' ) as float),2)
as percent_sales
from clean_weekly_sales
where platform='Retail'
group by  age_band, demographic
order by 3 desc

--9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
with tranx as(
select calender_year,sum(case when platform='Retail' then transactions end) as retail_tranx_sum,
sum(case when platform='Shopify' then transactions end) as shopify_tranx_sum,
sum(case when platform='Retail' then  cast(sales as bigint) end) as retail_sales_sum,
sum(case when platform='Shopify' then cast(sales as bigint) end) as shopify_sales_sum
from clean_weekly_sales
group by calender_year)
select calender_year,round(cast(avg(retail_sales_sum*100.0/retail_tranx_sum) as float),2) as retail_avg,
round(cast(avg(shopify_sales_sum*100.0/shopify_tranx_sum) as float),2) as shopify_avg
from tranx
group by calender_year
order by 1


--Before & After Analysis

--What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

 select distinct(dateadd(week, -4, '2020-06-15')) as Date_Before, 
(dateadd(week, 4, '2020-06-15')) as Date_After
from clean_weekly_sales;

with bef_aft as
(select *,
case when week_date>='2020-06-15' then 'after'
else 'before' end as before_after
from clean_weekly_sales
where calender_year='2020'
),
 sales_tab as(
select 
sum(case when  before_after='before' and week_date>='2020-05-18' then cast(sales as bigint)end) as before_sales,
sum(case when  before_after='after' and week_date<='2020-07-13' then cast(sales as bigint)end) as after_sales
from 
 bef_aft
 )
 select *,  (after_sales- before_sales) as sales_diff, round(cast((after_sales- before_sales)*100.0/before_sales as float),2) as percent_change
 from sales_tab


 --2. What about the entire 12 weeks before and after?
 
 select distinct(dateadd(week, -12, '2020-06-15')) as Date_Before, 
(dateadd(week, 12, '2020-06-15')) as Date_After
from clean_weekly_sales;

with bef_aft as
(select *,
case when week_date>='2020-06-15' then 'after'
else 'before' end as before_after
from clean_weekly_sales
where calender_year='2020'
),
 sales_tab as(
select 
sum(case when  before_after='before' and week_date>='2020-03-23' then cast(sales as bigint)end) as before_sales,
sum(case when  before_after='after' and week_date<='2020-09-07' then cast(sales as bigint)end) as after_sales
from 
 bef_aft
 )
 select *,  (after_sales- before_sales) as sales_diff, round(cast((after_sales- before_sales)*100.0/before_sales as float),2) as percent_change
 from sales_tab




 --3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

 select distinct week_number
from clean_weekly_sales
where week_date = '2020-06-15'  and calender_year = '2020';
  
with sales as
(
select calender_year, week_number, sum(cast(sales as bigint)) as Total_Sales
from clean_weekly_sales
where week_number between 21 and 28
group by calender_year, week_number
),
bef_aft as
(
select calender_year, 
sum(case when week_number between 21 and 24 then total_sales end) as before_sales, 
sum(case when week_number between 25 and 28 then total_sales end) as after_sales
from sales
group by calender_year
)
select calender_year, before_sales, after_sales, (after_sales- before_sales) as sales_diff,
((after_sales - before_sales) * 100.0 / before_sales) as percent_diff
from bef_aft;

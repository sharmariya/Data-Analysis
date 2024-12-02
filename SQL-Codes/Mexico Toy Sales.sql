--Access the database
Use [Mexico Toy Sales]

--viewing all the tables
SELECT * FROM Sales
SELECT * FROM Products
SELECT * FROM Stores
SELECT * FROM Inventory

--TOTAL QUANTITIES SOLD
SELECT SUM(UNITS) AS TOTAL_UNITS_SOLD FROM  Sales --Using sum function to get total units sold

--TOTAL SALES

--Converting data types of Product_Price and Product_Cost 

SELECT *,(CAST(PARSENAME(REPLACE(Product_Price,'$','.'),2) AS FLOAT) + CAST(PARSENAME(REPLACE(Product_Price,'$','.'),1) AS FLOAT)/100) AS SELLING_PRICE
, (CAST(PARSENAME(REPLACE(Product_Cost,'$','.'),2) AS FLOAT)+CAST(PARSENAME(REPLACE(Product_Cost,'$','.'),1) AS FLOAT)/100) AS COST_PRICE 

FROM PRODUCTS

/* EXPLAINATION
Product_Price and Product_Cost column had $ symbol due to which datatype was nvarchar and we need it to be float to perform calculations
Using PARSENAME function we split the columns , but since PARSENAME use '.' as delimeter we replace '$' with '.' first so for eg if our price was '$15.99' we made it '.15.99'
PARSENAME(REPLACE(Product_Price,'$','.'),2) will give us 15 (since it counts from last)
and (PARSENAME(REPLACE(Product_Price,'$','.'),1) will give us 99
using cast function we convert these values from nvarchar datatype to float data type
Now since we got 99 from (PARSENAME(REPLACE(Product_Price,'$','.'),1) but we actually we want 0.99 so we can add to 15 and get our 15.99 value without dollar and of float type so we divide the value by 100
and finally we add both values using '+' symbol and alias it as selling_price and cost_price 

*/

-- creating a new table for products which have above created new columns along with all other product columns

drop table if exists products_new --deleting the table products_new if it exist as we will be using this name for our new table

SELECT *,(CAST(PARSENAME(REPLACE(Product_Price,'$','.'),2) AS FLOAT) + CAST(PARSENAME(REPLACE(Product_Price,'$','.'),1) AS FLOAT)/100) AS SELLING_PRICE
, (CAST(PARSENAME(REPLACE(Product_Cost,'$','.'),2) AS FLOAT)+CAST(PARSENAME(REPLACE(Product_Cost,'$','.'),1) AS FLOAT)/100) AS COST_PRICE 
into products_new --table name for new table
FROM PRODUCTS

--checking the new_products table
SELECT * FROM products_new

--Calculating total sales
select round(sum(Units* SELLING_PRICE),2) as total_sales --we are multiplying total units with selling price to get total sales per sales id and summing the product using sum function to get net total sales and rounding it to 2 decimal place using round function
from products_new p join Sales s  --joining products_new and Sales table on 'Product_ID' column
on p.Product_ID=s.Product_ID 


--TOTAL PROFITS
select round(sum(Units* SELLING_PRICE)-sum(Units* COST_PRICE),2) as total_Pofit  --Using the above concept we get net total sales and net spend and do Sales-Cost to get profit
from products_new p join Sales s --joining products_new and Sales table on 'Product_ID' column
on p.Product_ID=s.Product_ID

--TOTAL PROFIT MARGIN
select round((sum(Units* SELLING_PRICE)-sum(Units* COST_PRICE))*100.0/sum(Units* SELLING_PRICE),2) as total_Pofit_percent  --Using the above concept we get net total sales and net spend and do Sales-Cost to get profit and divide itby total sales to get total_Profit_percent
from products_new p join Sales s  --joining products_new and Sales table on 'Product_ID' column
on p.Product_ID=s.Product_ID

-- SEASONAL TREND

;with counts as(
select 
datename(month,Date) as Months, product_name,count(s.Product_ID) as sold_count
from products_new p join sales s
on p.Product_ID =s.Product_ID
group by datename(month,Date),Product_Name

),
max_count as(
select Months, max(sold_count) as max_sold
from counts
group by Months
--having sold_count= max(sold_count)
)
select m.Months,Product_Name,max_sold
from counts c join max_count m
on c.Months=m.Months
where sold_count=max_sold
order by max_sold desc

/* CODE EXPLAINATION
we first create a CTE(Common table expression) named 'counts' in which we count the number of pieces of each product sold per month, "datename(month,Date)" gives the month name from the date
we then create another CTE named 'max_count' in which we use the above create cte i.e 'counts' to get the maximum pieces sold per month
in the last segment of our code we join both the CTEs on 'Month' column and find the products whose maximum peices were sold each month by giving the condition 'sold_count=max_sold'

*/


/* Analyzing the result we got from above query
1. Jan month has the maximum sales (most probably because of new year)
2. Oct month has the least sales 
3.  Out of 35 different products offered max sales are from Colorbuds, Barrel O' Slime 
*/

--Total Sales storewise 
select St.Store_ID, round(SUM(SELLING_PRICE*Units),0) as total_sales_per_store
from Stores St  join Sales S
on St.Store_ID=S.Store_ID 
join products_new p 
on s.Product_ID=p.Product_ID
group by St.Store_ID
order by round(SUM(SELLING_PRICE*Units),0) desc

/*CODE EXPLAINATION
We have joined Stores and Sales table on 'Store_ID' Column 
We use ' round(SUM(SELLING_PRICE*Units),0) ' to caculate total sales and rounding it to 0 decimals (integer)
and we are giving group by Store_ID to get the total sales per store_id
and to gving the records to be shown by total_sales_per_store descending order so that we can see which store got the most sales in first row
*/

---Total volume by store
;with vol as(
select St.Store_ID, SUM(Stock_On_Hand) as total_vol_per_store
from Stores St join Inventory I 
on St.Store_ID= I.Store_ID
group by St.Store_ID
)
select v.Store_ID, Store_Name,Store_City,total_vol_per_store
from vol v join Stores St
on v.Store_ID=St.Store_ID
order by total_vol_per_store desc

/*CODE EXPLAINATION
We first created a CTE named 'vol' in which we are joining Stores and Inventory column on 'Store_ID' column, in this CTE we are finding total volume present in each store
by using sum function on Stock_On_Hand and rouping then by Store_ID
then we join this cte with Stores table on on 'Store_ID' column to get more details about store like name and city and order by volume in descending order
*/


--City Store performance 
;with city_sales as
(
select   Store_City, ROUND(SUM((Units*SELLING_PRICE)),0) AS sales_per_city
from Stores St  join Sales S
on St.Store_ID=S.Store_ID 
join products_new p 
on s.Product_ID=p.Product_ID
group by  Store_City

)
select Store_City, round(sales_per_city*100.0/(select sum(sales_per_city) from city_sales),2) as sales_percentage
from city_sales
order by round(sales_per_city*100.0/(select sum(sales_per_city) from city_sales),2) desc

/* CODE EXPLAINATION
We create a CTE named 'city_sales' in which we join Sales and Stores table on 'Store_ID' column,
using 'ROUND(SUM(Units*SELLING_PRICE),0)' we calculate total sales rounded to 0 decimal places and group by store_city to get total sales for each store_city
then we are using this cte to calculate sales percentage contribution of each city 
"select sum(sales_per_city) from city_sales" - this will give us total sales of all cities
"round(sales_per_city*100.0/(select sum(sales_per_city) from city_sales),2)" - we are getting percentage contribution of each city to net sales and rounding it to 2 decimal places

*/

--Profitability of products
select  distinct Product_Name, round(( SELLING_PRICE-COST_PRICE)*100.0/SELLING_PRICE,2) as profit_prcnt
from  Sales S
join products_new p 
on s.Product_ID=p.Product_ID
order by round(( SELLING_PRICE-COST_PRICE)*100.0/SELLING_PRICE,2)  desc

/* CODE EXPLAINATION
We have joined products_new table with Sales table on 'Product_ID' column and using 'round(( SELLING_PRICE-COST_PRICE)*100.0/SELLING_PRICE,2)' we find profit percent
Profit percent formula= (Selling Price-Cost Price)*100/Selling Price
using round function we round the value to 2 decimal places
and order by profit percent in descending order 
*/

-- Store locationwise sales contribution 

select Store_Location, round(sum(units*(SELLING_PRICE)),2) as Total_Sales,  
round(sum(units*(SELLING_PRICE))*100.0/(select sum(units*(SELLING_PRICE)) from Sales s join products_new p on s.Product_ID=p.Product_ID),2) as sales_contribution
from Stores st
join Sales s
on s.Store_ID=st.Store_ID
join products_new p 
on s.Product_ID=p.Product_ID
group by Store_Location

/* CODE EXPLAINATION
Using "round(sum(units*(SELLING_PRICE)),2)" we are calculating te total sales by multiplying units with selliong price and rounding the value upto 2 decimal places.
"(SELECT SUM(units*(SELLING_PRICE)) FROM Sales s JOIN products_new p ON s.Product_ID=p.Product_ID) "- This subquery calculates the overall total sales across all store locations.
As to get the sales_contribution of each location we will be dividing the total sales of individual location by net total sales irrespective of location.
*/

-- Which product is most popular for each store location

;with units_sold_tab as(
select store_location, product_name, sum(units) as units_sold from Stores st
join Sales s
on s.Store_ID=st.Store_ID
join products_new p 
on s.Product_ID=p.Product_ID
group by store_location, product_name
--order by 1, 3 desc
),
max_min_tab as(
select distinct Store_Location, max(units_sold)over( partition by store_location) as max_units, min(units_sold)over( partition by store_location) as min_units
from units_sold_tab
),
re as (
Select distinct m.Store_Location, 
case when units_sold=max_units then Product_Name end as max_sold_prod,
case when units_sold=min_units then Product_Name end as min_sold_prod
from units_sold_tab  u join max_min_tab m
on u.Store_Location = m.Store_Location
),
max_tab as (
select * from re
where max_sold_prod is not null
) , 
min_tab as (
select * from re
where min_sold_prod is not null
)
select ma.Store_Location, ma.max_sold_prod,mi.min_sold_prod from max_tab ma join min_tab mi
on ma.Store_Location=mi.Store_Location

/* CODE EXPLANATION
First we crete a CTE named units_sold_tab in which we get the toal units sold for each product in different store locations by joining stores, sales and products_new table and using the sum function.
Then we create another CTE named max_min_tab in which we use window function to get max and min units sold of any product for each store  that is why we parttion by store_location.
Another CTE named re is created in which we join the above 2 ctes i.e. units_sold_tab and max_min_tab on store_location and using the case staement we get the name of products which are max and min sold for a location.
Since, it will give us a result with null values as well, we create 2 ctes named max_tab and min_tab to get the data where there is no null values of max_sold_prod and min_sold_prod respectively.
And finally we join max_tab and min_tab on store_location to get the compact result with store locations and max sold product and min sold product.
*/

-- Which store location is profitable for cities that have multiple stores in different locations

;with sl as 
(
select store_city, count(store_location) as store_loc_count
from Stores
group by store_city
) ,
sl_profit as (
select st.store_city, Store_Location, sum(units*(SELLING_PRICE-COST_PRICE)) as profit, rank()over(partition by store_city order by (sum(units*(SELLING_PRICE-COST_PRICE))) desc) as ranks
from Stores st
join Sales s
on s.Store_ID=st.Store_ID
join products_new p 
on s.Product_ID=p.Product_ID
where st.Store_City in (select store_city from sl where store_loc_count>1)
group by st.store_city,Store_Location
--order by 1,3 desc
)
select store_city, Store_Location, profit
from sl_profit where ranks=1


/* CODE EXPLANATION
First we create a CTE named sl in which we count the number of stores in diferent locations for each store_city, then we create another cte named sl_profit in which we calculate the profit
by using the formual unit*(selling price- cost price) and we sum this value and since we are grouping by store_city and store_location we will get the profit earned by ech location in each city.
Then we are using window function i.e rank function to get the highest profitable location in each city to be ranked 1, that is why we are parttioned by store_city and order by profit in descending order.
In the where condtion we are using the subquery to give condtion regarding ocation, so that only those store city gets selected that have more than store  in more than 1  location.
Finally we select store_city, Store_Location and profit from the above create CTE i.e. sl_profit and give condition that ranks=1 so that it shows location with the highest profitability.
*/
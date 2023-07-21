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
and finaaly we add both values using '+' symbol and alias it as selling_price and cost_price 

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
select round(sum(Units* SELLING_PRICE),2) as total_sales --we are multiplying total units with sellip price to get total sales per sales id and summing the product using sum function to get net total sales and rounding it to 2 decimal place by using round function
from products_new p join Sales s  --joining products_new and Sales table on 'Product_ID' column
on p.Product_ID=s.Product_ID 


--TOTAL PROFITS
select round(sum(Units* SELLING_PRICE)-sum(Units* COST_PRICE),2) as total_Pofit  --Using the above concept we get net total sales and net spend and do Sales-Cost to get profit
from products_new p join Sales s --joining products_new and Sales table on 'Product_ID' column
on p.Product_ID=s.Product_ID

--TOTAL PROFIT MARGIN
select round((sum(Units* SELLING_PRICE)-sum(Units* COST_PRICE))*100.0/sum(Units* SELLING_PRICE),2) as total_Pofit_percent  --Using the above concept we get net total sales and net spend and do Sales-Cost to get profit
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
we first create a CTE(Common table expression) named 'counts' in which we count the number of pieces of each product sold per month
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



--High Level Sales Analysis
--1. What was the total quantity sold for all products?
select sum(qty) as sold
from sales s join product_details p 
on s.prod_id=p.product_id


--2. What is the total generated revenue for all products before discounts?
select sum((qty*s.price)*(1-discount*0.01)) as Total_Revenues from sales s
join product_details pd on s.prod_id = pd.product_id


--3. What was the total discount amount for all products?
select round(sum((discount*(qty*s.price)/100.0)),2) as Total_Discount
from sales s join product_details pd
on s.prod_id=pd.product_id
 

--Transaction Analysis
--1. How many unique transactions were there?
select count(distinct txn_id) as unique_transactions
from sales

--2. What is the average unique products purchased in each transaction?
with prods as (
select distinct txn_id,count(prod_id)over(partition by txn_id) as prod
from sales)
select sum(prod)/count(txn_id) as avg_unique_prods
from prods

--3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
select   distinct
percentile_cont(0.25)within group(order by ((qty*price)*(1-discount*0.01)))over() as percentile_25,
percentile_cont(0.5)within group(order by ((qty*price)*(1-discount*0.01)))over() as percentile_50,
percentile_cont(0.75)within group(order by ((qty*price)*(1-discount*0.01)))over() as percentile_75
from sales

--4. What is the average discount value per transaction?
select round(avg(discount*qty*price/100.0),2) as avg_discount
from sales

--5. What is the percentage split of all transactions for members vs non-members?
select sum(case when member='t' then 1 else 0 end)*100.0/count(*) as member,
sum(case when member='f' then 1 else 0 end)*100.0/count(*) as non_member
from sales

--6. What is the average revenue for member transactions and non-member transactions?
select 
avg(case when member='t' then (qty*price)*(1-discount*0.01) end) as avg_revenue_member,
avg(case when member='f' then (qty*price)*(1-discount*0.01) end) as avg_revenue_non_member
from sales


--Product Analysis
--1. What are the top 3 products by total revenue before discount?
select distinct product_name,sum((qty*s.price)*(1-discount*0.01)) as total_revenue
from sales s join product_details pd
on s.prod_id=pd.product_id
group by product_name
order by 2 desc
offset 0 rows
fetch  next 3 rows only

--2. What is the total quantity, revenue and discount for each segment?
select segment_name, sum(qty)as total_qty,round(sum((qty*s.price)*(1-discount*0.01)),2) as total_revenue,
round(sum(discount*qty*s.price/100.0),2) as total_disc
from sales s join product_details pd
on s.prod_id=pd.product_id
group by segment_name

--3. What is the top selling product for each segment?
;with tab as
(select segment_name, product_name, sum(qty) as total_qty,
rank() over(partition by segment_name order by sum(qty) desc) as rk
from sales s
join product_details pd on s.prod_id = pd.product_id
group by segment_name,product_name
)
select segment_name,product_name,total_qty
from tab where rk=1

--4. What is the total quantity, revenue and discount for each category?
select category_name,sum(qty) as total_qty,
round(sum((qty*s.price)*(1-discount*0.01)),2) as total_revenue,
round(sum(discount*qty*s.price/100.0),2)as total_dis
from sales s
join product_details pd on s.prod_id = pd.product_id
group by category_name

--5. What is the top selling product for each category?
with cat_tab as(
select category_name, product_name,sum(qty) as total_qty,rank()over(partition by category_name order by sum(qty) desc) as rk
from sales s
join product_details pd on s.prod_id = pd.product_id
group by category_name,product_name
)
select category_name, product_name, total_qty
from cat_tab
where rk=1

--6. What is the percentage split of revenue by product for each segment?
;with prods as (
select segment_name,product_name,sum((qty*s.price)*(1-discount*0.01)) as rev_prod
from sales s
join product_details pd on s.prod_id = pd.product_id
group by segment_name,product_name
)
select segment_name,product_name,round(rev_prod*100.0/ (select sum((qty*price)*(1-discount*0.01)) from sales),2) as rev_prcnt
from prods 
order by 1,3

--7. What is the percentage split of revenue by segment for each category?
;with seg as 
(select category_name, segment_name,sum((qty*s.price)*(1-discount*0.01)) as rev_seg
from sales s
join product_details pd on s.prod_id = pd.product_id
group by category_name,segment_name
)
select category_name,segment_name, round(rev_seg*100.0/ (select sum((qty*price)*(1-discount*0.01)) from sales),2) as rev_seg_prcnt
from seg 
order by 1,3

--8. What is the percentage split of total revenue by category?
select category_name, round(sum((qty*s.price)*(1-discount*0.01)) *100.0/ (select sum((qty*price)*(1-discount*0.01)) from sales),2) as rev_cat_prcnt
from sales s
join product_details pd on s.prod_id = pd.product_id
group by category_name

--9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
select product_name, count(distinct txn_id)*100.0/(select count(distinct txn_id) from sales ) as penetration
from sales s
join product_details pd on s.prod_id = pd.product_id
where qty>=1
group by product_name
order by 2 desc

--10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
with base as (
select s.txn_id,s.prod_id,product_name
from sales s
join product_details pd on s.prod_id = pd.product_id
)
select top 1 a.product_name, b.product_name, c.product_name , count(*) as combination_count
from base a inner join base b
on a.txn_id = b.txn_id 
inner join base c 
on b.txn_id = c.txn_id 
where a.prod_id < b.prod_id and  b.prod_id < c.prod_id
group by a.product_name, b.product_name, c.product_name 
order by 4 desc

--Reporting Challenge
--Sales Table
select category_name,segment_name,s.prod_id,p.product_name,sum(qty) as sold,sum((qty*s.price)*(1-discount*0.01)) as Total_Revenues,
round(sum((discount*(qty*s.price)/100.0)),2) as Total_Discount,
round(sum((qty*s.price)*(1-discount*0.01)) *100.0/ (select sum((qty*price)*(1-discount*0.01)) from sales),2) as revenue_prcnt,
count(distinct txn_id)*100.0/(select count(distinct txn_id) from sales ) as penetration,
 sum(case when member='t' then 1 else 0 end)*100.0/count(*) as member_transaction,
sum(case when member='f' then 1 else 0 end)*100.0/count(*) as non_member_transaction,
avg(case when member='t' then (qty*s.price)*(1-discount*0.01) end) as avg_revenue_member,
avg(case when member='f' then (qty*s.price)*(1-discount*0.01) end) as avg_revenue_non_member
from sales s join product_details p 
on s.prod_id=p.product_id
where datename(month,start_txn_time)='January'
group by category_name,segment_name,s.prod_id,p.product_name
order by 1,2,6 desc



/*Bonus Challenge
Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.
*/
with cat as(
select id as  cat_id, level_text as category 
from product_hierarchy 
where level_name='Category'
),
seg as (
select parent_id as cat_id,id as  seg_id, level_text as Segment 
from product_hierarchy 
where level_name='Segment'
),
style as (
select parent_id as seg_id,id as  style_id, level_text as Style
from product_hierarchy 
where level_name='Style'),
prod_final as(
 select c.cat_id as category_id,category as category_name,s.seg_id as segment_id,segment as segment_name,style_id,style as style_name
 from cat c join seg s 
 on c.cat_id=s.cat_id
 join style st on s.seg_id=st.seg_id
 )
select product_id, price ,
concat(style_name,' ',segment_name,' - ',category_name) as product_name,
category_id,segment_id,style_id,category_name,segment_name,style_name from  prod_final pf join product_prices pp
on pf.style_id=pp.id

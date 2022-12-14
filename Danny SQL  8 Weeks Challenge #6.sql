 --Digital Analysis
 --1. How many users are there?
   select count(distinct user_id) as total_users from users

 --2. How many cookies does each user have on average?
   with cookies as
   (select user_id,count(distinct cookie_id) as total_cookies
	from users
	group by user_id
	)
	select round(cast(sum(total_cookies)/count(user_id) as float),2) as avg_cookies
	from cookies
--3. What is the unique number of visits by all users per month?
   select datepart(month,event_time) as Month_Number,datename(month,event_time) as Months, count(distinct visit_id) as Visits
   from events
   group by  datepart(month,event_time),datename(month,event_time)
   order by 1,2

--4. What is the number of events for each event type?
   select  distinct e.event_type,event_name,count(*) as counts
   from events e join event_identifier ei
   on e.event_type=ei.event_type
   group by e.event_type,event_name
   order by 1

--5. What is the percentage of visits which have a purchase event?
   select  round(count(distinct visit_id)*100.0/(select count(distinct visit_id) from events e ) ,2) as purchase_prcnt
   from events e join event_identifier ei
   on e.event_type=ei.event_type
   where event_name='Purchase'
  
--6. What is the percentage of visits which view the checkout page but do not have a purchase event?
   with abc as(
   select  distinct visit_id,
   sum(case when event_name!='Purchase'and page_id=12 then 1 else 0 end) as checkouts,
   sum(case when event_name='Purchase' then 1 else 0 end) as purchases
   from
   events e join event_identifier ei
   on e.event_type=ei.event_type
   group by visit_id
   )
   select sum(checkouts) as total_checkouts,sum(purchases) as total_purchases,
   100-round(sum(purchases)*100.0/sum(checkouts),2) as prcnt
   from abc


--7. What are the top 3 pages by number of views?  
    select top 3 page_name, count( visit_id) as visits
	from events e join
    page_hierarchy p on
	e.page_id=p.page_id
	group by page_name
	order by 2 desc

--8. What is the number of views and cart adds for each product category?
     select product_category,
	 sum(case when event_name='Page View' then 1 else 0 end) as views,
	 sum(case when event_name='Add to Cart' then 1 else 0 end) as cart_adds
	 from events e join event_identifier ei   
	 on e.event_type=ei.event_type join page_hierarchy p
	 on p.page_id=e.page_id
	 where product_category is not null
	 group by product_category

-- Product Funnel Analysis
/*Using a single SQL query - create a new output table which has the following details:
How many times was each product viewed?

How many times was each product added to cart?

How many times was each product added to a cart but not purchased (abandoned)?

How many times was each product purchased? */

drop table if exists product_tab
create table product_tab
(
page_name varchar(50),
page_views int,
cart_adds int,
cart_add_not_purchase int,
cart_add_purchase int
);


with tab1 as(
 select e.visit_id,page_name, 
 sum( case when event_name='Page View' then 1 else 0 end)as view_count,
 sum( case when event_name='Add to Cart' then 1 else 0 end)as cart_adds
 from events e join  page_hierarchy p
 on e.page_id=p.page_id 
 join event_identifier ei   
 on e.event_type=ei.event_type
 where product_id is not null
 group by e.visit_id,page_name
),

--creating purcchaseid because for purchased products the product_id is null
 tab2 as(
select distinct(visit_id) as Purchase_id
from events e join event_identifier ei   
 on e.event_type=ei.event_type where event_name = 'Purchase'),

tab3 as(
select *, 
(case when purchase_id is not null then 1 else 0 end) as purchase
from tab1 left join tab2
on visit_id = purchase_id),

tab4 as(
select page_name, sum(view_count) as Page_Views, sum(cart_adds) as Cart_Adds, 
sum(case when cart_adds = 1 and purchase = 0 then 1 else 0
	end) as Cart_Add_Not_Purchase,
sum(case when cart_adds= 1 and purchase = 1 then 1 else 0
	end) as Cart_Add_Purchase
from tab3
group by page_name)


insert into product_tab
(page_name ,page_views ,cart_adds ,cart_add_not_purchase ,cart_add_purchase )
select page_name, page_views, cart_adds, cart_add_not_purchase, cart_add_purchase
from tab4

select * from product_tab


--Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.
drop table if exists product_category_tab
create table product_category_tab
(product_category varchar(50),
page_views int,
cart_adds int ,
cart_add_not_purchase int,
cart_add_purchase int )
;
with tab1 as(
 select e.visit_id,product_category, page_name, 
 sum( case when event_name='Page View' then 1 else 0 end)as view_count,
 sum( case when event_name='Add to Cart' then 1 else 0 end)as cart_adds
  --sum( case when event_name='Purchase' then 1 else 0 end)as purchases
 from events e join  page_hierarchy p
 on e.page_id=p.page_id 
 join event_identifier ei   
 on e.event_type=ei.event_type
 where product_id is not null
 group by e.visit_id,product_category,page_name
),

--creating purcchaseid because for purchased products the product_id is null
 tab2 as(
select distinct(visit_id) as Purchase_id
from events e join event_identifier ei   
 on e.event_type=ei.event_type where event_name = 'Purchase'),

tab3 as(
select *, 
(case when purchase_id is not null then 1 else 0 end) as purchase
from tab1 left join tab2
on visit_id = purchase_id),

tab4 as(
select product_category, sum(view_count) as Page_Views, sum(cart_adds) as Cart_Adds, 
sum(case when cart_adds = 1 and purchase = 0 then 1 else 0
	end) as Cart_Add_Not_Purchase,
sum(case when cart_adds= 1 and purchase = 1 then 1 else 0
	end) as Cart_Add_Purchase
from tab3
group by  product_category)


insert into product_category_tab
(product_category,page_views ,cart_adds ,cart_add_not_purchase ,cart_add_purchase )
select product_category, page_views, cart_adds, cart_add_not_purchase, cart_add_purchase
from tab4
select * from product_category_tab

---Use your 2 new output tables - answer the following questions:

--Which product had the most views, cart adds and purchases?
 
  select top 1 page_name as most_viewed from product_tab order by page_views desc

  select top 1 page_name as most_cart_adds from product_tab order by cart_adds desc

  select top 1 page_name as most_purchased from product_tab order by  cart_add_purchase desc

--Which product was most likely to be abandoned?
  select top 1 page_name as most_purchased from product_tab order by  cart_add_not_purchase desc

--Which product had the highest view to purchase percentage?
  select page_name as product,round(cart_add_purchase*100.0/page_views,2 ) as view_purchase_prcnt
  from product_tab
  order by 2 desc
 
--What is the average conversion rate from view to cart add?
  select round(avg(cart_adds*100.0/page_views),2) as avg_rate_viewTocart
  from product_tab

--What is the average conversion rate from cart add to purchase?
  select round(avg(cart_add_purchase*100.0/cart_adds),2) as avg_rate_cartTopurchase
  from product_tab

--Generate a table that has 1 single row for every unique visit_id record and has the following columns:
/*user_id
visit_id
visit_start_time: the earliest event_time for each visit
page_views: count of page views for each visit
cart_adds: count of product cart add events for each visit
purchase: 1/0 flag if a purchase event exists for each visit
campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
impression: count of ad impressions for each visit
click: count of ad clicks for each visit
(Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)
*/

create table campaign_analysis
(
user_id int,
visit_id varchar(20),
visit_start_time datetime2(3),
page_views int,
cart_adds int,
purchase int,
impressions int, 
click int, 
Campaign varchar(200),
cart_products varchar(200)
);
with cte as(
select distinct visit_id, user_id,min(event_time) as visit_start_time,count(e.page_id) as page_views, sum(case when event_name='Add to Cart' then 1 else 0 end) as cart_adds,
sum(case when event_name='Purchase' then 1 else 0 end) as purchase,
sum(case when event_name='Ad Impression' then 1 else 0 end) as impressions,
sum(case when event_name='Ad Click' then 1 else 0 end) as click,
case
when min(event_time) > '2020-01-01 00:00:00' and min(event_time) < '2020-01-14 00:00:00'
		then 'BOGOF - Fishing For Compliments'
when min(event_time) > '2020-01-15 00:00:00' and min(event_time) < '2020-01-28 00:00:00'
		then '25% Off - Living The Lux Life'
when min(event_time) > '2020-02-01 00:00:00' and min(event_time) < '2020-03-31 00:00:00'
		then 'Half Off - Treat Your Shellf(ish)' 
else NULL
end as Campaign,
string_agg(case when product_id IS NOT NULL AND event_name='Add to Cart'
			then page_name ELSE NULL END, ', ') AS cart_products
from events e join event_identifier ei
on e.event_type=ei.event_type  join users u
on u.cookie_id=e.cookie_id 
join page_hierarchy ph on e.page_id = ph.page_id
group by visit_id, user_id
)

insert into campaign_analysis 
(user_id, visit_id, visit_start_time, page_views, cart_adds, purchase, impressions, click, Campaign, cart_products)
select user_id,visit_id, visit_start_time, page_views, cart_adds, purchase, impressions, click, Campaign, cart_products
from cte;
select * from campaign_analysis
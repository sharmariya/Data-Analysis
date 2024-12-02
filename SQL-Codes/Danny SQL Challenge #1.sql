
CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);
INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);
INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),('2', 'curry', '15'),('3', 'ramen', '12');
  CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);
INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

  
-- 1. What is the total amount each customer spent at the restaurant?

select s.customer_id, sum(m.price) as total_spend
from sales s join menu m
on  s.product_id= m.product_id
group by s.customer_id

  

-- 2. How many days has each customer visited the restaurant?

select customer_id, count(distinct order_date) as number_of_days
from sales
group by customer_id

-- 3. What was the first item from the menu purchased by each customer?
select * from sales
select * from menu
select * from members


select distinct  customer_id, product_name from
(
select customer_id, product_name, order_date,rank()over(partition by customer_id order by order_date) as rank
from sales s join menu m
on s.product_id=m.product_id
)a
where rank=1

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select top 1 product_name, count(customer_id) as count
from sales s join menu m
on s.product_id=m.product_id
group by product_name
order by 2 desc

-- 5. Which item was the most popular for each customer?
with abc as
(select customer_id, product_name,count(product_name) as counts,
rank()over(partition by customer_id order by count(product_name)  desc) as rk
from sales s join menu m
on s.product_id=m.product_id
group by customer_id, product_name)
select customer_id, product_name
from abc
where 
rk=1

-- 6. Which item was purchased first by the customer after they became a member?
select customer_id, product_name
from
(select s.customer_id, product_name,datediff(day,join_date,order_date) as diff, 
rank()over(partition by s.customer_id order by datediff(day,join_date,order_date) 
) as rn
from sales s join menu m
on s.product_id=m.product_id
join members me on s.customer_id=me.customer_id
where order_date>=join_date) ab
where rn=1


-- 7. Which item was purchased just before the customer became a member?

select customer_id, product_name
from
(select s.customer_id, product_name,datediff(day,order_date,join_date) as diff, 
rank()over(partition by s.customer_id order by datediff(day,order_date,join_date) 
) as rn
from sales s join menu m
on s.product_id=m.product_id
join members me on s.customer_id=me.customer_id
where order_date<join_date) ab
where rn=1

-- 8. What is the total items and amount spent for each member before they became a member?

select s.customer_id, count(product_name) number_of_prods,sum(price) as total_spend
from sales s join menu m
on s.product_id=m.product_id
join members me on s.customer_id=me.customer_id
where order_date<join_date
group by s.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

with cte as
( select *, case
when product_name='sushi' then price*20
else price*10 end as point
from menu
)
select customer_id, sum(point) as total_points
from sales s join cte c
on s.product_id=c.product_id
group by customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
select afte.customer_id, (before_points+points_after) as total_points
from
(select customer_id,sum(points_bef) as before_points from
(select s.customer_id,product_name,price,
case when product_name='sushi' then price*20 else price*10 end as points_bef
from 
members m join sales s
on m.customer_id=s.customer_id
join menu me on
me.product_id= s.product_id
where order_date<join_date)bef
group by customer_id
) befor
join 
(select s.customer_id,sum(price*20) as points_after
from members m join sales s
on m.customer_id=s.customer_id
join menu me on
me.product_id= s.product_id
where order_date>=join_date
and order_date<'2021-02-01'
group by s.customer_id) afte
on 
befor.customer_id=afte.customer_id 


--Recreate the table 
select s.customer_id,order_date,product_name,price
,case when s.customer_id in(select customer_id from members) and order_date>=join_date
then 'Y' else 'N' end as member
from sales s join menu m
on s.product_id=m.product_id
left join members me on s.customer_id=me.customer_id
order by customer_id,order_date, price desc

--Rank All The Things

with xy as
(select s.customer_id,order_date,product_name,price
,case when s.customer_id in(select customer_id from members) and order_date>=join_date
then 'Y' else 'N' end as member
from sales s join menu m
on s.product_id=m.product_id
left join members me on s.customer_id=me.customer_id
) 
select
*, 
case
when member='Y' then rank()over(partition by customer_id,member order by order_date) 
else null end as ranking
from xy
order by customer_id,order_date, price desc


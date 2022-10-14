use Swiggy_caseStudy

--Find customers who have never ordered
select *  from users$
select *  from orders$

select user_id
from users$ 
where user_id not in 
(
select user_id from orders$   )

--Average Price/dish
select * from food$
select * from menu$

select f.f_name, avg(m.price) as Avg_Price
from food$ f join menu$ m 
on f.f_id=m.f_id 
group by f.f_name

--Find the top restaurant in terms of the number of orders for a given month
select * from restaurants$
select * from orders$

select top 1 r.r_name as name ,count(o.order_id) as number_of_orders
from orders$ o join restaurants$ r 
on o.r_id=r.r_id
where month(date)=7
group by r.r_name
order by 2 desc

--restaurants with monthly sales greater than x for

select r.r_name as name ,sum(o.amount) as amount, month(o.date) as order_month
from orders$ o join restaurants$ r 
on o.r_id=r.r_id
group by r.r_name, month(o.date)
having sum(o.amount)>700
order by 2 desc
 
 --Show all orders with order details for a particular customer in a particular date range


 select o.order_id, r.r_name,f.f_name
 from 
 orders$ o
 join restaurants$ r on o.r_id= r.r_id
 join menu$ m on r.r_id= m.r_id
 join food$ f on m.f_id=f.f_id
 where o.user_id=(select user_id from users$ where name like 'Ankit')
 and (o.date > '2022-06-10' and o.date< '2020-07-10')

 --Find restaurants with max repeated customers 
 
select  top 1 r_id, count(*) as Loyal_Customers
  from (
  select r_id, user_id, count(*) as Visits
  from orders$
  group by r_id, user_id
  having count(*) >1
 
) a
  group by r_id
  order by 2 desc 
  
  --Month over month revenue growth of swiggy
  select months, revenue, lag(revenue)over(order by months) as previous_revenue,(revenue-(lag(revenue)over(order by months)))/revenue as growth_rate
  from
  (select sum(amount) as revenue, month(date) as months
  from orders$
  group by month(date)
  ) a
   where months is not null

 --Customer - favorite food
    select * from users$
	 select * from food$
	  select * from orders$
	  select * from order_details$

;with abc as
(
select count(f.f_id) as food_count, o.user_id, f.f_id
from order_details$ od join food$ f 
on od.f_id=f.f_id join orders$ o on od.order_id=o.order_id
group by o.user_id, f.f_id
--order by user_id,1 desc
) 
select u.name , f.f_name, t1.food_count from abc t1
join users$ u on u.user_id= t1.user_id
join food$ f on f.f_id=t1.f_id
where 
t1.food_count=(select max(food_count) from abc t2 where t2.user_id=t1.user_id)


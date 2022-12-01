
  --How many customers has Foodie-Fi ever had?
  select count( distinct customer_id) as total_customers from
  subscriptions 

  --What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
  
  select count(customer_id) as total_subscriptions , datepart(month,start_date) as month from subscriptions
  where plan_id=0
  group by datepart(month,start_date)
  order by datepart(month,start_date)

  --What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
  select p.plan_id, p.plan_name,count(*) as subscriptions
  from plans p   join subscriptions s
  on p.plan_id=s.plan_id
  where start_date > '2020-12-31'
  group by p.plan_id,p.plan_name

  --What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
  
  select count(distinct customer_id) as customers, 
  round(cast(count(distinct customer_id)*100 as float)/(select count(distinct customer_id) from subscriptions) ,1) 
  as percentage
  from 
  plans p join subscriptions s 
  on p.plan_id= s.plan_id
 where plan_name='churn'

 --How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
 select count(customer_id) as churns, 
 round(cast(count(customer_id)*100 as float)/(select count(distinct customer_id)  from subscriptions),0) 
 as churn_percentage
 from
 (select  customer_id,plan_name,lag(plan_name)over(partition by customer_id order by start_date,plan_name) 
 as prev_plan,start_date 
 from plans p join subscriptions s
 on p.plan_id=s.plan_id
 --order by customer_id
 )a
 where plan_name='churn' and prev_plan='trial'

 --What is the number and percentage of customer plans after their initial free trial?

 with cte as 
 (select  customer_id,plan_name,lag(plan_name)over(partition by customer_id order by start_date,plan_name) 
 as prev_plan,start_date 
 from plans p join subscriptions s
 on p.plan_id=s.plan_id
 
 ) 
  select plan_name,count(customer_id) as customers, 
  cast (count(customer_id)*100 as float)/(select count(distinct customer_id) from subscriptions) as percentage
 from cte
 where prev_plan='trial'
group by plan_name


--What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

 ;with abc as 
( select customer_id,p.plan_id,plan_name, start_date,
rank()over(partition by customer_id order by start_date desc) ranks
 from plans p left join subscriptions s
 on p.plan_id=s.plan_id
 where start_date<='2020-12-31')
 select plan_id,plan_name,count(customer_id) as subscribers, 
 cast(count(customer_id)*100 as float)/(select count(distinct customer_id) from subscriptions)
 as percentage
 from abc 
 where ranks=1
  group by plan_id,plan_name
  order by 1

  --How many customers have upgraded to an annual plan in 2020?

   ;with abc as 
( select customer_id,p.plan_id,plan_name, start_date,
rank()over(partition by customer_id order by start_date desc) ranks
 from plans p left join subscriptions s
 on p.plan_id=s.plan_id
 where start_date<='2020-12-31')
 select count(customer_id) as annual_new_subscribers
 from abc 
 where ranks=1 and plan_name='pro annual'

 --How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
 
WITH abc AS 
  (
  SELECT 
    customer_id, 
    start_date AS fst_day
  FROM subscriptions
  WHERE plan_id = 0
),
def AS
  (SELECT 
    customer_id, 
    start_date AS subscribe_day
  FROM subscriptions
  WHERE plan_id = 3
)
SELECT 
  abs(ROUND(AVG(DATEDIFF(day,fst_day,subscribe_day)),0)) AS avg_days_to_upgrade
FROM abc
JOIN def
  ON abc.customer_id = def.customer_id;


  --Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

WITH strt AS 
  (
  SELECT 
    customer_id, start_date AS fst_day FROM subscriptions WHERE plan_id = 0
),
annual AS
  (SELECT 
    customer_id, start_date AS subscribe_day FROM subscriptions WHERE plan_id = 3
),
tb as (
SELECT 
DATEDIFF(day,fst_day,subscribe_day) AS days_to_upgrade,a.customer_id
FROM strt s
JOIN annual a ON a.customer_id = s.customer_id
 ),
 periods_group as
  (select *,
  case when days_to_upgrade <=30 then '0-30'
  when days_to_upgrade>30 and days_to_upgrade <=60 then '30-60'
   when days_to_upgrade>60 and days_to_upgrade <=90 then '60-90'
    when days_to_upgrade>90 and days_to_upgrade <=120 then '90-120'
	 when days_to_upgrade>120 and days_to_upgrade <=150 then '120-150'
	  when days_to_upgrade>150 and days_to_upgrade <=180 then '150-180'
	   when days_to_upgrade>180 and days_to_upgrade <=210 then '180-210'
	    when days_to_upgrade>210 and days_to_upgrade <=240 then '210-240'
		 when days_to_upgrade>240 and days_to_upgrade <=2700 then '240-270'
		  when days_to_upgrade>270 and days_to_upgrade <=300 then '270-300'
		   when days_to_upgrade>300 and days_to_upgrade <=330 then '300-330'
		    when days_to_upgrade>330 and days_to_upgrade <=365 then '330-365' 
			else '>1 yr'end as periods
			 from tb)
  select  periods,count(customer_id) as customers from periods_group
  group by periods


  --How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
  ;with plans_tab as
  (select customer_id,plan_name,lag(plan_name)over(partition by customer_id order by start_date) 
  as prev_plan,start_date, DATENAME(year,start_date) as years
  from subscriptions s
  join plans p on p.plan_id=s.plan_id)
  select count(customer_id) as downgraded_plan_subscriber
  from plans_tab
  where plan_name='basic monthly' and prev_plan=  'pro monthly' and years='2020'
 

 --challenge payment questions
 ;with cte as
 (select customer_id, p.plan_id,plan_name,
 lag(plan_name)over(partition by customer_id order by  start_date) as prev_plan,
 start_date as payment_date,price as amounts,
 lag(price)over(partition by customer_id order by  start_date) as prev_pay
,rank()over(partition by customer_id order by start_date) as payment_order
 from subscriptions s join plans p
 on s.plan_id=p.plan_id
 where p.plan_id!=0 and p.plan_id!=4)

 select customer_id,plan_id,plan_name,payment_date  ,
 case when prev_plan='basic monthly' and (plan_name='pro monthly' or plan_name='pro annual') 
 then amounts-prev_pay 
 else amounts end as amount, payment_order
 from cte 

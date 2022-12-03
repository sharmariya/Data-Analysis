--A. Customer Nodes Exploration

--1. How many unique nodes are there on the Data Bank system?
  select count(distinct node_id) unique_nodes
  from customer_nodes

--2. What is the number of nodes per region?
select r.region_id,region_name,count(node_id)  number_of_nodes
  from customer_nodes c join regions r
  on c.region_id=r.region_id
  group by r.region_id,region_name
  order by 1 
 
--3. How many customers are allocated to each region?
select r.region_id,region_name,count( distinct customer_id)  number_of_customers
  from customer_nodes c join regions r
  on c.region_id=r.region_id
  group by r.region_id,region_name
  order by 1

--4. How many days on average are customers reallocated to a different node?
select 
	AVG(DATEDIFF(D, start_date, end_date)) avg_days
from customer_nodes
where end_date != '99991231';



--5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
;with reallocation as
(  
select r.region_id,
	region_name,
DATEDIFF(D, start_date, end_date) day_diff
from customer_nodes c join regions r
on r.region_id=c.region_id
where end_date != '99991231')

select distinct
	region_id,
	region_name,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY day_diff)
		OVER (PARTITION BY region_name) AS median,
	PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY day_diff)
		OVER (PARTITION BY region_name) AS percentile_80,
	PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY day_diff)
		OVER (PARTITION BY region_name) AS percentile_90
from reallocation 
order by region_id;


--B. Customer Transactions

--1. What is the unique count and total amount for each transaction type?
select txn_type,count(*)  count, sum(txn_amount) total_amount
from customer_transactions
group by txn_type
order by 2,3

--2. What is the average total historical deposit counts and amounts for all customers?
with counts_tab as
(select customer_id, count(txn_type) as TotalCount, 
sum(txn_amount) as TotalAmount
from customer_transactions
where txn_type = 'deposit'
group by customer_id
)

select avg(TotalCount) as avg_count, avg(TotalAmount) as avg_amount
from counts_tab

--3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

;with abc as
(
select customer_id, datepart(month,txn_date) as months,
sum(case when txn_type='deposit' then 1 else 0 end) as deposit,
sum(case when txn_type='withdrawl' then 1 else 0 end) as withdrawl,
sum(case when txn_type='purchase' then 1 else 0 end) as purchase
from customer_transactions
group by  datepart(month,txn_date),customer_id
)
select months,count(customer_id) as customers
from abc
where deposit>1 and (withdrawl=1 or purchase=1)
group by months
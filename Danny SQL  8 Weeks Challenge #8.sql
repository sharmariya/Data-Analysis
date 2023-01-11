--Data Exploration and Cleansing
--1. Update the interest_metrics table by modifying the month_year column to be a date data type with the start of the month

alter table  interest_metrics
drop column month_year

alter table  interest_metrics
add month_year date

update  interest_metrics
set month_year=  cast(_year + '-' + _month + '-01' as date)

 select * from interest_metrics

 --2. What is count of records in the interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
 select month_year, count(*) as records
 from interest_metrics
 group by month_year
 order by 1

 --3. What do you think we should do with these null values in the interest_metrics
 --we can delete records with null values

delete from interest_metrics 
where month_year is null

--4. How many interest_id values exist in the interest_metrics table but not in the interest_map table? What about the other way around?
select count(distinct interest_id) Ids_not_in_maps  from interest_metrics 
where interest_id  not in (select interest_id  from interest_map)

select count(id) as Ids_not_in_metrics from interest_map
where id  not in (select interest_id  from interest_metrics )

--5. Summarise the id values in the interest_map by its total record count in this table
select id,interest_name, count(*) as count
from interest_map m join interest_metrics me
on m.id=me.interest_id
group by id,interest_name
order by 3 desc

--6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from interest_metrics and all columns from interest_map except from the id column
--Inner join
select _month, _year, interest_id, composition, index_value, ranking, percentile_ranking,
month_year, interest_name, interest_summary, created_at, last_modified
from interest_metrics me join interest_map m
on me.interest_id = m.id
where interest_id = 21246

--7. Are there any records in your joined table where the month_year value is before the created_at value from the interest_map table? Do you think these values are valid and why?
select *
from interest_metrics me join interest_map m
on me.interest_id = m.id
where month_year < created_at and interest_id  is not null


--Yes these records are valid because both the dates have same month and we set the date for the month_year column to be the first day of the month

--Interest Analysis
--1. Which interests have been present in all month_year dates in our dataset?

--checking the number of dates
select count(distinct month_year) as count
from interest_metrics 

--interests present  in all month_year dates
select distinct interest_id
from interest_metrics 
group by interest_id
having count(distinct month_year)=14

--2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
with months_count as(
select distinct interest_id, count(month_year) as month_count
from interest_metrics 
group by interest_id
--order by 2 desc
)
, interests_count as
(
select month_count, count(interest_id) as interest_count
from months_count
group by month_count
)
, cumulative_percentage as
(
select *, round(sum(interest_count)over(order by month_count desc) *100.0/(select sum(interest_count) from interests_count),2) as cumulative_percent
from interests_count
group by month_count, interest_count
)
select *
from cumulative_percentage
where cumulative_percent >90

--3. If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?

--getting interest ids which have month count less than 6
with month_counts as
(
select interest_id, count(distinct month_year) as month_count
from 
interest_metrics
group by interest_id
having count(distinct month_year) <6 
)

--getting the number of times the above interest ids are present in the interest_metrics table
select count(interest_id) as interest_record_to_remove
from interest_metrics
where interest_id in (select interest_id from month_counts)


/*4. Does this decision make sense to remove these data points from a business perspective?
Use an example where there are all 14 months present to a removed interest example for your arguments 
- think about what it means to have less months present from a segment perspective.
*/

--getting interest ids which have month count less than 6
with month_counts as
(
select interest_id, count(distinct month_year) as month_count
from 
interest_metrics
group by interest_id
having count(distinct month_year) <6 
)
select removed.month_year,  present_interest,removed_interest, round(removed_interest*100.0/(removed_interest+present_interest),2) as removed_prcnt
from
(
select month_year, count(*) as removed_interest
from interest_metrics
where interest_id in (select interest_id from month_counts) 
group by month_year
) removed
join 

(
select month_year, count(*) as present_interest
from interest_metrics
where interest_id not in (select interest_id from month_counts) 
group by month_year
) present
on removed.month_year= present.month_year
order by removed.month_year

--As removed percentage is not significant, we can removed the data points

--5. After removing these interests - how many unique interests are there for each month?
with month_counts as
(
select interest_id, count(distinct month_year) as month_count
from 
interest_metrics
group by interest_id
having count(distinct month_year) <6 
)
select month_year, count(distinct interest_id) as unique_present_interest
from interest_metrics
where interest_id not in (select interest_id from month_counts) 
group by month_year
order by 1

--SEGMENT ANALYSIS
/* 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10
interests which have the largest composition values in any month_year?
Only use the maximum composition value for each interest but you must keep the corresponding month_year
*/

--creating filtered table
with cte as
(
select interest_id, count(distinct month_year) as month_count
from 
interest_metrics
group by interest_id
having count(distinct month_year) >=6 
)
select * into filtered_table
from interest_metrics
where interest_id in (select interest_id from cte)

select * from filtered_table

--For top 10 
select top 10  
month_year,interest_id,interest_name, max(composition) as max_composition
from filtered_table f join interest_map ma on
 f.interest_id=ma.id
group by month_year,interest_id,interest_name
order by 4 desc

--for bottom 10

select top 10 month_year,interest_id,interest_name,max(composition) as max_composition
from filtered_table f join interest_map ma on
 f.interest_id=ma.id
group by month_year, interest_id,interest_name
order by 4 asc


--2. Which 5 interests had the lowest average ranking value?

select  top 5
interest_id, interest_name,avg(ranking) as avg_rank
from filtered_table f
join interest_map ma on
 f.interest_id=ma.id
 group by interest_id,interest_name
 order by 3 asc

 --3. Which 5 interests had the largest standard deviation in their percentile_ranking value?

 select top 5
interest_id, interest_name,round(stdev(percentile_ranking),2) as stdev_ranking
from filtered_table f
join interest_map ma on
 f.interest_id=ma.id
 group by interest_id,interest_name
 order by 3 desc

 /*4. For the 5 interests found in the previous question - 
 what was minimum and maximum percentile_ranking values for each interest
 and its corresponding year_month value? Can you describe what is happening for these 5 interests? */

 
--getting the 5 above interests in a cte table
with interests as
(
 select top 5
interest_id, interest_name,round(stdev(percentile_ranking),2) as stdev_ranking
from filtered_table f
join interest_map ma on
 f.interest_id=ma.id
 group by interest_id,interest_name
 order by 3 desc
 ),
 percentiles as(
 select i.interest_id, interest_name, max(percentile_ranking) as max_percentile,min(percentile_ranking) as min_percentile
 from  filtered_table f join interests i
 on i.interest_id=f.interest_id
 group by i.interest_id, interest_name
 ), 
 max_per as
 (
  select p.interest_id, interest_name,month_year as max_year, max_percentile
 from  filtered_table f join  percentiles p
 on p.interest_id=f.interest_id
 where  max_percentile =percentile_ranking
 ),
 min_per as
  ( select p.interest_id, interest_name,month_year as min_year, min_percentile
 from  filtered_table f join  percentiles p
 on p.interest_id=f.interest_id
 where  min_percentile =percentile_ranking
 )

 select mi.interest_id,mi.interest_name,min_year,min_percentile, max_year, max_percentile
 from min_per mi join max_per ma on mi.interest_id= ma.interest_id

 --Index Analysis
 /* Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places. */
 --creating table with avg composition
 select * from interest_metrics
 with cte as(
 select*, round(composition/index_value,2) as avg_composition
 from interest_metrics 

 )
 select * into index_table from cte

 --1. What is the top 10 interests by the average composition for each month?
 with ranks_tab as(
 select  i.interest_id,interest_name, month_year,avg_composition, rank()over(partition by month_year order by avg_composition desc) ranks
 from index_table i join interest_map m
 on i.interest_id=m.id
 )
 select * from ranks_tab where ranks<=10

 --2. For all of these top 10 interests - which interest appears the most often?
  with ranks_tab as(
 select  i.interest_id,interest_name, month_year,avg_composition, rank()over(partition by month_year order by avg_composition desc) ranks
 from index_table i join interest_map m
 on i.interest_id=m.id
 )
 select distinct interest_id, interest_name,count(*)over(partition by interest_name) as counts
 from ranks_tab where ranks<=10
 order by 3 desc

 --3. What is the average of the average composition for the top 10 interests for each month?
   with ranks_tab as(
 select  i.interest_id,interest_name, month_year,avg_composition, rank()over(partition by month_year order by avg_composition desc) ranks
 from index_table i join interest_map m
 on i.interest_id=m.id
 )
 select month_year,round(avg(avg_composition),2) as avg_monthly_comp 
 from ranks_tab where ranks<=10 
 group by month_year

 --4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.


 --first find the max avg_composition for each month
 with month_comp as(
 select  month_year,round(max(avg_composition),2) as max_avg_comp
 from index_table

 group by month_year
 ), 
 rolling_avg as (
 --getting the interests which gave the max avg_comp and rolling avg for 3 months
 select i.month_year,interest_id,interest_name,max_avg_comp as max_index_composition, 
 round(avg(max_avg_comp)over(order by i.month_year rows between 2 preceding and current row),2) as '3_month_moving_avg'
 from index_table i join month_comp m on i.month_year=m.month_year
  join interest_map ma
 on i.interest_id=ma.id
 where avg_composition =max_avg_comp 
 --order by 1 asc
 ),
 month_1_lag as(
 select *, concat(lag(interest_name)over( order by month_year), ' : ',lag(max_index_composition)over(order by month_year)) as [1_month_ago]
 from rolling_avg
 ),
 month_2_lag as (
 select *, lag([1_month_ago])over(order by month_year) as [2_month_ago]
 from  month_1_lag
 )
 select * from month_2_lag
 where month_year  between '2018-09-01' and '2019-08-01'
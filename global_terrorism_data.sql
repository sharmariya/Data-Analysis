--reading data
select * from Projects..terrorism_data

--removing columns not needed
alter table Projects..terrorism_data drop column imonth

 --Remove dupicates
with Attack as(
select*,
ROW_NUMBER() over(
Partition by year, country, region, city, attacktype, targtype, gname, weaptype
order by year)
row_num
from
Projects..terrorism_data
)
select * --this will show all the dupicates
from Attack
where row_num>1
order by country

delete  --this will delete all the dupicates
from Attack
where row_num>1


--Number of terrorist attacks each year
select count(*) as attack_per_year, year
from Projects..terrorism_data
group by year
order by attack_per_year desc

--Number of attacks by region
select count(*) as attack_count, region
from Projects..terrorism_data
group by region
order by attack_count desc


--Number of attacks by country
select count(*) as attack_count, country
from Projects..terrorism_data
group by country
order by attack_count desc

---top 10 cities with most attacks
select top 10 city,  count(*) as attack_count
from Projects..terrorism_data
where city !='Unknown'
group by city
order by attack_count desc

--Different attack types
select count(*) as attack_count, attacktype as attack_type
from Projects..terrorism_data
group by attacktype
order by attack_count desc

--Different weapons used and their count
select count(*) as attack_count, weaptype as weapon_type
from Projects..terrorism_data
group by weaptype
order by attack_count desc

--Different types of targets
select count(*) as attack_count, targtype as target_type
from Projects..terrorism_data
group by targtype
order by attack_count desc

--Year with the most attack
select top 1  year,count(*) as attack_per_year
from Projects..terrorism_data
group by year
order by attack_per_year desc

--Most common attack type
select top 1 attacktype as attack_type, count(*) as attack_count
from Projects..terrorism_data
group by attacktype
order by attack_count desc

--Most common weapon type
select top 1 weaptype as weapon_type, count(*) as attack_count
from Projects..terrorism_data
group by weaptype
order by attack_count desc

--Most common target
select top 1 targtype as target_type,count(*) as attack_count
from Projects..terrorism_data
group by targtype
order by attack_count desc

--10 cities of India which are most attacked
select top 10 city ,count(*) as attack_count
from Projects..terrorism_data
where country='India' and city!='Unknown'
group by city
order by attack_count desc
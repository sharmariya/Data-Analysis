use Zomato
select * from zomato

select * from Country_code

--total number of restaurans
select count(distinct [Restaurant ID]) as total_restaurants
from zomato

--top 3 countries that uses zomato

select top 3 z.[Country Code],c.[Country] ,count(z.[Country Code])--over(partition by [Country Code])
from zomato z join Country_code c on z.[Country Code]=c.[Country Code]
group by z.[Country Code],c.[Country]
order by 3 desc

--understanding aggregate rating, rating color and rating text

select distinct [Aggregate rating], [Rating color],[Rating text]
from zomato
order by 1 

--restaurants in each city in India

select City,count(distinct [Restaurant ID]) as restaurants
from zomato
where [Country Code]=1
group by City
order by 2 desc

--which countries have online deliveries option 

select distinct c.[Country]
from zomato z
join Country_code c
on z.[Country Code]=c.[Country Code]
where [Has Online delivery]='Yes'

--highest price restaurants in India
select top 3  [Restaurant Name], City, [Average Cost for two]
from zomato
where [Country Code]=1 and [Average Cost for two]!=0
order by 3 desc
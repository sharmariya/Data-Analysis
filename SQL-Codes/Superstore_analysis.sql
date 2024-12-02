use Projects
--loading dataset
select * from superstore

--How are the sales and profit performance throughout the years?
select year([Order Date]) as year, sum(Sales) as yearly_sale, 
round(sum(Profit),2) as yearly_profit
from superstore
group by  year([Order Date])
order by year([Order Date]) desc

-- Which region has the highest sales?
select top 1 Region,year([Order Date]) as year,sum(sales) as Sales
from superstore
group by Region, year([Order Date])
order by 3 desc

--Which 3 cities have the highest profits each year?
with cte as
(select *,rank()over(partition by year order by profits desc) as rank 
from(
select 
city, year([Order Date]) as year,sum(profit) as profits
from superstore
group by city , year([Order Date])
--order by 3 desc
)a
)
select city, year, profits,rank()over(partition by year order by profits desc) as yearly_rank 
from cte
where rank <=3

-- Which segment and item have generated the most profit?
select top 3 category, [Sub-Category],[Product Name] as item , 
round(sum(profit),2) as profits
from superstore
where profit >0
group by  [Product Name],category, [Sub-Category]

order by 4 desc



--how long is from order to shipping lead time for each shipping option?
;with abc as
(select *,
DATEDIFF(DAY,[Order Date],[Ship Date]) as days_taken
from superstore
)
select [Ship Mode] , max(days_taken) as max_days_taken
from abc
group by [Ship Mode]




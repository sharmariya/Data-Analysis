select * from Projects..batsman
select * from Projects..bowler
select *  from Projects..Ground_Averages
select * from Projects..ODI_results
select * from Projects..ODI_Totals
select * from Projects..WC_Players

--deleting the unwanted columns
alter table Projects..batsman drop column F1
alter table Projects..bowler drop column F1
alter table Projects..ODI_results drop column F1
alter table Projects..ODI_Totals drop column F1

--total countries participated
select count(distinct Country) as Number_of_Countries from Projects..ODI_results
select distinct Country from Projects..ODI_results;


--total matches played 
select count( distinct Match_ID) as total_matches from  Projects..ODI_Totals 

--total matches played by each country and won
select country, count( distinct Match_ID) as total_matches_per_country
from  Projects..ODI_Totals 
group by Country
order by total_matches_per_country desc

--total matches won and lost by each country


select country,
sum(case when Result='won' then 1 else 0 end) as won_matches,
sum(case when Result='lost' then 1 else 0 end) as lost_matches
from  Projects..ODI_results
group by country
order by 2 desc



--total number of tie matches
select count( distinct Match_ID) as tied_matches from  Projects..ODI_results 
where Result='tied'

--Does India prefer to choose batting on winning toss or not?
 select  
sum(case when Toss='won'and Bat='1st' and Country='India' then 1 else 0 end) as India_Bat1,
sum(case when Toss='won'and Bat='2nd' and Country='India' then 1 else 0 end) as India_Bat2
from  Projects..ODI_results 


--
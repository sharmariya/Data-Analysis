select * from Projects..CensusTable1
select * from Projects..CensusTable2

--Total Population of India
select sum(Population) as Total_Population from Projects..CensusTable2

--Population state-wise
select State,sum(Population) as State_Population from Projects..CensusTable2
Group by State
Order by State_Population desc

--Most and least Populated States
select top 1 State as Most_populated_state,sum(Population) as State_Population from Projects..CensusTable2
Group by State
Order by State_Population desc

select top 1 State Least_populated_state,sum(Population) as State_Population from Projects..CensusTable2
Group by State
Order by State_Population asc

--Avg growth rate
select AVG(Growth) from Projects..CensusTable1

--Top 10 state with highest growth rate
select top 10  avg(Growth), State from Projects..CensusTable1
group by State
order by avg(Growth) desc

--average sex ratio
select round(avg(sex_ratio),0) from Projects..CensusTable1

--5 states with least sex ratio
select top 5  round(avg(sex_ratio),0) as sex_ratio, state from Projects..CensusTable1
group by State
order by sex_ratio

--Avg literacy rate
select round(AVG(Literacy),0)from Projects..CensusTable1

-- top and bottom 3 states in literacy state


drop table if exists topliteracyStates
create table topliteracyStates(state varchar(300), literacy float)
insert into topliteracyStates
select state,round(avg(literacy),0) avg_literacy_ratio from Projects..CensusTable1
group by state order by avg_literacy_ratio desc

SELECT TOP 3 * FROM topliteracyStates ORDER BY literacy DESC

drop table if exists leastliteracyStates
create table leastliteracyStates(state varchar(300), Leastliteracy float)
insert into leastliteracyStates
select state,round(avg(literacy),0) avg_literacy_ratio from Projects..CensusTable1
group by state order by avg_literacy_ratio asc

SELECT TOP 3 * FROM leastliteracyStates ORDER BY Leastliteracy ASC

--union of the above two tables 
select * from(SELECT TOP 3 * FROM topliteracyStates ORDER BY literacy DESC) A
union 
select * from(SELECT TOP 3 * FROM leastliteracyStates ORDER BY Leastliteracy ASC)B
order by literacy

--States starting with letter a
select distinct State from Projects..CensusTable1
Where lower(State) like 'a%'

--total males and females in each state
--sex_ratio=male/female, population=male+female
--male=sex_ratio*female
--population=sex_ratio*female+female
--population=female(sex_ratio+1)
--females=population/(sex_ratio+1)
--male=sex_ratio*population/(sex_ratio+1)

select d.state,sum(d.males)as total_males,sum(d.females)as total_females from
(select c.state, round(c.Population/(c.Sex_Ratio+1),0) as males, round(c.Sex_Ratio*c.Population/(c.Sex_Ratio+1),0)as females from
(select a.District,a.Sex_Ratio/1000 as Sex_Ratio,a.State,a.Growth,a.Literacy,b.Area_km2, b.Population
from Projects..CensusTable1 a join  Projects..CensusTable2 b
on a.District=b.District and a.State=b.State)c)d
group by d.State

--Total number of litterate and illiterate people in each state
--(literate/population)*100=literacy rate
--literate=(literacy rate*population)/100
select c.state, sum(c.Literate_People) as Total_Literate , sum(c.Illiterate_People) as Total_Illiterate from
(select a.District,round((a.Literacy*b.Population)/100,0)as Literate_People,round(((100-a.Literacy)*b.Population)/100,0) as Illiterate_People
,a.State, a.Literacy,b.Population
from Projects..CensusTable1 a join  Projects..CensusTable2 b
on a.District=b.District and a.State=b.State)c
group by c.State
order by c.State

--Population in previous census
--current population= previous population(1+growth)
--previous population=current population/(1+growth)
select sum(d.Previous_Population) as Total_Previous_Population from
(select c.state, sum(c.Previous_Population) as Previous_Population from
(select a.State,round(b.Population/(a.Growth+1),0) as Previous_Population
from Projects..CensusTable1 a join  Projects..CensusTable2 b
on a.District=b.District and a.State=b.State)c
group by c.State
)d

--How much area per population has been reduced from current census to previous census

select sum(d.State_Area)/sum(d.Previous_Population )as Previous_AreaPerPopulation, sum(d.State_Area)/sum(d.Population) as Current_AreaPerPopulation from
(select c.state, sum(c.Area_km2) as State_Area,sum(c.Population) as Population,sum(c.Previous_Population) as Previous_Population from
(select a.State,b.Area_km2,b.Population,round(b.Population/(a.Growth+1),0) as Previous_Population
from Projects..CensusTable1 a join  Projects..CensusTable2 b
on a.District=b.District and a.State=b.State)c
group by c.State)d

--Raanking districts according to literacy rate
select district,state,literacy,rank() over( order by literacy desc) rnk from Projects..CensusTable1

--top 3 districts from each state with highest literacy rate
select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from Projects..CensusTable1) a

where a.rnk in (1,2,3) order by state

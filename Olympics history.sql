use Olympics
select * from events
select* from noc_regions

--How many olympics games have been held?
select count(distinct Games) as game_count from events 

-- List down all Olympics games held so far.
select distinct Games as Game, Year, Season,City as game_count from events 

-- total no of nations who participated in each olympics game
select Games,count(distinct n.region) as nation_count
from events e join noc_regions n ON n.noc = e.noc
group by Games
order by 1

--Which year saw the highest and lowest no of countries participating in olympics
 with all_countries as
              (select games, nr.region
              from events oh
              join noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          tot_countries as
              (select games, count(1) as total_countries
              from all_countries
              group by games)
      select distinct
      concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from tot_countries
      order by 1
 --Which nation has participated in all of the olympic games
 with tot_games as
 (select count(distinct games) as total_games
              from events),
          countries as
              (select games, nr.region as country
              from events oh
              join noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          countries_participated as
              (select country, count(1) as total_participated_games
              from countries
              group by country)
      select cp.*
      from countries_participated cp
      join tot_games tg on tg.total_games = cp.total_participated_games
      order by 1
 --Identify the sport which was played in all summer olympics.
  with t1 as
          	(select count(distinct games) as total_games
          	from events where season = 'Summer'),
          t2 as
          	(select distinct games, sport
          	from events where season = 'Summer'),
          t3 as
          	(select sport, count(1) as no_of_games
          	from t2
          	group by sport)
      select *
      from t3
      join t1 on t1.total_games = t3.no_of_games;

--Which Sports were just played only once in the olympics.
  with t1 as
          	(select distinct games, sport
          	from events),
          t2 as
          	(select sport, count(1) as no_of_games
          	from t1
          	group by sport)
      select t2.*, t1.games
      from t2
      join t1 on t1.sport = t2.sport
      where t2.no_of_games = 1
      order by t1.sport;

-- the total no of sports played in each olympic games.
  with t1 as
      	(select distinct games, sport
      	from events),
        t2 as
      	(select games, count(1) as no_of_sports
      	from t1
      	group by games)
      select * from t2
      order by no_of_sports desc;







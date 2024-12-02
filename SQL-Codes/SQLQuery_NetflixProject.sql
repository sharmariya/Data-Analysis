--view table
select *
from NetflixProject..['Netflix data$']

--Finding about  movies
--Total movies
select count( title) as TotalNoOfMovies from NetflixProject..['Netflix data$']
where [Series or Movie] = 'Movie'
select  distinct(Genre) from
NetflixProject..['Netflix data$']



--Highest Imdb rated
select * from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie' and
[IMDb Score] = 
 (
 select max([IMDb Score])
 from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie' 
)

--Max award winning
select * from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie' and
[Awards Received] = 
 (
 select max([Awards Received])
 from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie' 
)

--Highest IMDb rated hindi romantic movie
select * from NetflixProject..['Netflix data$']
where Genre like '%Romance%'and [Series or Movie] = 'Movie' and Languages='Hindi' and
[IMDb Score] = 
 (
 select max([IMDb Score])
 from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie' and Languages='Hindi'
)
--Highest IMDb rated only romantic hindi movie
select * from NetflixProject..['Netflix data$']
where Genre ='Romance' and [Series or Movie] = 'Movie' and Languages='Hindi' and
[IMDb Score] = 
 (
 select max([IMDb Score])
 from NetflixProject..['Netflix data$']
where Genre = 'Romance' and [Series or Movie] = 'Movie' and Languages='Hindi'
)

--most recent
select * from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie' and
[Release Date]=
(
select max([Release Date])
 from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie' and [Release Date] is not null
)

--least difference between netflix release date and release date movie list ordered by title
select Title,Genre,[Release Date],[Netflix Release Date], datediff(Month,[Release Date],[Netflix Release Date]) as ReleaseDifference from NetflixProject..['Netflix data$']
where  [Series or Movie] = 'Movie' and
datediff(Month,[Release Date],[Netflix Release Date])=
(
select min(datediff(Month,[Release Date],[Netflix Release Date]))
 from NetflixProject..['Netflix data$']
where  [Series or Movie] = 'Movie' and
[Release Date]<=[Netflix Release Date]
)
order by ReleaseDifference, Title  

--list of  movies name with highest award received to awards nominated for ratio
select Title, ([Awards Received]/[Awards Nominated For]) as AwardRatio
from NetflixProject..['Netflix data$']
where  [Series or Movie] = 'Movie' and [Awards Nominated For] >'0' and [Awards Nominated For] >=[Awards Received]
order by AwardRatio desc

--types of genre and corresponding number of movies
select distinct Genre,count(Genre) as NumberOfMovies
from  NetflixProject..['Netflix data$']
group by Genre

--Checking different types of runtime entries
select distinct Runtime
from  NetflixProject..['Netflix data$']

--Categorizing movie as very short, short, long, very long according to rum-time
alter table NetflixProject..['Netflix data$'] add TypeOfMovie varchar(200)

update NetflixProject..['Netflix data$'] set TypeOfMovie=

case when Runtime like '30 minutes' then 'Very Short'
when Runtime like'30-60 mins' then   'Short'
when Runtime like'> 2 hrs' then  'Very Long'
when Runtime like'1-2 hour' then  'Long'

else 'Runtime is NULL'
end
from NetflixProject..['Netflix data$']


--Finding about horror movies
--All horror movies
select * from NetflixProject..['Netflix data$']
where Genre like '%Horror%' and [Series or Movie] = 'Movie'

--Highest Imdb rated
select * from NetflixProject..['Netflix data$']
where Genre like '%Horror%' and [Series or Movie] = 'Movie' and
[IMDb Score] = 
 (
 select max([IMDb Score])
 from NetflixProject..['Netflix data$']
where Genre like '%Horror%' and [Series or Movie] = 'Movie' 
)

--Max award winning
select * from NetflixProject..['Netflix data$']
where Genre like '%Horror%' and [Series or Movie] = 'Movie' and
[Awards Received] = 
 (
 select max([Awards Received])
 from NetflixProject..['Netflix data$']
where Genre like '%Horror%' and [Series or Movie] = 'Movie' 
)

--Highest IMDb rated hindi movie
select * from NetflixProject..['Netflix data$']
where Genre like '%Horror%' and [Series or Movie] = 'Movie' and Languages='Hindi' and
[IMDb Score] = 
 (
 select max([IMDb Score])
 from NetflixProject..['Netflix data$']
where Genre like '%Horror%' and [Series or Movie] = 'Movie' and Languages='Hindi'
)
--Highest IMDb rated only horror hindi movie
select * from NetflixProject..['Netflix data$']
where Genre like 'Horror' and [Series or Movie] = 'Movie' and Languages='Hindi' and
[IMDb Score] = 
 (
 select max([IMDb Score])
 from NetflixProject..['Netflix data$']
where Genre = 'Horror' and [Series or Movie] = 'Movie' and Languages='Hindi'
)

--most recent
select * from NetflixProject..['Netflix data$']
where Genre like '%Horror%' and [Series or Movie] = 'Movie' and
[Release Date]=
(
select top 1 [Release Date]
 from NetflixProject..['Netflix data$']
where Genre like '%Horror%' and [Series or Movie] = 'Movie'
order by [Release Date] desc

)

--least difference between netflix release date and release date
select * from NetflixProject..['Netflix data$']
where Genre like '%Horror%'  and [Series or Movie] = 'Movie' and
datediff(Month,[Release Date],[Netflix Release Date])=
(
select top 1 datediff(Month,[Release Date],[Netflix Release Date])
 from NetflixProject..['Netflix data$']
where Genre like '%Horror%' and [Series or Movie] = 'Movie' and
[Release Date]<=[Netflix Release Date]
order by datediff(Month,[Release Date],[Netflix Release Date]) asc
)

--list of movies name with highest award received to awards nominated for ratio
select Title, ([Awards Received]/[Awards Nominated For]) as AwardRatio
from NetflixProject..['Netflix data$']
where Genre like '%Horror%' and [Series or Movie] = 'Movie' and [Awards Nominated For] >'0' and [Awards Nominated For] >=[Awards Received]
order by AwardRatio desc


--Finding about romantic movies
--All romantic movies
select * from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie'

--Highest Imdb rated
select * from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie' and
[IMDb Score] = 
 (
 select max([IMDb Score])
 from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie' 
)

--Max award winning
select * from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie' and
[Awards Received] = 
 (
 select max([Awards Received])
 from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie' 
)

--Highest IMDb rated hindi romantic movie
select * from NetflixProject..['Netflix data$']
where Genre like '%Romance%'and [Series or Movie] = 'Movie' and Languages='Hindi' and
[IMDb Score] = 
 (
 select max([IMDb Score])
 from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie' and Languages='Hindi'
)
--Highest IMDb rated only romantic hindi movie
select * from NetflixProject..['Netflix data$']
where Genre ='Romance' and [Series or Movie] = 'Movie' and Languages='Hindi' and
[IMDb Score] = 
 (
 select max([IMDb Score])
 from NetflixProject..['Netflix data$']
where Genre = 'Romance' and [Series or Movie] = 'Movie' and Languages='Hindi'
)

--most recent
select * from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie' and
[Release Date]=
(
select max([Release Date])
 from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie' and [Release Date] is not null
)

--least difference between netflix release date and release date
select * from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie' and
datediff(Month,[Release Date],[Netflix Release Date])=
(
select min(datediff(Month,[Release Date],[Netflix Release Date]))
 from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie' and
[Release Date]<=[Netflix Release Date]
)

--list of  romantic movies name with highest award received to awards nominated for ratio
select Title, ([Awards Received]/[Awards Nominated For]) as AwardRatio
from NetflixProject..['Netflix data$']
where Genre like '%Romance%' and [Series or Movie] = 'Movie' and [Awards Nominated For] >'0' and [Awards Nominated For] >=[Awards Received]
order by AwardRatio desc
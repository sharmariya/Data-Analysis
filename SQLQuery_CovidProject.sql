
select Location,date,total_cases,new_cases,total_deaths,population
from CovidProject..CovidDeaths$
order by 1,2

--Likelyhood of dying depending on your nation
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from CovidProject..CovidDeaths$
where location like '%states%' and continent is not null
order by 1,2

--comparying total cases with population(what percentag eof population died)
select Location,date,total_cases,population,(total_cases/population)*100 as infectedpopulation_percentage
from CovidProject..CovidDeaths$
where location like 'India' and continent is not null
order by 1,2

--highest infection rate countries
select Location,max(total_cases) as highest_infection, max(total_cases/population)*100 as PercentPopulationInfected
from CovidProject..CovidDeaths$
where continent is not null
group by Location
order by 3 desc

--Showing countries with highest death count per population
select Location,max(cast(total_deaths as int)) as TotalDeathCount, max(total_deaths/population)*100 as PercentPopulationDied
from CovidProject..CovidDeaths$
where continent is not null
group by Location
order by 2 desc

--Showing continents with the highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCountInContinet
from CovidProject..CovidDeaths$
where continent is not null
group by continent
order by 2 desc

--GLOBAL NUMBERS(New cases and deaths daily)
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from CovidProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

--Joining deaths and vaccine tables
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(CONVERT(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths$ d
join CovidProject..CovidVaccinations$ v
on d.location= v.location
and d.date=v.date
where d.continent is not null
order by 2,3

--use cte
with PopvsVac(Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(CONVERT(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated --gradually number of vaccines for a particular location are added according to date and location
from CovidProject..CovidDeaths$ d
join CovidProject..CovidVaccinations$ v
on d.location= v.location
and d.date=v.date
where d.continent is not null
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac

--temp table
drop table if exists percentPopulationVaccinated
create table percentPopulationVaccinated
(
continet nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)
insert into percentPopulationVaccinated
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(CONVERT(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated 
from CovidProject..CovidDeaths$ d
join CovidProject..CovidVaccinations$ v
on d.location= v.location
and d.date=v.date
where d.continent is not null
select *,(RollingPeopleVaccinated/Population)*100
from percentPopulationVaccinated

--creating view to store data for visualization
create view percentPopulationVaccinatedview as
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(CONVERT(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths$ d
join CovidProject..CovidVaccinations$ v
on d.location= v.location
and d.date=v.date
where d.continent is not null
select * from percentPopulationVaccinatedview


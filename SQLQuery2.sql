Select *
From [Portfolio Project]..covidDeaths
Where continent is not null
order by 3,4

Select *
From [Portfolio Project]..covidVaccinations
order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..covidDeaths
order by 1,2

-- Looking at total cases vs. total deaths
-- shows likelihood of dying of covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From [Portfolio Project]..covidDeaths
Where continent is not null
Where location like '%states%'
order by 1,2

-- Looking at total cases vs population
Select Location, date, population,total_cases, (total_cases/population)*100 as total_infected
From [Portfolio Project]..covidDeaths
--Where location like '%Germany%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as
	PercentPopulationInfected
From [Portfolio Project]..covidDeaths
Where continent is not null
Group by Location, population
order by PercentPopulationInfected desc

-- Looking at countries with highest death rate compared to population
Select Location, population, MAX(cast(total_deaths as bigint)) as highest_death_count, MAX(cast(total_deaths as bigint)/population)*100 as
	PercentPopulationDead
From [Portfolio Project]..covidDeaths
Where continent is not null
Group by Location, population
order by highest_death_count desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count

Select continent,MAX(cast(total_deaths as bigint))
	PercentPopulationDead
From [Portfolio Project]..covidDeaths
Where continent is not null
Group by continent
order by PercentPopulationDead desc



-- GLOBAL NUMBERS
 -- overall numbers
Select sum(new_cases) as total_cases, 
	sum(cast(new_deaths as bigint)) as total_deaths, 
	sum(cast(new_deaths as bigint))/sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..covidDeaths
Where continent is not null
order by 1,2

--numbers by date
Select date, sum(new_cases) as total_cases, 
	sum(cast(new_deaths as bigint)) as total_deaths, 
	sum(cast(new_deaths as bigint))/sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..covidDeaths
Where continent is not null
Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations




-- USE CTE

With popvsvac (continent,Location, date, population,new_vaccinations, rolling_people_vaccinated)
as 
(
Select dea.continent,dea.Location,dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.Location 
												Order by dea.Location, dea.date)
												as rolling_people_vaccinated
--,(rolling_people_vaccinated/population)*100
From [Portfolio Project]..covidVaccinations vac
Join [Portfolio Project]..covidDeaths dea
	On dea.Location = vac.Location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (rolling_people_vaccinated/population)*100
From popvsvac


-- TEMP TABLE

drop table if exists #percent_population_vaccinated
create table #percent_population_vaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)



Insert into #percent_population_vaccinated
Select dea.continent,dea.Location,dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.Location 
												Order by dea.Location, dea.date)
												as rolling_people_vaccinated
--,(rolling_people_vaccinated/population)*100
From [Portfolio Project]..covidVaccinations vac
Join [Portfolio Project]..covidDeaths dea
	On dea.Location = vac.Location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (rolling_people_vaccinated/population)*100
From #percent_population_vaccinated


-- creating view to store data for later visualisation

create view percent_population_vaccinated as 
Select dea.continent,dea.Location,dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.Location 
												Order by dea.Location, dea.date)
												as rolling_people_vaccinated
--,(rolling_people_vaccinated/population)*100
From [Portfolio Project]..covidVaccinations vac
Join [Portfolio Project]..covidDeaths dea
	On dea.Location = vac.Location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
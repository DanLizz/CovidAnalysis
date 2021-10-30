SELECT *
FROM CovidDatabase..covid_deaths
where continent is not null
order by 3,4

--SELECT *
--FROM CovidDatabase..covid_vaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDatabase..covid_deaths
order by 1,2


-- Total Cases vs Total Deaths and Chance of Death by COVID 19 in Canada
select 
	location, date, 
	total_cases, total_deaths,
	(total_deaths/total_cases)*100 as percentage_of_death
from CovidDatabase..covid_deaths
	where location like '%canada%'
order by 1,2


-- Total cases vs Population and Chance of getting infected in Canada
select 
	location, date, 
	total_cases, population,
	(total_cases/population)*100 as 'Chance_of_infection(%)'
from CovidDatabase..covid_deaths
	where location like '%canada%'
order by 1,2

-- Total cases vs Population
select 
	location, population, 
	MAX(total_cases) AS Highest_infection_count, 
	(MAX(total_cases)/population)*100 as 'Chance_of_infection(%)'
from CovidDatabase..covid_deaths
where continent is not null and population is not null
group by location, population
order by 'Chance_of_infection(%)' desc


-- Total deaths vs Population
select 
	location, population, 
	MAX(cast(total_deaths as int)) as Highest_Death_count, 
	(MAX(total_deaths)/population)*100 as 'Chance_of_Death(%)'
from CovidDatabase..covid_deaths
where continent is not null and population is not null
group by location, population
order by Highest_Death_count desc

-- Total deaths by Continent
select 
	continent, 
	MAX(cast(total_deaths as int)) as Highest_Death_count
from CovidDatabase..covid_deaths
where continent is not null
group by continent
order by Highest_Death_count desc


-- Continents with highest infection rate
select location,
	MAX(cast(total_cases as int)) as Highest_Infection_count
from CovidDatabase..covid_deaths
where continent is  null
group by location
order by Highest_Infection_count desc


--World Numbers - Infection and Deaths
select location,
	SUM(cast(new_cases as int)) as Total_Cases,	
	SUM(cast(new_deaths as int)) as Total_Deaths
from CovidDatabase..covid_deaths
where continent is  null
group by location
order by Total_Cases desc

--World Numbers - Infection and Deaths
select location,
	SUM(cast(new_cases as int)) as Total_Cases,	
	SUM(cast(new_deaths as int)) as Total_Deaths,
	SUM(cast(new_deaths as int))/SUM(cast(new_cases as int))*100 as Percentage_of_Death
from CovidDatabase..covid_deaths
where continent is  null
group by location
order by Total_Cases desc


-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location) as RollingPeopleVaccination
from CovidDatabase..covid_deaths dea
join CovidDatabase..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3


--CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location) as RollingPeopleVaccination
from CovidDatabase..covid_deaths dea
join CovidDatabase..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- Temp table

--DROP Table IF EXISTS #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccination numeric)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location) as RollingPeopleVaccination
from CovidDatabase..covid_deaths dea
join CovidDatabase..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null


Select *, (RollingPeopleVaccination/Population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated




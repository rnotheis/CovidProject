select *
from CovidProject..CovidVaccinations
where continent is not null
Order by 3,4


--Select *
--From CovidProject..CovidVacinations
--Order by 3,4

-- Selecting the data in CovidDeaths I need

select location, date, total_cases, new_cases, total_deaths, population
from CovidProject..CovidDeaths
Order by location, date

-- Looking at Total Cases by Total Deaths

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from CovidProject..CovidDeaths
Order by location, date 

-- Looking at Total Case by Total Deaths for United States

Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From CovidProject..CovidDeaths
Where location = 'United States'
Order by location, date 

-- Looking at the Total Cases by Total Deaths for the US during the summer months of May through August

Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From CovidProject..CovidDeaths
Where location = 'United States' 
And date Between '2020-05-01' And '2020-08-31' 
Order by location, date 


-- Looking at the Total Cases vs the Total Population in US

Select location, date, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
From CovidProject..CovidDeaths
Where location = 'United States'
Order by location, date 

-- Looking at countries with the Highest Infection Rate compared to Population

Select location, population, Max(total_cases) as HighestInfectedRate, Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
Group By location, population
Order by PercentPopulationInfected DESC

-- Showing the Countries with the Highest Death Count per Population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
where continent is not null
Group By location
Order by TotalDeathCount DESC


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases) * 100 as DeathPercentage
From CovidProject..CovidDeaths
-- Where location = 'United States'
Where continent is not null
--Group by date
Order by 1,2 


-- Covid Vaccinations 
-- Looking at Total Populations vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

Select *, (RollingPeopleVaccinated/population) * 100 as PercentRollingPeopleVaccinated
From PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/population) * 100 
From #PercentPopulationVaccinated


-- CREATING VIEWS TO STORE DATA FOR LATER VISUALIZATIONS

Drop View if exists PercentPopulationVaccinated 

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


-- Creating a view for looking at Total Cases by Total Deaths

Drop View if exists TotalCasesVsTotalDeaths 

Create View TotalCasesVsTotalDeaths as 
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from CovidProject..CovidDeaths


-- Creating a view for looking at Total Case by Total Deaths for United States

Drop View if exists US_TotalCasesVsTotalDeaths 

Create View US_TotalCasesVsTotalDeaths as 
Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From CovidProject..CovidDeaths
Where location = 'United States'


-- Creating a view for looking at the Total Cases by Total Deaths for the US during the summer months of May through August
Drop View if exists US_TotalCasesVsTotalDeaths_SUMMER 

Create View US_TotalCasesVsTotalDeaths_SUMMER as
Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From CovidProject..CovidDeaths
Where location = 'United States' 
And date Between '2020-05-01' And '2020-08-31' 

-- Creating a view for looking at the Total Cases vs the Total Population in US
Drop View if exists US_TotalCasesVsTotalPopulation 

Create View US_TotalCasesVsTotalPopulation as 
Select location, date, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
From CovidProject..CovidDeaths
Where location = 'United States'

-- Creating a view for looking at countries with the Highest Infection Rate compared to Population
Drop View if exists HighestInfectionRate 

Create View HighestInfectionRate as
Select location, population, Max(total_cases) as HighestInfectedRate, Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
Group By location, population

-- Creating a view for showing the Countries with the Highest Death Count per Population
Drop View if exists TotalDeathCount 

Create View TotalDeathCount as
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
where continent is not null
Group By location

-- Creating a view for looking at GLOBAL NUMBERS
Drop View if exists GlobalNumbers 

Create View GlobalNumbers as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases) * 100 as DeathPercentage
From CovidProject..CovidDeaths
-- Where location = 'United States'
Where continent is not null


-- Creating a view for looking at Total Populations vs Vaccinations
Drop View if exists TotalPopVsVaccinations 

Create View TotalPopVsVaccinations as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null





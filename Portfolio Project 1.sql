/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

use PortfolioProject;


--Checking Total Data

select * from CovidDeaths
where continent is not null
order by 1,2;

--Total deaths vs total cases in our country

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths 
where continent is not null
and location like 'India';


--Total deaths vs total cases in our country

select location,date,total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths 
where location like 'India'
and continent is not null
order by 1,2;


--Countries with highest Infection rate compared to population

select location,population,MAX(total_cases) as HighestInfectedCount, Max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths 
--where location like 'India'
group by location,population
order by PercentPopulationInfected desc;


--Countries with highest death count per population

	
select location	,MAX(cast(Total_Deaths as int)) as TotalDeathCount
from CovidDeaths 
--where location like 'India'
where continent is not null
group by location
order by TotalDeathCount desc;


--Continents with highest death count per population

select continent ,MAX(cast(Total_Deaths as int)) as TotalDeathCount
from CovidDeaths 
--where location like 'India'
where continent is not null
group by continent
order by TotalDeathCount desc;


--Global Numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Total_Death_Percentage
from CovidDeaths 
where continent is not null
order by 1,2;


--Global Numbers by date

select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Total_Death_Percentage
from CovidDeaths 
where continent is not null
group by date
order by 1,2;


--Checking other table
select * from PortfolioProject..CovidVaccinations;


--Joining two tabels 
--Total Population vs Total Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3



 -- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 RollingPeopleVac_Percentage
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select * from PercentPopulationVaccinated;


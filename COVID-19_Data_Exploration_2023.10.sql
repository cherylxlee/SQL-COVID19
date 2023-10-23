/*
COVID-19 Data Exploration 

Skills: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject1..CovidDeaths
Where continent is not null 
order by 3,4


-- Starting data set
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
Where continent is not null 
order by 1,2

-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract COVID-19 in your country
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / total_cases)*100 as MortalityRate
from PortfolioProject1.. CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs. Population
-- Shows % of population that have contracted COVID-19
Select Location, date, total_cases, population, (total_cases / population)*100 as InfectedPopulation
from PortfolioProject1.. CovidDeaths
where location like '%states%' AND continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestReportedInfections, (MAX(total_cases)/population)*100 as InfectedPopulation
From PortfolioProject1.. CovidDeaths
where continent is not null
Group by Location, Population
order by InfectedPopulation desc

-- Looking at Countries with Highest Mortality Rate
Select Location, MAX(CONVERT(float, total_deaths)) as TotalReportedDeaths
From PortfolioProject1.. CovidDeaths
where continent is not null
Group by Location
order by TotalReportedDeaths desc

-- Showing Continents with the highest death count per capita
Select location, MAX(CONVERT(float, total_deaths)) as TotalReportedDeaths
From PortfolioProject1.. CovidDeaths
where continent is null
Group by location
order by TotalReportedDeaths desc

-- Global: Cases & Deaths per day
Select date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as MortalityRate
From PortfolioProject1.. CovidDeaths
where continent is not null 
Group by date
order by 1,2

-- Global: Total Deaths, Cases, and Mortality Rate Globally
Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as MortalityRate
From PortfolioProject1.. CovidDeaths
where continent is not null 
order by 1,2


-- Looking at Total Population vs. Vaccination by Country per day

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject1.. CovidDeaths dea
Join PortfolioProject1.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- Looking at Total Population vs. Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date)
  as RollingVaccinationCount
from PortfolioProject1.. CovidDeaths dea
Join PortfolioProject1.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

With PopVsVac (continent, location, date, population, new_vaccinations, RollingVaccinationCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date)
  as RollingVaccinationCount
from PortfolioProject1.. CovidDeaths dea
Join PortfolioProject1.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingVaccinationCount / population)*100 as RollingVaccinatedPerCapita
from PopVsVac
Order by 2,3

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinationCount numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date)
  as RollingVaccinationCount
from PortfolioProject1.. CovidDeaths dea
Join PortfolioProject1.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

Select *, (RollingVaccinationCount / population)*100 as RollingVaccinatedPerCapita
from #PercentPopulationVaccinated
Order by 2,3

-- Creating view for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date)
  as RollingVaccinationCount
from PortfolioProject1.. CovidDeaths dea
Join PortfolioProject1.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
from PercentPopulationVaccinated
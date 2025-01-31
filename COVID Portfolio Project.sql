Select*
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select*
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Selecting the data we are going to use

Select location, date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
order by 1,2

--Exploring Total Cases vs Total Deaths
Select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From PortfolioProject..CovidDeaths
Where location = 'India'
order by 1,2

--Exploring Total Cases  Vs Population 
--Shows what percentage of population got covid
Select location, date, total_cases, population, (total_cases/population)*100 as infected_percentage
From PortfolioProject..CovidDeaths
order by 1,2
--Where location = 'India'

--Exploring Countries with Highest Infection Rate compared to Population

Select location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as infected_percentage
From PortfolioProject..CovidDeaths
Group by location, population
--Where location = 'India'
order by infected_percentage desc

--Showing Countries With Highest Death Count 
Select location,  Max(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
--Where location = 'India'
order by total_death_count desc

--Death Count By Continent
Select location, Max(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
where continent is  null
Group by location
--Where location = 'India'
order by total_death_count desc

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Exploring Total Population Vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Creating CTE


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as Percentage
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

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Create View population_infected as
Select location, date, total_cases, population, (total_cases/population)*100 as infected_percentage
From PortfolioProject..CovidDeaths

Create View Highest_infection_Percent as
Select location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as infected_percentage
From PortfolioProject..CovidDeaths
Group by location, population





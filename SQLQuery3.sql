SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
order by 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--order by 3, 4
--select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
order by 1, 2


--looking at total cases vs total deaths
--the likelihood of dying from covid
SELECT location, date, total_cases,  total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
where location like '%Nigeria%'
order by 1, 2

--percentage of population that has covid
--cases/population

SELECT location, date, total_cases,  population, 
(total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
where location like '%Nigeria%'
order by 1, 2

--country with the highest infection rate
SELECT location,  population, MAX(total_cases),
MAX((total_cases/population)*100)as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location,  population
order by 4 desc

--highest death count per country
SELECT continent, location, MAX(cast (total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, continent
ORDER BY 3 DESC

--BY CONTINENTS (continents with thw highest deathcount)
SELECT continent, SUM (cast (total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

--Global cases and deaths
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath,
(SUM(cast(new_deaths as int))/ SUM(new_cases))*100 as TotaldeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
Group by date
order by 1 DESC

--TOTAL CASES ACROSS THE WORLD 
SELECT  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath,
(SUM(cast(new_deaths as int))/ SUM(new_cases))*100 as TotaldeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
--Group by date
order by 1 DESC


--MOVING TO THE SECOND VACINATION TABLE
SELECT * 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
on dea.location =vac.location
and dea.date = vac.date

--total wpold population vs vacination 
SELECT dea.location, dea.population, 
SUM(cast(vac.new_vaccinations as int)) as Totalvaccination
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent  IS NOT NULL
GROUP BY dea.location, dea.population
ORDER BY dea.location, dea.population

SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent IS NOT NULL
order by 2,3

--adding up total vacinnated people per date and per location
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date)as RollingPeopleVacinated 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent IS NOT NULL
order by 2,3

--USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVacinated )as
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date)as RollingPeopleVacinated 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent IS NOT NULL

)
select *, (RollingPeopleVacinated/population)*100
From PopvsVac


-- TEMP TABLE 
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric, 
RollingPeopleVacinated numeric
)
Insert into  #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date)as RollingPeopleVacinated 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent IS NOT NULL


select *, (RollingPeopleVacinated/population)*100 As PercentageperPopulationVaccinated
From #PercentPopulationVaccinated
where Location like '%canada%'
order by PercentageperPopulationVaccinated desc

--creating view for visualization
Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date)as RollingPeopleVacinated 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent IS NOT NULL

Select *
from PercentPopulationVaccinated

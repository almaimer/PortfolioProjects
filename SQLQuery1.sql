SELECT *
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT null
ORDER BY 3,4

--Select the data we will be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects.. CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths in the United States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

--Looking at the Total Cases vs Population in the United States
--Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2


--Looking at countries with highest infection rate compared to population
SELECT location, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Showing Continent with Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location =  vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2,3

--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location =  vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--USE TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location =  vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location =  vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null



Select *
FROM PercentPopulationVaccinated
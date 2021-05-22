SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..CovidVacinations
ORDER BY 3,4


-- Get data we need to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total cases vs total deaths
-- Whats likelihood of dying if you contract covid in your country?
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%kingdom%' AND continent IS NOT NULL
ORDER BY 1,2

-- Total cases vs population
-- What percentage of population got covid?
SELECT location, date, total_cases, population, ROUND((total_cases / population) * 100,2) AS PercentOfPopulationWithCovid
FROM PortfolioProject..CovidDeaths
--WHERE location like '%kingdom%' AND continent IS NOT NULL
ORDER BY 1,2

-- Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population) * 100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%kingdom%' AND continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- LETS BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC

-- Showing countries with highest death count per population
SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, sum(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%kingdom%' AND continent IS NOT NULL
WHERE continent IS NOT NULL
--GROUP BY date  -- Get rid of this for across the entire world
ORDER BY 1,2



-- USE CTE -- temporary result set that you can reference within another SELECT, INSERT, UPDATE, or DELETE statement
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
-- Looking at total population vs vaccination
SELECT da.continent, da.location, da.date, da.population, dv.new_vaccinations,
	SUM(CAST(dv.new_vaccinations AS INT)) OVER (PARTITION BY da.location ORDER BY da.location, da.date) 
	AS RollingPeopleVaccinated -- Adds people vaccinated into a rolling count,and resets once a new location is reached
FROM PortfolioProject..CovidDeaths da
JOIN PortfolioProject..CovidVacinations dv
	ON da.location = dv.location
	AND da.date = dv.date
WHERE da.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated /Population) * 100
FROM PopvsVac



--TEMP TABLE (same as CTE just using a temp table)
DROP TABLE IF EXISTS #PercentPopulationVaccinated --So you can run whole block of code below mutiple time
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT da.continent, da.location, da.date, da.population, dv.new_vaccinations,
	SUM(CAST(dv.new_vaccinations AS INT)) OVER (PARTITION BY da.location ORDER BY da.location, da.date) 
	AS RollingPeopleVaccinated -- Adds people vaccinated into a rolling count,and resets once a new location is reached
FROM PortfolioProject..CovidDeaths da
JOIN PortfolioProject..CovidVacinations dv
	ON da.location = dv.location
	AND da.date = dv.date
--WHERE da.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated /Population) * 100
FROM #PercentPopulationVaccinated



-- CREATE VIEW (like permenant version of temp table)
-- Creating view to store data vizualizations Portfolioproject > Views > 
CREATE VIEW PercentPopulationVaccinated AS
SELECT da.continent, da.location, da.date, da.population, dv.new_vaccinations,
	SUM(CAST(dv.new_vaccinations AS INT)) OVER (PARTITION BY da.location ORDER BY da.location, da.date) 
	AS RollingPeopleVaccinated -- Adds people vaccinated into a rolling count,and resets once a new location is reached
FROM PortfolioProject..CovidDeaths da
JOIN PortfolioProject..CovidVacinations dv
	ON da.location = dv.location
	AND da.date = dv.date
WHERE da.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated

--Used for tableau tables
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc
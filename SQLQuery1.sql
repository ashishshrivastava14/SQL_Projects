SELECT *
FROM CovidDeaths
ORDER BY 3,4

SELECT * 
FROM CovidVaccinations
ORDER BY 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Total Cases Vs Total Deaths
SELECT Location, date, total_cases, total_deaths, (NULLIF(CONVERT(float, total_deaths), 0) / NULLIF(CONVERT(float, total_cases), 0))*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%INDIA%'
ORDER BY 1,2 DESC


-- Total Cases Vs Population
-- Shows what percentage of population got covid
SELECT Location, date, population, total_cases, (NULLIF(CONVERT(float, total_cases), 0) / NULLIF(CONVERT(float, population), 0))*100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE location LIKE '%INDIA%'
ORDER BY 1,2 desc

-- Countries with highest infection rate Vs Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((NULLIF(CONVERT(float, total_cases), 0) / NULLIF(CONVERT(float, population), 0)))*100 AS PercentagePopulationInfected
FROM CovidDeaths
-- WHERE location LIKE '%INDIA%'
GROUP BY Location, population
ORDER BY PercentagePopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Showing Continents with Highest Death Count per Population
SELECT continent, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT SUM(new_cases) As total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 DESC


-- Looking at total population Vs Vaccinations
SELECT d.continent, d.location, d.date, d.population, NULLIF(CONVERT(bigint, v.new_vaccinations), 0) AS new_vaccinations,
		SUM(NULLIF(CONVERT(bigint, v.new_vaccinations), 0)) OVER (Partition by d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
		-- (RollingPeopleVaccinated/Population)*100
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT d.continent, d.location, d.date, d.population, NULLIF(CONVERT(bigint, v.new_vaccinations), 0) AS new_vaccinations,
		SUM(NULLIF(CONVERT(bigint, v.new_vaccinations), 0)) OVER (Partition by d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, NULLIF(CONVERT(bigint, v.new_vaccinations), 0) AS new_vaccinations,
		SUM(NULLIF(CONVERT(bigint, v.new_vaccinations), 0)) OVER (Partition by d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Create View to store data for later visualization

CREATE VIEW PercentagePopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, NULLIF(CONVERT(bigint, v.new_vaccinations), 0) AS new_vaccinations,
		SUM(NULLIF(CONVERT(bigint, v.new_vaccinations), 0)) OVER (Partition by d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
-- ORDER BY 2,3

SELECT * 
FROM PercentagePopulationVaccinated
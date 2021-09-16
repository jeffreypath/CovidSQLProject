SELECT *
FROM CovidProject..CovidDeaths
ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidProject..CovidDeaths
ORDER BY 1,2


--Comparing Total Cases and Total Deaths
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage 
FROM CovidProject..CovidDeaths
WHERE location like 'Thai%'
ORDER BY 1,2
 

--Comparing Total Cases and Population
SELECT location,date,total_cases,population,(total_cases/population)*100 AS Cases_Percentage 
FROM CovidProject..CovidDeaths
WHERE location like 'Thai%'
ORDER BY 1,2

--Highest infection rate
SELECT location,population,MAX(total_cases) AS totalcases,MAX((total_cases/population))*100 AS Cases_Percentage 
FROM CovidProject..CovidDeaths
GROUP BY location,population
ORDER BY Cases_Percentage DESC

--Country with highest death count per population
SELECT location,MAX(CAST(total_deaths AS int)) AS totaldeath,MAX((total_deaths/population))*100 AS Deaths_Percentage 
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Deaths_Percentage DESC

--Continent
SELECT continent,MAX(CAST(total_deaths AS int)) AS totaldeath,MAX((total_deaths/population))*100 AS Deaths_Percentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Deaths_Percentage DESC


-- Global Numbers
SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS Deaths_Percentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Population and Vaccinations
WITH PopVsVac (continent,location,date,population,new_vaccinations,CumVac) --CTE number of item in () must be the same with SELECT
AS
(
SELECT DEATH.continent, DEATH.location, DEATH.date, DEATH.population, VAC.new_vaccinations,
SUM(CONVERT(int,VAC.new_vaccinations)) OVER (PARTITION BY DEATH.location ORDER by DEATH.location, DEATH.date) AS CumVac
--(CumVac/DEATH.population)*100 AS Vacrate
--You cannot use CumVac here so
FROM CovidProject..CovidDeaths DEATH
JOIN CovidProject..CovidVaccinations VAC
	ON DEATH.location = VAC.location
	AND DEATH.date = VAC.date
WHERE DEATH.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (Cumvac/population)*100 AS Percentage
FROM PopVsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date datetime,
population numeric,
new_vaccinations numeric,
CumVac numeric
)

SELECT DEATH.continent, DEATH.location, DEATH.date, DEATH.population, VAC.new_vaccinations,
SUM(CONVERT(int,VAC.new_vaccinations)) OVER (PARTITION BY DEATH.location ORDER by DEATH.location, DEATH.date) AS CumVac
--(CumVac/DEATH.population)*100 AS Vacrate
--You cannot use CumVac here so
FROM CovidProject..CovidDeaths DEATH
JOIN CovidProject..CovidVaccinations VAC
	ON DEATH.location = VAC.location
	AND DEATH.date = VAC.date
WHERE DEATH.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (Cumvac/population)*100 AS Percentage
FROM #PercentPopulationVaccinated

--CREATE VIEW FOR VISUALIZATION LATER
CREATE VIEW PercentPopulationVaccinated AS
SELECT DEATH.continent, DEATH.location, DEATH.date, DEATH.population, VAC.new_vaccinations,
SUM(CONVERT(int,VAC.new_vaccinations)) OVER (PARTITION BY DEATH.location ORDER by DEATH.location, DEATH.date) AS CumVac
--(CumVac/DEATH.population)*100 AS Vacrate
--You cannot use CumVac here so
FROM CovidProject..CovidDeaths DEATH
JOIN CovidProject..CovidVaccinations VAC
	ON DEATH.location = VAC.location
	AND DEATH.date = VAC.date
WHERE DEATH.continent IS NOT NULL


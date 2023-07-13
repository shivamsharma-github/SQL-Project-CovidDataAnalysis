USE my_first_project;

SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY location, date;

SELECT *
FROM covid_vaccinations
ORDER BY location, date;

-- Selecting the required data from covid_deaths table

SELECT location, date, total_cases, total_deaths, population
FROM covid_deaths
ORDER BY location, date;

-- Looking at Total Cases Vs Total Deaths In India

SELECT location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases)*100 AS DeathPercentage
FROM covid_deaths
WHERE location = 'India'
ORDER BY location, date; 

-- Looking at Total Cases Vs Population In India

SELECT location, date, population, total_cases, (total_cases*1.0/population)*100 AS InfectionPercentage
FROM covid_deaths
WHERE location = 'India'
ORDER BY location, date; 

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX(total_cases*1.0/population)*100 AS InfectionPercentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectionPercentage DESC; 

-- Looking at countries with highest death count per population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC; 

-- Looking at death count per Continent

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC; 

-- Looking at the Global numbers

SELECT date, SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths,
(SUM(new_deaths))*1.0/NULLIF(SUM(new_cases),0)*100 AS UpdatedDeathRate
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY TotalNewCases DESC, TotalNewDeaths DESC; 

-- Looking at total new cases Vs total deaths with updated death rate

SELECT SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths,
(SUM(new_deaths))*1.0/NULLIF(SUM(new_cases),0)*100 AS UpdatedDeathRate
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY TotalNewCases DESC, TotalNewDeaths DESC; 


-- Looking at Total Population Vs Total Vaccinations Using CTE

WITH populationVsvaccination AS 
(SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(BIGINT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingSumVaccination
FROM covid_deaths D INNER JOIN covid_vaccinations V
ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL)
SELECT *, (RollingSumVaccination/population)*100 AS VaccinationPercentage
FROM populationVsvaccination;


-- Creating a temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC, 
rolling_sum_vacctions NUMERIC
);


INSERT INTO #PercentPopulationVaccinated
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(BIGINT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingSumVaccination
FROM covid_deaths D INNER JOIN covid_vaccinations V
ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL;


SELECT *, (rolling_sum_vacctions/population)*100 AS VaccinationPercentage
FROM #PercentPopulationVaccinated;


-- Creating views to store data for visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CONVERT(BIGINT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingSumVaccination
FROM covid_deaths D INNER JOIN covid_vaccinations V
ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL;

CREATE VIEW UpdatedCasesVsDeaths AS
SELECT SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths,
(SUM(new_deaths))*1.0/NULLIF(SUM(new_cases),0)*100 AS UpdatedDeathRate
FROM covid_deaths
WHERE continent IS NOT NULL;

CREATE VIEW GlobalCovidData AS
SELECT date, SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths,
(SUM(new_deaths))*1.0/NULLIF(SUM(new_cases),0)*100 AS UpdatedDeathRate
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date;

--------------------------------------------- THE END -----------------------------------------
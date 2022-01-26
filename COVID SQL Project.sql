SELECT *
FROM coviddeaths
ORDER BY 3,4;

-- Select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1,2;

-- Looking at the total case vs the total deaths
-- Likelyhood of dying if you have covid based on your location
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE location like '%canada%'
ORDER BY 1,2;

-- Looking at the total cases vs the population
SELECT location, date, total_cases, population, (total_Cases/population)*100 as CasePercentage
FROM coviddeaths
WHERE location like '%canada%'
ORDER BY 1,2;

-- What country/location has the highest infection rate compared to population
SELECT location,population, MAX(total_cases) as HighestInfectionCount,(MAX(total_Cases/population))*100 as InfectedPercentage
FROM coviddeaths
GROUP BY location, population
ORDER BY InfectedPercentage DESC;

-- Showing countries with the highest death count per population

SELECT location, MAX(total_deaths) as TotalDeathCount, population, (MAX(total_deaths/population))*100 as DeathRatePercentage
FROM coviddeaths
GROUP BY location
ORDER BY DeathRatePercentage DESC;

-- Showing Continent with the highest death count per population

SELECT locations.continent, SUM(locations.PopCount) AS TotalPopCount, SUM(locations.TotalDeathCount) AS TotalDeathCountContinent, (SUM(locations.TotalDeathCount)/SUM(locations.PopCount))*100 AS DeathRatePercentageCont
FROM
(SELECT location, continent, MAX(population) as PopCount, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths
GROUP BY location) as locations
GROUP BY continent
ORDER BY TotalDeathCountContinent DESC;

-- Showing Global numbers of the death percentage  

SELECT SUM(new_cases) AS TotalCases ,SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
ORDER BY 1,2;

-- Lets look into the Covid Vaccines Table
SELECT *
FROM covidvax;

-- Lets join the tables together
-- Looking at the Total Pop vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CAST(vax.new_vaccinations AS SIGNED int)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingCount
FROM coviddeaths dea
JOIN covidvax vax
	ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.location like '%canada%'
ORDER BY 2,3;

-- USE CTE

WITH PopVsVax (Continent, Location, Date, Population, New_Vaccinations, RollingCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CAST(vax.new_vaccinations AS SIGNED int)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingCount
FROM coviddeaths dea
JOIN covidvax vax
	ON dea.location = vax.location
    AND dea.date = vax.date
)
SELECT *, (RollingCount/Population)*100 AS PercentofPopVaxxed
FROM PopvsVax;


-- Creating a view to store data for later visualizations
DROP VIEW IF exists PopVSVax;
CREATE VIEW PopVSVax as 
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(CAST(vax.new_vaccinations AS SIGNED int)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingCount
FROM coviddeaths dea
JOIN covidvax vax
	ON dea.location = vax.location
    AND dea.date = vax.date
-- WHERE dea.location like '%canada%'
ORDER BY 2,3;



--Update '' von csv file to NULL in sql
SELECT *
FROM Portfolio_Project..Covid_Deaths
UPDATE Portfolio_Project..Covid_Deaths
SET continent = NULL
WHERE continent= ''

--select from covid deaths
SELECT *
FROM Portfolio_Project..Covid_Deaths
WHERE continent is NOT NULL
ORDER BY 2


--select Data that we are going to be using from Covid_Deaths table
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..Covid_Deaths
WHERE continent is NOT NULL
ORDER BY 1,2

--change the data type of a column Total_Deaths in Table Covid_Deaths
ALTER TABLE Portfolio_Project..Covid_Deaths
ALTER COLUMN total_deaths float

--change the data type of a column population in Table Covid_Deaths
ALTER TABLE Portfolio_Project..Covid_Deaths
ALTER COLUMN population float

--change the data type of a column total_cases in Table Covid_Deaths
ALTER TABLE Portfolio_Project..Covid_Deaths
ALTER COLUMN total_cases float

--change the data type of a column date in Table Covid_Deaths
ALTER TABLE Portfolio_Project..Covid_Deaths
ALTER COLUMN date DATE

--Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Precentage
FROM Portfolio_Project..Covid_Deaths
WHERE total_cases<>0 AND continent is NOT NULL
ORDER BY 1,2

--Shows likelihood of dying if we contract in Germany
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Precentage
FROM Portfolio_Project..Covid_Deaths
WHERE total_cases<>0 AND location like '%germ%' AND continent is NOT NULL
ORDER BY 1,2

--Looking at a total Cases vs Population
--Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Population_Precentage
FROM Portfolio_Project..Covid_Deaths
WHERE population<>0 AND continent is NOT NULL
ORDER BY 1,2

--Looking at countries with highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) As Highest_Infection_Count, MAX((total_cases/population))*100 AS Population_Infected_Precentage
FROM Portfolio_Project..Covid_Deaths
WHERE population<>0 AND continent is NOT NULL
GROUP BY location, population
ORDER BY Population_Infected_Precentage DESC

--Showing Countries with Highest Death Count per Population
SELECT location, population, MAX(total_deaths) AS Highest_Death_Count, MAX((total_deaths/population))*100 As Population_Deaths_Precentage
FROM Portfolio_Project..Covid_Deaths
WHERE population<> 0 AND continent is NOT NULL
GROUP BY location, population
ORDER BY Population_Deaths_Precentage DESC

--Showing Countries with Highest Death Count
SELECT location, MAX(total_deaths) AS Total_Deaths_Count
FROM Portfolio_Project..Covid_Deaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY Total_Deaths_Count DESC


--LET's BREAK THINGS DOWN BY CONTINENT

--Showing Continent with highest total death count
SELECT continent, MAX(total_deaths) AS Total_Deaths_Count
FROM Portfolio_Project..Covid_Deaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY Total_Deaths_Count DESC

--Showing Contintents with highest death count per population
SELECT continent, MAX(total_deaths) AS Total_Deaths_Count, MAX((total_deaths/population))*100 AS death_count_per_Population
FROM Portfolio_Project..Covid_Deaths
WHERE population<> 0 AND continent IS NOT NULL
GROUP BY continent
ORDER BY death_count_per_Population DESC


--GLOBAL NUMBERS

--Show total deaths count per total cases in each day
SELECT date, SUM(cast(new_cases as float)) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, 
SUM(cast(new_deaths as int))/SUM(cast(new_cases as float))*100 as DeathPercentage
FROM Portfolio_Project..Covid_Deaths
WHERE continent IS NOT NULL AND new_cases<>0
GROUP By date
ORDER BY 1,2

--show total deaths count per total cases
SELECT SUM(cast(new_cases as float)) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, 
SUM(cast(new_deaths as int))/SUM(cast(new_cases as float))*100 as DeathPercentage
FROM Portfolio_Project..Covid_Deaths
WHERE continent IS NOT NULL AND new_cases<>0
ORDER BY 1,2

--Vaccination

--select from covid vaccinations
SELECT *
FROM Portfolio_Project..Covid_Vaccinations
WHERE continent is NOT NULL
ORDER BY 3,4

--change the data type of a column date in Table Covid_Vaccination
ALTER TABLE Portfolio_Project..Covid_Vaccinations
ALTER COLUMN date DATE

--change the data type of a column date in Table Covid_Vaccination
ALTER TABLE Portfolio_Project..Covid_Vaccinations
ALTER COLUMN new_vaccinations float

--JOIN Death table and Vaccination table
SELECT *
FROM Portfolio_Project..Covid_Deaths DEA
JOIN Portfolio_Project..Covid_Vaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date

--Update '' von csv file to NULL in sql
SELECT *
FROM Portfolio_Project..Covid_Vaccinations
UPDATE Portfolio_Project..Covid_Vaccinations
SET new_vaccinations = NULL
WHERE new_vaccinations= ''

--Looking at Total population vs new Vaccination order by date
SELECT DEA.Continent, DEA.location, DEA.date, DEA.population, new_vaccinations
FROM Portfolio_Project..Covid_Deaths DEA
JOIN Portfolio_Project..Covid_Vaccinations VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.Continent IS NOT NULL AND new_vaccinations IS NOT NULL
ORDER BY DEA.date

--Looking at Total Population vs Vaccination
--CTE
WITH PopvsVac(continent, location, date, population, new_vaccination, Rolling_People_Vaccinated)
AS(
SELECT DEA.continent, DEA.location, DEA.date, population, new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) As Rolling_People_Vaccinated
FROM Portfolio_Project..Covid_Deaths DEA
JOIN Portfolio_Project..Covid_Vaccinations VAC
ON DEA.date = VAC.date
AND DEA.location=VAC.location
WHERE DEA.continent IS NOT NULL
)

SELECT *, Rolling_People_Vaccinated/population*100 AS Vacc_Percentage
FROM PopvsVac



--TEMP TABLE
DROP TABLE IF EXISTS #Percent_Poplation_Vaccinated
CREATE TABLE #Percent_Poplation_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_Vaccination numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #Percent_Poplation_Vaccinated
SELECT DEA.continent, DEA.location, DEA.date, population, new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) As Rolling_People_Vaccinated
FROM Portfolio_Project..Covid_Deaths DEA
JOIN Portfolio_Project..Covid_Vaccinations VAC
ON DEA.date = VAC.date
AND DEA.location=VAC.location
WHERE DEA.continent IS NOT NULL


SELECT *, Rolling_People_Vaccinated/population*100 AS Vacc_Percentage
FROM #Percent_Poplation_Vaccinated



--Creating View to store data for later Visualization
CREATE VIEW Percent_Poplation_Vaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, population, new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) As Rolling_People_Vaccinated
FROM Portfolio_Project..Covid_Deaths DEA
JOIN Portfolio_Project..Covid_Vaccinations VAC
	ON DEA.date = VAC.date
	AND DEA.location=VAC.location
WHERE DEA.continent IS NOT NULL


--Query to show the view table
SELECT *
FROM Percent_Poplation_Vaccinated

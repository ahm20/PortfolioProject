SELECT *
FROM PortfolioProject.CovidDeaths cd
where continent != ''
ORDER BY 3, 4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.CovidDeaths cd 
ORDER BY 1, 2;

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.CovidDeaths cd 
ORDER BY 1, 2;

SELECT DISTINCT location
FROM PortfolioProject.CovidDeaths;

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.CovidDeaths cd 
WHERE location like '%states%'
ORDER BY 1, 2;

SELECT location, date, total_cases, population , (total_cases/population)*100 as CasesPercentage
FROM PortfolioProject.CovidDeaths cd 
WHERE location like '%states%'
ORDER BY 1, 2;

-- Looking at countries with highest infection rate compared to populaton 

SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as CasesPercentage 
FROM PortfolioProject.CovidDeaths cd 
-- WHERE location like '%states%'
Group by location, population 
ORDER BY CasesPercentage DESC;

-- Countries with highest death counts per population

SELECT location, MAX(total_deaths) AS DeathCounts
FROM PortfolioProject.CovidDeaths cd 
where continent != ''
GROUP BY location
ORDER BY DeathCounts DESC;

-- Lets break it down by continent 

SELECT location, MAX(total_deaths) AS DeathCounts
FROM PortfolioProject.CovidDeaths cd 
where continent = ''
GROUP BY location 
ORDER BY DeathCounts DESC;

SELECT continent , MAX(total_deaths) AS DeathCounts
FROM PortfolioProject.CovidDeaths cd 
where continent != ''
GROUP BY continent  
ORDER BY DeathCounts DESC;

-- Showing the continents with the highest death count per population

SELECT continent , MAX(total_deaths) AS DeathCounts
FROM PortfolioProject.CovidDeaths cd 
where continent != ''
GROUP BY continent  
ORDER BY DeathCounts DESC;


-- GLOBAL Numbers

SELECT date, SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject.CovidDeaths cd
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

SELECT SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject.CovidDeaths cd
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2;

-- Total population vs vaccination

SELECT 
    cd.continent, 
    cd.location, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS CumulativeVaccinations, (CumulativeVaccinations/population)*100
FROM 
    PortfolioProject.CovidDeaths cd
JOIN 
    PortfolioProject.CovidVaccinations cv
    ON cd.location = cv.location 
    AND cd.date = cv.date
WHERE 
    cd.continent != ''
ORDER BY 
    2, 3;
   
-- USE CTE
   
WITH PopvsVac AS (
    SELECT 
        cd.continent, 
        cd.location, 
        cd.date, 
        cd.population, 
        cv.new_vaccinations,
        SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS CumulativeVaccinations
        -- (CumulativeVaccinations/population)*100 AS VaccinationPercentage
    FROM 
        PortfolioProject.CovidDeaths cd
    JOIN 
        PortfolioProject.CovidVaccinations cv
        ON cd.location = cv.location 
        AND cd.date = cv.date
    WHERE 
        cd.continent != ''
)
SELECT *, (CumulativeVaccinations/population)*100
FROM PopvsVac
-- ORDER BY 2, 3;

-- TEMP TABLE

-- Create regular table
CREATE TABLE IF NOT EXISTS PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    CumulativeVaccinations NUMERIC
);

-- Insert data into the table
INSERT INTO PercentPopulationVaccinated
SELECT 
    cd.continent, 
    cd.location, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS CumulativeVaccinations
FROM 
    PortfolioProject.CovidDeaths cd
JOIN 
    PortfolioProject.CovidVaccinations cv
    ON cd.location = cv.location 
    AND cd.date = cv.date
WHERE 
    cd.continent != '';
    
-- Select data from the table with the VaccinationPercentage calculation
SELECT 
    *,
    (CumulativeVaccinations/population)*100 AS VaccinationPercentage
FROM 
    PercentPopulationVaccinated;
    
-- Creating Views to store data later for visualization
   
CREATE VIEW Percent_PopulationVaccinated AS
SELECT 
    cd.continent, 
    cd.location, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS CumulativeVaccinations
FROM 
    PortfolioProject.CovidDeaths cd
JOIN 
    PortfolioProject.CovidVaccinations cv
    ON cd.location = cv.location 
    AND cd.date = cv.date
WHERE 
    cd.continent != '';
   
SELECT *
FROM Percent_PopulationVaccinated;




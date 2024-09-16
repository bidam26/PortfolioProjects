--SELECT * 
--FROM PortfolioProject.dbo.CovidDatas
--ORDER BY 3,4

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..CovidDatas
--ORDER BY location, date

-- Looking at Total Cases vs Total Deaths
-- That shows us that if you got Covid, we can see the percentage of the death senario
-- in your country.

SELECT location, date, total_cases, total_deaths, 
CASE 
	WHEN total_cases > 0 THEN (total_deaths /total_cases) * 100
	ELSE '0'
END AS Case_Death_Perc
FROM PortfolioProject..CovidDatas
WHERE location LIKE 'Turkey'
ORDER BY location, date

-- to see the percentage of the case in population in selected country

SELECT location, date, total_cases, population, 
CASE 
	WHEN total_cases > 0 THEN (total_cases/ population) * 100
	ELSE '0'
END AS Case_Popu_Perc
FROM PortfolioProject..CovidDatas
WHERE location LIKE 'Turkey'
ORDER BY location, date

-- looking at countries with highest infection rates 

SELECT location, MAX(total_cases) AS Highest_Infection , population,
MAX((total_cases/ population)) * 100 AS Popu_perc_Inf
FROM PortfolioProject..CovidDatas
GROUP BY location, population
ORDER BY Popu_perc_Inf DESC


-- looking at countries with highest death count per population

SELECT location, MAX(total_deaths) AS Total_Death_Count
FROM PortfolioProject..CovidDatas
WHERE total_deaths IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count

-- looking at continents with highest death count per population

SELECT continent, MAX(total_deaths) AS Total_Death_Count
FROM PortfolioProject..CovidDatas
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count

-- looking at global numbers

SELECT date, continent, SUM(CAST(new_cases AS INT)) AS Total_New_Cases_In_A_Day
--SUM(CAST(new_deaths AS INT)) AS Total_New_Cases_In_A_Day
FROM PortfolioProject..CovidDatas
WHERE continent IS NOT NULL
GROUP BY date, continent
ORDER BY date, continent

SELECT date, new_cases, new_deaths
FROM PortfolioProject.dbo.CovidDatas
ORDER BY date
 
 -- after searching for the problem of 0's, here is what I realize. Date datas are
 -- weekly datas. They are all written in Sundays. Thus why we cannot check daily
 -- cases and deaths. Let's check weekly datas.

SELECT date, SUM(new_cases) AS Weekly_New_Cases,
SUM(new_deaths) AS Weekly_New_Deaths,
CASE 
	WHEN SUM(new_deaths) / SUM (new_cases) * 100 > 100 THEN NULL
	ELSE SUM(new_deaths) / SUM (new_cases) * 100
END AS Death_Percentage
FROM PortfolioProject..CovidDatas
GROUP BY date
HAVING SUM(new_cases) <> 0 AND SUM(new_deaths) <> 0
ORDER BY date

-- Looking at total population and vaccinations

SELECT continent, location, date, population, new_vaccinations
FROM PortfolioProject..CovidDatas
WHERE continent IS NOT NULL
ORDER BY date, continent, location
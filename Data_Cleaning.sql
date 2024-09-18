SELECT *
FROM PortfolioProject..data_cleaning_work
WHERE country = 'Turkey'

-- 1) Remove duplicates if there any
-- 2) Stardardize the data (if there is any issues about spelling etc.)
-- 3) NULL and blank values
-- 4) Remove any columns if necessary

CREATE TABLE #temp_layoff(
Company VARCHAR (50),
Location VARCHAR (50),
Industry VARCHAR (50),
Total_Laid_Off FLOAT,
Percentage_Laid_Off VARCHAR (50),
Date DATETIME,
Stage VARCHAR (50),
Country VARCHAR (50),
Funds_Raised_Millions FLOAT
)

SELECT *
FROM #temp_layoff

INSERT #temp_layoff
SELECT *
FROM PortfolioProject..data_cleaning_work

-- -------------------------------------------------------------------------------------------
-- Checking if is there any duplicates
SELECT *,
ROW_NUMBER ()
OVER (PARTITION BY company, location, Industry, total_laid_off, percentage_laid_off ORDER BY company) AS Row_Num
FROM #temp_layoff

-- Here we checked if there any duplicates. If is there any, than Row_Num values must be > 1. 
-- When I quickly checked, I saw a few 2. Now we are going to clear them.
-- -------------------------------------------------------------------------------------------

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER ()
OVER (PARTITION BY company, location, Industry, total_laid_off, percentage_laid_off ORDER BY company) AS Row_Num
FROM #temp_layoff
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1

-- I Found the duplicates with this code. Now let's check a random company to see duplicates.

SELECT *
FROM #temp_layoff
WHERE company = 'Oda'

-- What I found here is, every column that I choose to figure out duplicates are not enough. 
-- All the variables are same where I selected column names but Country and Fund_Raised_Millions 
-- variables aren't same which means they aren't duplicate. Thus, I am going to check every column name in
-- partition by statement.

--------------------------------------------------------------------------------------------------------
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER ()
OVER (PARTITION BY company, location, Industry, total_laid_off, percentage_laid_off, 
'date', stage, country, funds_raised_millions
ORDER BY company) AS Row_Num
FROM #temp_layoff
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1


-- Now everything works well. I've checked some datas with writing WHERE company = 'company name'
-- to see if there is any mistake. 

-----------------------------------------------------------------------------------------------------------
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER ()
OVER (PARTITION BY company, location, Industry, total_laid_off, percentage_laid_off, 
'date', stage, country, funds_raised_millions
ORDER BY company) AS Row_Num
FROM #temp_layoff
)
DELETE 
FROM duplicate_cte
WHERE row_num > 1

-- With this code, I've deleted duplicates.
-------------------------------------------------------------------------------------------------
-- Now let's standardize the data.

SELECT company, TRIM(company)
FROM #temp_layoff

-- deleted any spaces around letters.

UPDATE #temp_layoff
SET Company = TRIM(company)

-------------------------------------------------------------------------------------------------
SELECT DISTINCT Industry
FROM #temp_layoff
ORDER BY 1

-- I have realized that there is one Cyrpto, Crypto Currency and CryptoCurrency values.
-- They are exact same but due to they have written different, I need to fix it.

UPDATE #temp_layoff
SET Industry = 'Crypto'
WHERE Industry LIKE 'Crypto%'

SELECT *
FROM #temp_layoff
ORDER BY Industry

-- With the code above, it is fixed.
-----------------------------------------------------------------------------------------------
--Now I am looking is there any country duplicates.

SELECT DISTINCT country
FROM #temp_layoff
ORDER BY 1

-- Here I found there are 'United States' and 'Unites States.' values. I need to fix that too.

UPDATE #temp_layoff
SET Country = 'United States'
WHERE country LIKE 'United States%'

-- Fixed with the code above.
-------------------------------------------------------------------------------------------------
-- Let's see NULL values

SELECT *
FROM #temp_layoff
WHERE Industry IS NULL
OR Industry = ''

SELECT *
FROM #temp_layoff
WHERE company = 'Airbnb'
ORDER BY Company

-- Here What I catch. There is one Airbnb company which is located to the same area but 
-- the thing is, on the second one industry missing. From here, I am guessing that 
-- this is a Airbnb company and they are located to the same area, thus they must be in the 
-- same industry which is travel. So here, I am fixing the NULL value with Travel.

SELECT T1.Industry, T2.Industry
FROM #temp_layoff T1
JOIN #temp_layoff T2
	ON t1.Company = T2.Company
WHERE T1.Industry IS NULL
AND T2.Industry IS NOT NULL

UPDATE #temp_layoff
JOIN #temp_layoff 
	ON company = company
SET Industry = Industry
WHERE Industry IS NULL
AND Industry IS NOT NULL


-- JOIN PART DIDN'T WORKED. I need to SET them. OR don't touch them because I am just GUESSING 
-- that it must be 'it'.

-- Because I think this data isn't accurate or hard to trust, I prefer to DELETE them.

SELECT *
FROM #temp_layoff
WHERE Total_Laid_Off IS NULL
AND Percentage_Laid_Off = 'NULL'

-- I have discovered something interesting here. When I deleted NULL values, there is only one row
-- affected. But when I checked the data, there are tons of rows that are NULL. I have realized that
-- Percentage_Laid_Off column is VARCHAR. So, it is written as 'NULL'. So I need to change this
-- code just a little bit.

DELETE 
FROM #temp_layoff
WHERE Total_Laid_Off IS NULL
AND Percentage_Laid_Off = 'NULL'

-- Now 348 row are affected.

-- DATA CLEANING

SELECT*
FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-- Removing Duplicates
SELECT *,
ROW_NUMBER () OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) as row_num
FROM layoffs_staging;

WITH duplicate_cte as 
(
SELECT *,
ROW_NUMBER () OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) as row_num
FROM layoffs_staging
)
SELECT *  
FROM duplicate_cte
where row_num > 1 ;


-- creating a new staging table to remove duplicates

CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` double DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging_2
SELECT *,
ROW_NUMBER () OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) as row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging_2
WHERE row_num > 1;

DELETE 
FROM layoffs_staging_2
WHERE row_num>1;

SELECT *
FROM layoffs_staging_2;

-- STANDARDIZING DATA
SELECT company, TRIM(company)
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET company = TRIM(company);

SELECT company
FROM layoffs_staging_2;

SELECT distinct (industry)
FROM layoffs_staging_2
ORDER BY 1;

SELECT *
FROM layoffs_staging_2
WHERE industry Like 'Crypto%';

UPDATE layoffs_staging_2
SET industry = 'Crypto'
where industry LIKE 'Crypto%';

SELECT distinct country 
FROM layoffs_staging_2
ORDER BY 1;

UPDATE layoffs_staging_2
SET country = TRIM(TRAILING '.' FROM country)
where country LIKE 'United States%';

SELECT `date`,
str_to_date(`date`,'%m/%d/%Y')
From layoffs_staging_2;

ALTER TABLE layoffs_staging_2
MODIFY column `date` DATE;

SELECT * 
FROM layoffs_staging_2
WHERE total_laid_off is null 
and percentage_laid_off is null;

SELECT *
FROM layoffs_staging_2
WHERE company LIKE 'Bally%';
-- nothing wrong here
SELECT *
FROM layoffs_staging_2
WHERE company LIKE 'airbnb%';


-- writing a query, that if there is another row with the same company name, it will update it to the non-null industry values
-- makes it easy so if there were thousands we wouldn't have to manually check them all

-- we should set the blanks to nulls since those are typically easier to work with
UPDATE layoffs_staging_2
SET industry = NULL
WHERE industry = '';

-- now if we check those are all null

SELECT *
FROM world_layoffs.layoffs_staging_2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- now we need to populate those nulls if possible

UPDATE layoffs_staging_2 t1
JOIN layoffs_staging_2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- and if we check it looks like Bally's was the only one without a populated row to populate this null values
SELECT *
FROM world_layoffs.layoffs_staging_2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- DELETING DATA WHICH WONT BE USEFULL FOR OUR FUTURE ANALYSIS
SELECT * 
FROM layoffs_staging_2
WHERE total_laid_off is null 
and percentage_laid_off is null;

DELETE
FROM layoffs_staging_2
WHERE total_laid_off is null 
and percentage_laid_off is null;

ALTER TABLE layoffs_staging_2
drop column row_num;

SELECT * 
FROM layoffs_staging_2;

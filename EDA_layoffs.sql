-- EXPLORATORY DATA ANALYSIS 

SELECT * 
FROM layoffs_staging_2;

SELECT MAX(total_laid_off),MAX(percentage_laid_off)
FROM layoffs_staging_2;

SELECT * 
FROM layoffs_staging_2
WHERE percentage_laid_off = 1
order by funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage,SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY stage
ORDER BY 2 DESC;

SELECT SUBSTRING(`date`,1,7) as `Month`, SUM(total_laid_off)
FROM layoffs_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month` 
ORDER BY 1 ASC;

-- Rolling total of layoffs per month

WITH ROLLING_TOTAL AS (
  SELECT 
    SUBSTRING(`date`, 1, 7) AS `Month`, 
    SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
  GROUP BY `Month`
  ORDER BY 1 ASC
)
SELECT `Month`, total_laid_off,SUM(total_laid_off) OVER (ORDER BY `Month` ASC) as rolling_total_layoffs
FROM ROLLING_TOTAL
ORDER BY `Month` ASC;

SELECT company,YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY YEAR(`date`),company
ORDER BY company;

-- Ranking companies with the most layoffs per year

WITH Company_Year AS 
(
  SELECT company, YEAR(`date`) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging_2
  GROUP BY company, YEAR(`date`)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;


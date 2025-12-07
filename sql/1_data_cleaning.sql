/**************************************************
 PROJECT 1: LAYOFFs DATA CLEANING IN MYSQL
 AUTHOR: Kartik Chelagamsetty
 DESCRIPTION:
   - Import raw data into staging
   - Remove duplicates
   - Standardize text fields
   - Fix nulls and data inconsistencies
   - Remove unnecessary Columns or Rows   
**************************************************/

-- 1. Create Database & Staging Table

CREATE DATABASE world_layoffs;
USE world_layoffs;

SELECT * FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT * FROM layoffs;

-- 2. Identify Duplicate Records

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * FROM duplicate_cte
WHERE row_num > 1;

-- 3. Create Cleanup Table With row_num

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- 4. Remove Duplicates

SELECT * FROM layoffs_staging2 WHERE row_num > 1;
DELETE FROM layoffs_staging2 WHERE row_num > 1;

-- 5. Standardize Company Names

SELECT company, TRIM(company) FROM layoffs_staging2;
UPDATE layoffs_staging2 SET company = TRIM(company);

-- 6. Standardize Industry Names
-- (Example: converting all “Crypto …” variations into “Crypto”)

SELECT DISTINCT industry FROM layoffs_staging2 WHERE industry LIKE 'Crypto%'; 
UPDATE layoffs_staging2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';

-- 7. Fix Country Formatting (e.g., United States → remove trailing .)

SELECT DISTINCT country, TRIM(TRAILING '.' FROM Country) FROM layoffs_staging2 ORDER BY 1;
UPDATE layoffs_staging2 SET country = TRIM(TRAILING '.' FROM Country) WHERE country LIKE 'United States%';

-- 8. Convert Date Column into Correct Date Format

SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y') FROM layoffs_staging2;
UPDATE layoffs_staging2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
SELECT `date` FROM layoffs_staging2;
ALTER TABLE layoffs_staging2 MODIFY COLUMN `date` DATE;

-- 9. Handle Null & Blank Values for Industry
-- Infer industry for same company

SELECT t1.company, t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON t1.company = t2.company
SET t1.industry = t2. industry WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- Again checking companies that have no values under total_laid_off & percentage_laid_off columns
SELECT *, total_laid_off, percentage_laid_off FROM layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- 10. Delete Rows With No Layoff Information

DELETE FROM layoffs_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- 11. Remove Helper Column

ALTER TABLE layoffs_staging2 DROP COLUMN row_num;

-- The Final Cleaned Table is Ready for EDA

SELECT * FROM layoffs_staging2;



--This project dives deep into the realm of data analysis using SQL and Power BI to uncover important human resource insights that can greatly benefit the company. 

/*--------------------------------------Data cleaning------------------------------*/

--converting dates to yyyy-MM-dd
UPDATE [PortofolioProject].[dbo].[HR_Data]
SET termdate = FORMAT(CONVERT(DATETIME, LEFT(termdate, 19), 120), 'yyyy-MM-dd');

--creating new column new term data
ALTER TABLE [PortofolioProject].[dbo].[HR_Data]
ADD new_termdate DATE;

---copying converted time values from termdate to new_termdate
UPDATE [PortofolioProject].[dbo].[HR_Data]
SET new_termdate = CASE
 WHEN termdate IS NOT NULL AND ISDATE(termdate) = 1 THEN CAST(termdate AS DATETIME) ELSE NULL
 END;

----create new column age 
ALTER TABLE [PortofolioProject].[dbo].[HR_Data]
ADD age nvarchar(50)

--populate new column with age
UPDATE [PortofolioProject].[dbo].[HR_Data]
SET age = DATEDIFF(YEAR, birthdate, GETDATE());


select * from [PortofolioProject].[dbo].[HR_Data]

/*-------------------------------data exploration------------------------*/

--- age distribution
SELECT
 MIN(age) AS youngest,
 MAX(age) AS OLDEST
FROM [PortofolioProject].[dbo].[HR_Data]


  
------Age group by count
  
SELECT age_group,
count(*) AS count
FROM
(SELECT 
 CASE
  WHEN age <= 21 AND age <= 30 THEN '21 to 30'
  WHEN age <= 31 AND age <= 40 THEN '31 to 40'
  WHEN age <= 41 AND age <= 50 THEN '41 to 50'
  ELSE '50+'
  END AS age_group
 FROM [PortofolioProject].[dbo].[HR_Data]
 WHERE new_termdate IS NULL
 ) AS subquery
GROUP BY age_group
ORDER BY age_group;



----------------------Age group by gender
SELECT age_group,
gender,
count(*) AS count
FROM
(SELECT 
 CASE
  WHEN age <= 21 AND age <= 30 THEN '21 to 30'
  WHEN age <= 31 AND age <= 40 THEN '31 to 40'
  WHEN age <= 41 AND age <= 50 THEN '41 to 50'
  ELSE '50+'
  END AS age_group,
  gender
 FROM [PortofolioProject].[dbo].[HR_Data]
 WHERE new_termdate IS NULL
 ) AS subquery
GROUP BY age_group, gender
ORDER BY age_group, gender;



---------------gender breakdown
SELECT
 gender,
 COUNT(gender) AS count
FROM [PortofolioProject].[dbo].[HR_Data]
WHERE new_termdate IS NULL
GROUP BY gender
ORDER BY gender ASC;



---------How does gender vary across departments and job titles?
SELECT
 department,gender,
 COUNT(gender) AS count
FROM [PortofolioProject].[dbo].[HR_Data]
WHERE new_termdate IS NULL
GROUP BY department,gender
ORDER BY department,gender ASC;



--------------------------------job titles
SELECT 
department, jobtitle,
gender,
count(gender) AS count
FROM [PortofolioProject].[dbo].[HR_Data]
WHERE new_termdate IS NULL
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle, gender ASC;



----what is race distribution in the company
	
SELECT
race,
count(*) AS count
FROM [PortofolioProject].[dbo].[HR_Data]
WHERE new_termdate IS NULL 
GROUP BY race
ORDER BY count DESC;



---average length of employment in the company

SELECT 
AVG(DATEDIFF(year, hire_date, new_termdate)) AS tenure
FROM [PortofolioProject].[dbo].[HR_Data]
WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE();



-------Which department has the highest turnover rate?
--get total count
--get terminated count
--terminated count/total count

SELECT
 department,
 total_count,
 terminated_count,
 (round((CAST(terminated_count AS FLOAT)/total_count), 2)) * 100  AS turnover_rate
 FROM
	(SELECT 
	 department,
	 count(*) AS total_count,
	 SUM(CASE
		WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0
		END
		) AS terminated_count
	FROM [PortofolioProject].[dbo].[HR_Data]
	GROUP BY department
	) AS subquery
ORDER BY turnover_rate DESC;



----- What is the tenure distribution for each department?

SELECT 
    department,
    AVG(DATEDIFF(year, hire_date, new_termdate)) AS tenure
FROM 
    [PortofolioProject].[dbo].[HR_Data]
WHERE 
    new_termdate IS NOT NULL 
    AND new_termdate <= GETDATE()
GROUP BY 
    department; 



--- How many employees work remotely for each department?

SELECT location,count(location) as count 
FROM [PortofolioProject].[dbo].[HR_Data]
WHERE new_termdate IS  NULL
group by location


  
----What's the distribution of employees across different states?

SELECT location_state,count(*) as count
FROM [PortofolioProject].[dbo].[HR_Data]
WHERE new_termdate IS  NULL
group by location_state
order by count DESC


  
 --How are job titles distributed in the company?

SELECT jobtitle,count(*) as count
FROM [PortofolioProject].[dbo].[HR_Data]
WHERE new_termdate IS  NULL
group by  jobtitle
order by jobtitle 


  
---- How have employee hire counts varied over time?
--calculate hires
--calculate terminations
--(hires-terminations)/hires percent hire change

SELECT
 hire_year,
 hires,
 terminations,
 hires - terminations AS net_change,
 (round(CAST(hires-terminations AS FLOAT)/hires, 2)) * 100 AS percent_hire_change
 FROM
		(SELECT 
	 YEAR(hire_date) AS hire_year,
	 count(*) AS hires,
	 SUM(CASE
			WHEN new_termdate is not null and new_termdate <= GETDATE() THEN 1 ELSE 0
			END
			) AS terminations
	FROM [PortofolioProject].[dbo].[HR_Data]
	GROUP BY YEAR(hire_date)
	) AS subquery
ORDER BY percent_hire_change ASC;

-- Databricks notebook source
--1.View viewership
SELECT * FROM brighttv_viewership limit 10000;

-- COMMAND ----------

--2.view profiles
SELECT * FROM brighttv_user_profiles1 LIMIT 10000;



-- COMMAND ----------

--3.Count total records
SELECT COUNT(*) AS total_viewership FROM brighttv_viewership;
SELECT COUNT(*) AS total_users FROM brighttv_user_profiles1;

-- COMMAND ----------

--4.Distinct users
SELECT COUNT(DISTINCT UserID) AS unique_users
FROM brighttv_viewership;

-- COMMAND ----------

--5.FULL OUTER JOIN
SELECT
    COALESCE(v.UserID, u.UserID) AS UserID,
    u.Name,
    u.Surname,
    u.Email,
    u.`Social Media Handle`,
    u.Gender,
    u.Race,
    u.Province,
    u.Age,
    v.Channel2,
    v.RecordDate2,
    v.`Duration 2` AS Duration
FROM brighttv_viewership v
FULL OUTER JOIN brighttv_user_profiles1 u
ON v.UserID = u.UserID;

-- COMMAND ----------

--5.1 FULL OUTER JOIN to combine viewershio and user profile data
SELECT
    COALESCE(v.UserID, u.UserID) AS UserID,
    COALESCE(NULLIF(u.Name, 'None'), 'No Name') AS Name,
    COALESCE(NULLIF(u.Surname, 'None'), 'No Surname') AS Surname,
    COALESCE(NULLIF(u.Email, 'None'), 'No Email') AS Email,
    COALESCE(NULLIF(u.`Social Media Handle`, 'None'), 'No Handle') AS Social_Handle,
    COALESCE(NULLIF(u.Gender, 'None'), 'No Gender') AS Gender,
    COALESCE(NULLIF(u.Race, 'None'), 'No Race') AS Race,
    COALESCE(NULLIF(u.Province, 'None'), 'No Province') AS Province,
    u.Age,
    v.Channel2,
    v.RecordDate2,
    v.`Duration 2` AS Duration
FROM brighttv_viewership v
FULL OUTER JOIN brighttv_user_profiles1 u
ON v.UserID = u.UserID;

-- COMMAND ----------

--6.count nulls gender
SELECT COUNT(*) AS null_race
FROM brighttv_user_profiles1
WHERE Race IS NULL;

-- COMMAND ----------

--7.count nulls province
SELECT COUNT(*) AS null_province
FROM brighttv_user_profiles1
WHERE Province IS NULL;


-- COMMAND ----------

--8.count nulls age
SELECT COUNT(*) AS null_age
FROM brighttv_user_profiles1
WHERE Age IS NULL;

-- COMMAND ----------

--9.distinct channels
SELECT DISTINCT Channel2
FROM brighttv_viewership;

-- COMMAND ----------

--10.channel count
SELECT Channel2, COUNT(*) AS total_views
FROM brighttv_viewership
GROUP BY Channel2
ORDER BY total_views DESC;

-- COMMAND ----------

--11.most watched shows(channels)
SELECT Channel2, COUNT(*) AS views
FROM brighttv_viewership
GROUP BY Channel2
ORDER BY views DESC
LIMIT 10;

-- COMMAND ----------

--12.count nulls race
SELECT COUNT(*) AS null_race
FROM brighttv_user_profiles1
WHERE Race IS NULL;

-- COMMAND ----------

--13.viewership by province
SELECT 
    COALESCE(u.Province, 'No Province') AS Province,
    COUNT(*) AS total_views
FROM brighttv_viewership v
JOIN brighttv_user_profiles1 u
ON v.UserID = u.UserID
GROUP BY COALESCE(u.Province, 'No Province')
ORDER BY total_views DESC;

-- COMMAND ----------

--14.viewership by gender
SELECT 
    COALESCE(u.Gender, 'No Gender') AS Gender,
    COUNT(*) AS total_views
FROM brighttv_viewership v
JOIN brighttv_user_profiles1 u
ON v.UserID = u.UserID
GROUP BY COALESCE(u.Gender, 'No Gender');

-- COMMAND ----------

--15.viewership by race
SELECT
    COALESCE(NULLIF(TRIM(u.Race), ''), 'No Race') AS Race,
    COUNT(*) AS total_views
FROM brighttv_viewership v
JOIN brighttv_user_profiles1 u
ON v.UserID = u.UserID
GROUP BY COALESCE(NULLIF(TRIM(u.Race), ''), 'No Race');

-- COMMAND ----------

--16. age buckets(CASE STATEMENT)
SELECT 
    CASE 
        WHEN u.Age BETWEEN 0 AND 12 THEN 'Child'
        WHEN u.Age BETWEEN 13 AND 19 THEN 'Teen'
        WHEN u.Age BETWEEN 20 AND 35 THEN 'Young Adult'
        WHEN u.Age BETWEEN 36 AND 60 THEN 'Adult'
        ELSE 'Senior'
    END AS Age_Group,
    COUNT(*) AS total_views
FROM brighttv_viewership v
JOIN brighttv_user_profiles1 u
ON v.UserID = u.UserID
GROUP BY 
    CASE 
        WHEN u.Age BETWEEN 0 AND 12 THEN 'Child'
        WHEN u.Age BETWEEN 13 AND 19 THEN 'Teen'
        WHEN u.Age BETWEEN 20 AND 35 THEN 'Young Adult'
        WHEN u.Age BETWEEN 36 AND 60 THEN 'Adult'
        ELSE 'Senior'
    END;

-- COMMAND ----------

--17.time slot analysis based on SA time
SELECT Time_Slot, COUNT(*) AS total_views
FROM (
    SELECT
          date_format(
                   COALESCE(
                          try_to_timestamp(RecordDate2, 'd/M/yyyy HH:mm'),
                          try_to_timestamp(RecordDate2, 'M/d/yyyy H:mm')
            ),
             'HH:mm'
            ) AS formatted_time,
    CASE
        WHEN formatted_time BETWEEN '06:00' AND '11:59' THEN 'Morning'
        WHEN formatted_time BETWEEN '12:00'  AND '17:59' THEN 'Afternoon'
        WHEN formatted_time BETWEEN '18:00' AND '23:59' THEN 'Evening'
        ELSE 'Midnight'
    END AS Time_Slot

    FROM brighttv_viewership 
)  t
GROUP BY Time_Slot
ORDER BY total_views DESC;

-- COMMAND ----------

--18.viewership by province + channel
SELECT 
    COALESCE(u.Province, 'No Province') AS Province,
    v.Channel2,
    COUNT(*) AS total_views
FROM brighttv_viewership v
JOIN brighttv_user_profiles1 u
ON v.UserID = u.UserID
GROUP BY COALESCE(u.Province, 'No Province'), v.Channel2;


-- COMMAND ----------

--19.average duration watched
SELECT 
    AVG(v.`Duration 2`) AS avg_duration
FROM brighttv_viewership v;

-- COMMAND ----------

--20.longest watch time
SELECT MAX(v.`Duration 2`) AS max_duration
FROM brighttv_viewership v;

-- COMMAND ----------

--21.shortest watch time
SELECT MIN(v.`Duration 2`) AS min_duration
FROM brighttv_viewership v;

-- COMMAND ----------

--22.convert to SA time
SELECT
    v.RecordDate2 AS Original_Time,
    TO_TIMESTAMP(v.RecordDate2, 'M/d/yyyy H:mm') AS Converted_Time,
    FROM_UTC_TIMESTAMP(
        TO_TIMESTAMP(v.RecordDate2, 'M/d/yyyy H:mm'),
        'Africa/Johannesburg'
    ) AS SA_Time
FROM brighttv_viewership v
LIMIT 10;

-- COMMAND ----------

--23.channels by total views
SELECT 
     v.Channel2, 
        COUNT(*) AS total_views 
  FROM brighttv_viewership v
  GROUP BY v.Channel2
  ORDER BY total_views DESC
  LIMIT 5;

-- COMMAND ----------

--final clean table combining user and viewership data
CREATE OR REPLACE TABLE brighttv_final_clean AS
SELECT
    -- User Info
    COALESCE(v.UserID, u.UserID) AS UserID,

    COALESCE(NULLIF(u.Name, 'None'), 'No Name') AS Name,
    COALESCE(NULLIF(u.Surname, 'None'), 'No Surname') AS Surname,
    COALESCE(NULLIF(u.Email, 'None'), 'No Email') AS Email,
    COALESCE(NULLIF(u.`Social Media Handle`, 'None'), 'No Handle') AS Social_Handle,

    COALESCE(NULLIF(u.Gender, 'None'), 'No Gender') AS Gender,
    COALESCE(NULLIF(u.Race, 'None'), 'No Race') AS Race,
    COALESCE(NULLIF(u.Province, 'None'), 'No Province') AS Province,

    -- Age bucket
    CASE
        WHEN u.Age BETWEEN 0 AND 12 THEN 'Child'
        WHEN u.Age BETWEEN 13 AND 19 THEN 'Teen'
        WHEN u.Age BETWEEN 20 AND 35 THEN 'Young Adult'
        WHEN u.Age BETWEEN 36 AND 60 THEN 'Adult'
        WHEN u.Age > 60 THEN 'Senior'
        ELSE 'No Age'
    END AS Age_Group,

        --Convert to SA Time
        FROM_UTC_TIMESTAMP(
            TO_TIMESTAMP(v.RecordDate2, 'M/d/yyyy H:mm'),
            'Africa/Johannesburg'
        ) AS SA_Time,

    --Time Slot based on SA Time 
    CASE
        WHEN date_format(SA_Time, 'HH:mm') BETWEEN '06:00' AND '11:59' THEN 'Morning'
        WHEN date_format(SA_Time, 'HH:mm') BETWEEN '12:00'  AND '17:59' THEN 'Afternoon'
        WHEN date_format(SA_Time, 'HH:mm') BETWEEN '18:00' AND '23:59' THEN 'Evening'
        ELSE 'Midnight'
    END AS Time_Slot,

     -- Viewership Data
    v.Channel2,
    v.RecordDate2,
    v.`Duration 2` AS duration_Watched,

  --total views 
  COUNT(*) OVER (PARTITION BY v.Channel2) AS total_views 

FROM brighttv_viewership v
LEFT JOIN brighttv_user_profiles1 u
ON v.UserID = u.UserID;

SELECT * FROM brighttv_final_clean LIMIT 10000;
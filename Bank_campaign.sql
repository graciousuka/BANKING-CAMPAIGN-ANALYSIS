CREATE DATABASE Banking_Campaign_scheme;
GO
-- Step 1: Create the database if it doesn't exist
IF NOT EXISTS (
    SELECT name FROM sys.databases WHERE name = 'Banking_Campaign_scheme'
)
BEGIN
    CREATE DATABASE Banking_Campaign_scheme;
END
GO

-- Step 2: Use the database
USE Banking_Campaign;
GO

-- Step 3: Create the table if it doesn't exist
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'Banking_Campaign'
)
BEGIN
    CREATE TABLE Banking_Campaign (
        age INT,
        job VARCHAR(50),
        marital VARCHAR(20),
        education VARCHAR(50),
        [default] VARCHAR(10),
        balance INT,
        housing VARCHAR(10),
        loan VARCHAR(10),
        contact VARCHAR(20),
        day INT,
        month VARCHAR(10),
        duration INT,
        campaign INT,
        pdays INT,
        previous INT,
        poutcome VARCHAR(20),
        y VARCHAR(5)
    );
END
GO

-- Step 4: Bulk insert my CSV 
BULK INSERT Banking_Campaign
FROM 'C:\Users\Gracious\Downloads\banking_campaign.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

--Basic Queries
--Checking the Total number of records

DECLARE @total INT;

SELECT @total = COUNT(*) 
FROM Banking_Campaign;

PRINT 'Total number of records in Banking_Campaign: ' + CAST(@total AS VARCHAR);

--Top 5 Most Common Jobs

SELECT job, COUNT(*) AS total_clients
FROM Banking_Campaign
GROUP BY job
ORDER BY total_clients DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;
--RESULT
--job and total clients
--management	969
--blue-collar	946
--technician	768
--admin.	    478
--services	    417

--EXPLANATORY DATA ANALYSIS

--📊 Demographics & Customer Profile


--What is the age distribution of clients? 

SELECT 
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        WHEN age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+'
    END AS age_group,
    COUNT(*) AS count
FROM Banking_Campaign
GROUP BY 
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        WHEN age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+'
    END
ORDER BY age_group;
-- RESULT
--age_group  count
--20-29	    478
--30-39	    1808
--40-49	    1203
--50-59	    854
--60-69	    113
--70+	    61
--Under 20	4

--What are the most common job types among clients?

SELECT job, COUNT(*) AS total_clients
FROM Banking_Campaign
GROUP BY job
ORDER BY total_clients DESC;
--RESULT
--JOB            TOTAL_CLIENTS
--management	969
--blue-collar	946
--technician	768
--admin.	    478
--services	    417
--retired	    230
--self-employed	183
--entrepreneur	168
--unemployed	128
--housemaid	    112
--student	    84
--unknown	    38

--How does marital status vary across different age groups?

SELECT 
    CASE 
        WHEN age < 30 THEN 'Under 30'
        WHEN age BETWEEN 30 AND 39 THEN '30s'
        WHEN age BETWEEN 40 AND 49 THEN '40s'
        WHEN age BETWEEN 50 AND 59 THEN '50s'
        ELSE '60+'
    END AS age_group,
    marital,
    COUNT(*) AS count
FROM Banking_Campaign
GROUP BY 
    CASE 
        WHEN age < 30 THEN 'Under 30'
        WHEN age BETWEEN 30 AND 39 THEN '30s'
        WHEN age BETWEEN 40 AND 49 THEN '40s'
        WHEN age BETWEEN 50 AND 59 THEN '50s'
        ELSE '60+'
    END,
    marital
ORDER BY age_group, marital;
--RESULT

--age_group marital  count
--30s	divorced	153
--30s	married	    1023
--30s	single	    632
--40s	divorced	177
--40s	married	    854
--40s	single	    172
--50s	divorced	157
--50s	married	    653
--50s	single	    44
--60+	divorced	28
--60+	married	    138
--60+	single	      8
--Under 30	divorced 13
--Under 30	married	129
--Under 30	single	340

--What percentage of clients have loans or housing loans?

SELECT 
    'Housing Loan' AS Loan_Type,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Banking_Campaign) AS percentage
FROM Banking_Campaign
WHERE housing = 'yes'
UNION
SELECT 
    'Personal Loan',
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Banking_Campaign)
FROM Banking_Campaign
WHERE loan = 'yes';
--RESULT
--Housing Loan	56.602521566025
--Personal Loan	15.284229152842

--What is the average balance across different education levels?

SELECT education, AVG(balance) AS avg_balance
FROM Banking_Campaign
GROUP BY education
ORDER BY avg_balance DESC;

--RESULT
--Education avg_balance
--tertiary	1775
--unknown	1701
--primary	1411
--secondary	1196

--How do job roles correlate with having a loan or not?

SELECT job, loan, COUNT(*) AS client_count
FROM Banking_Campaign
GROUP BY job, loan
ORDER BY job, loan;

--Campaign Engagement

--Distribution of Call Duration

SELECT 
    CASE 
        WHEN duration < 60 THEN 'Under 1 min'
        WHEN duration BETWEEN 60 AND 180 THEN '1-3 mins'
        WHEN duration BETWEEN 181 AND 300 THEN '3-5 mins'
        WHEN duration BETWEEN 301 AND 600 THEN '5-10 mins'
        ELSE 'Over 10 mins'
    END AS duration_group,
    COUNT(*) AS call_count
FROM Banking_Campaign
GROUP BY 
    CASE 
        WHEN duration < 60 THEN 'Under 1 min'
        WHEN duration BETWEEN 60 AND 180 THEN '1-3 mins'
        WHEN duration BETWEEN 181 AND 300 THEN '3-5 mins'
        WHEN duration BETWEEN 301 AND 600 THEN '5-10 mins'
        ELSE 'Over 10 mins'
    END
ORDER BY call_count DESC;

--RESULT
--Duration_group  call_count
--1-3 mins	        1732
--3-5 mins	        1046
--5-10 mins	        841
--Under 1 min	    480
--Over 10 mins	    422


--Average Number of Contacts per Client (campaign)

SELECT 
    AVG(CAST(campaign AS FLOAT)) AS average_contacts
FROM Banking_Campaign

--RESULT
--2.7936297279363

--Distribution of Contact Months

SELECT 
    month, COUNT(*) AS contact_count
FROM Banking_Campaign
GROUP BY month
ORDER BY contact_count DESC;

--Effect of Contact Method on Campaign Success

SELECT 
    contact, 
    y, 
    COUNT(*) AS client_count
FROM Banking_Campaign
GROUP BY contact, y
ORDER BY contact, y;

--RESUL
--CONTACT  Y  Client_count
--cellular	no	2480
--cellular	yes	416
--telephone	no	257
--telephone	yes	44
--unknown	no	1263
--unknown	yes	61

--Average Number of Days Since Last Contact (pdays)

SELECT 
    AVG(CAST(pdays AS FLOAT)) AS average_pdays
FROM Banking_Campaign
WHERE pdays <> -1;  -- Exclude clients never contacted before
--RESULT
--224.865196078431

--Day of the Month with Most Campaign Activities

SELECT 
    day, COUNT(*) AS total_contacts
FROM Banking_Campaign
GROUP BY day
ORDER BY total_contacts DESC;

--Adding the specific day of the week
SELECT 
    day,
    DATENAME(WEEKDAY, CAST('2024-01-' + RIGHT('0' + CAST(day AS VARCHAR), 2) AS DATE)) AS weekday_name,
    COUNT(*) AS total_contacts
FROM Banking_Campaign
GROUP BY day
ORDER BY total_contacts DESC;

--Campaign Performance & Outcome

--Overall Conversion Rate (y = 'yes')

SELECT 
    COUNT(CASE WHEN y = 'yes' THEN 1 END) * 100.0 / COUNT(*) AS conversion_rate_percent
FROM Banking_Campaign;

--Conversion Rates by Job, Marital Status, and Education
--a. By Job

SELECT 
    job,
    COUNT(CASE WHEN y = 'yes' THEN 1 END) * 100.0 / COUNT(*) AS conversion_rate_percent
FROM Banking_Campaign
GROUP BY job
ORDER BY conversion_rate_percent DESC;

--b. By Marital Status

SELECT 
    marital,
    COUNT(CASE WHEN y = 'yes' THEN 1 END) * 100.0 / COUNT(*) AS conversion_rate_percent
FROM Banking_Campaign
GROUP BY marital;

--c. By Education

SELECT 
    education,
    COUNT(CASE WHEN y = 'yes' THEN 1 END) * 100.0 / COUNT(*) AS conversion_rate_percent
FROM Banking_Campaign
GROUP BY education;

--Do Longer Call Durations Lead to Higher Conversion?

SELECT 
    CASE 
        WHEN duration < 60 THEN 'Under 1 min'
        WHEN duration BETWEEN 60 AND 180 THEN '1-3 mins'
        WHEN duration BETWEEN 181 AND 300 THEN '3-5 mins'
        WHEN duration BETWEEN 301 AND 600 THEN '5-10 mins'
        ELSE 'Over 10 mins'
    END AS duration_group,
    COUNT(CASE WHEN y = 'yes' THEN 1 END) * 100.0 / COUNT(*) AS conversion_rate_percent,
    COUNT(*) AS total_calls
FROM Banking_Campaign
GROUP BY 
    CASE 
        WHEN duration < 60 THEN 'Under 1 min'
        WHEN duration BETWEEN 60 AND 180 THEN '1-3 mins'
        WHEN duration BETWEEN 181 AND 300 THEN '3-5 mins'
        WHEN duration BETWEEN 301 AND 600 THEN '5-10 mins'
        ELSE 'Over 10 mins'
    END
ORDER BY duration_group;


--Impact of poutcome on Current Campaign Success

SELECT 
    poutcome,
    COUNT(*) AS total_clients,
    COUNT(CASE WHEN y = 'yes' THEN 1 END) * 100.0 / COUNT(*) AS conversion_rate_percent
FROM Banking_Campaign
GROUP BY poutcome
ORDER BY conversion_rate_percent DESC;

--Conversion Rate by Month

SELECT 
    month,
    COUNT(*) AS total_contacts,
    COUNT(CASE WHEN y = 'yes' THEN 1 END) * 100.0 / COUNT(*) AS conversion_rate_percent
FROM Banking_Campaign
GROUP BY month
ORDER BY conversion_rate_percent DESC;

--Contact Frequency: Single vs Multiple Times

SELECT 
    CASE 
        WHEN campaign = 1 THEN 'Contacted Once'
        ELSE 'Contacted Multiple Times'
    END AS contact_frequency,
    COUNT(*) AS client_count,
    COUNT(CASE WHEN y = 'yes' THEN 1 END) * 100.0 / COUNT(*) AS conversion_rate_percent
FROM Banking_Campaign
GROUP BY 
    CASE 
        WHEN campaign = 1 THEN 'Contacted Once'
        ELSE 'Contacted Multiple Times'
    END;
--RESULT
--Contact_frequency            client_count             conversion_rate_percent
--Contacted Multiple Times	   2787	                    10.082526013634
--Contacted Once	           1734	                    13.840830449826

--More analysis
--Is there a pattern in age vs. balance among those who subscribed?

SELECT 
    age, 
    AVG(balance) AS avg_balance
FROM Banking_Campaign
WHERE y = 'yes'
GROUP BY age
ORDER BY age;

--Are younger clients more likely to subscribe than older ones?

SELECT 
    CASE 
        WHEN age < 30 THEN 'Under 30'
        WHEN age BETWEEN 30 AND 39 THEN '30s'
        WHEN age BETWEEN 40 AND 49 THEN '40s'
        WHEN age BETWEEN 50 AND 59 THEN '50s'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS total_clients,
    COUNT(CASE WHEN y = 'yes' THEN 1 END) AS subscribed,
    COUNT(CASE WHEN y = 'yes' THEN 1 END) * 100.0 / COUNT(*) AS conversion_rate_percent
FROM Banking_Campaign
GROUP BY 
    CASE 
        WHEN age < 30 THEN 'Under 30'
        WHEN age BETWEEN 30 AND 39 THEN '30s'
        WHEN age BETWEEN 40 AND 49 THEN '40s'
        WHEN age BETWEEN 50 AND 59 THEN '50s'
        ELSE '60+'
    END
ORDER BY age_group;

--Is there a difference in conversion between loan holders vs. non-holders?

SELECT 
    loan,
    COUNT(*) AS total_clients,
    COUNT(CASE WHEN y = 'yes' THEN 1 END) AS subscribed,
    COUNT(CASE WHEN y = 'yes' THEN 1 END) * 100.0 / COUNT(*) AS conversion_rate_percent
FROM Banking_Campaign
GROUP BY loan;

--Which combinations of job + education produce the highest conversion?

SELECT 
    job,
    education,
    COUNT(*) AS total_clients,
    COUNT(CASE WHEN y = 'yes' THEN 1 END) AS subscribed,
    COUNT(CASE WHEN y = 'yes' THEN 1 END) * 100.0 / COUNT(*) AS conversion_rate_percent
FROM Banking_Campaign
GROUP BY job, education
ORDER BY conversion_rate_percent DESC;
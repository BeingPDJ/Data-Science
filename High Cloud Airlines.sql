use  `airline`;
show tables;
desc maindata;
select * from maindata;
-- 1.calcuate the following fields from the Year	Month (#)	Day  fields ( First Create a Date Field from Year , Month , Day fields)
--    A.Year
--    B.Monthno
--    C.Monthfullname
--    D.Quarter(Q1,Q2,Q3,Q4)
--    E. YearMonth ( YYYY-MMM)
--    F. Weekdayno
--    G.Weekdayname
--    H.FinancialMOnth
--    I. Financial Quarter 

ALTER TABLE maindata add column Date_field date;


UPDATE maindata SET Date_field = STR_TO_DATE(CONCAT("Year`", '-', "Month (#)", '-', "Day"), '%D-%m-%Y');
 


-- A.Year
select distinct year(date_field) as Year from maindata;

 -- B.Monthno
select distinct month(date_field) as month_No from maindata;

 -- C.Monthfullname
select distinct monthname(date_field) as Month_Fullname from maindata;

--  D.Quarter(Q1,Q2,Q3,Q4)
 select distinct quarter(date_field) as Quarter_ from maindata;
 
-- E. YearMonth ( YYYY-MMM)
select concat(year(date_field),"-",concat(month(datefield))) as yearMonth from maindata;

-- F. Weekdayno
select dayofweek(date_field) as Weekday_No from maindata;

-- G.Weekdayname
select dayname(date_field) as Weekday_Name from maindata;

-- H.FinancialMOnth
ALTER TABLE maindata ADD COLUMN Financial_Month VARCHAR(7);
UPDATE maindata 
SET Financial_Month = 
    CASE 
        WHEN `Month (#)` >= 4 THEN CONCAT(Year, '-', LPAD(`Month (#)`, 2, '0'))
        ELSE CONCAT(Year - 1, '-', LPAD(`Month (#)`, 2, '0'))
    END;
    
-- I. Financial Quarter 
    SELECT 
    Year, 
    `Month (#)`,
    CASE 
        WHEN `Month (#)` BETWEEN 4 AND 6 THEN 'Q1'
        WHEN `Month (#)` BETWEEN 7 AND 9 THEN 'Q2'
        WHEN `Month (#)` BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4'  -- Jan to March (Last Quarter of Financial Year)
    END AS Financial_Quarter
FROM maindata;


-- 2. Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)

-- 1.Yearly
SELECT 
    Year, 
    SUM(`# Transported Passengers`) AS Total_Passengers,
    SUM(`# Available Seats`) AS Total_Seats,
    (SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100) AS Load_Factor_Percentage
FROM maindata
GROUP BY Year
ORDER BY Year;

-- 2.Quarterly 
SELECT 
    Year, 
    CASE 
        WHEN `Month (#)` BETWEEN 4 AND 6 THEN 'Q1'
        WHEN `Month (#)` BETWEEN 7 AND 9 THEN 'Q2'
        WHEN `Month (#)` BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4' 
    END AS Financial_Quarter,
    SUM(`# Transported Passengers`) AS Total_Passengers,
    SUM(`# Available Seats`) AS Total_Seats,
    (SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100) AS Load_Factor_Percentage
FROM maindata
GROUP BY Year, Financial_Quarter
ORDER BY Year, Financial_Quarter;

-- 3.Monthly
SELECT 
    Year, 
    `Month (#)`, 
    SUM(`# Transported Passengers`) AS Total_Passengers,
    SUM(`# Available Seats`) AS Total_Seats,
    (SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100) AS Load_Factor_Percentage
FROM maindata
GROUP BY Year, `Month (#)`
ORDER BY Year, `Month (#)`;

-- 3. Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)
SELECT 
    `Carrier Name`, 
    SUM(`# Transported Passengers`) AS Total_Passengers,
    SUM(`# Available Seats`) AS Total_Seats,
    (SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100) AS Load_Factor_Percentage
FROM maindata
GROUP BY `Carrier Name`
ORDER BY Load_Factor_Percentage DESC;

-- 4. Identify Top 10 Carrier Names based passengers preference 
SELECT 
    `Carrier Name`, 
    SUM(`# Transported Passengers`) AS Total_Passengers
FROM maindata
GROUP BY `Carrier Name`
ORDER BY Total_Passengers DESC
LIMIT 10;

-- 5. Display top Routes ( from-to City) based on Number of Flights 
SELECT 
    `Origin City` AS From_City, 
    `Destination City` AS To_City, 
    COUNT(*) AS No_Of_Flights
FROM maindata
GROUP BY `Origin City`, `Destination City`
ORDER BY No_Of_Flights DESC
LIMIT 10;

-- 6. Identify the how much load factor is occupied on Weekend vs Weekdays.
SELECT 
    CASE 
        WHEN DAYOFWEEK(STR_TO_DATE(CONCAT(Year, '-', LPAD(`Month (#)`, 2, '0'), '-', LPAD(Day, 2, '0')), '%Y-%m-%d')) IN (1, 7) 
        THEN 'Weekend' 
        ELSE 'Weekday' 
    END AS DayType,
    SUM(`# Transported Passengers`) AS Total_Passengers,
    SUM(`# Available Seats`) AS Total_Seats,
    (SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100) AS Load_Factor_Percentage
FROM maindata
GROUP BY DayType;

-- 7. Identify number of flights based on Distance group
SELECT 
    CASE 
        WHEN `Distance` < 500 THEN 'Short-haul (<500 km)'
        WHEN `Distance` BETWEEN 500 AND 1500 THEN 'Medium-haul (500-1500 km)'
        WHEN `Distance` BETWEEN 1501 AND 3000 THEN 'Long-haul (1501-3000 km)'
        ELSE 'Ultra-long-haul (>3000 km)'
    END AS Distance_Group,
    COUNT(*) AS No_Of_Flights
FROM maindata
GROUP BY Distance_Group
ORDER BY NO_Of_Flights DESC;
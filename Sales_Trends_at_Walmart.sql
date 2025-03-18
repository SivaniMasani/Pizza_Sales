-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;

-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- To read Data
SELECT * FROM sales;


----------------------- Feature Engineering---------------------------------

-- Add the time_of_day column
SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

-- Add day_name column
SELECT
	date,
	DAYNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

-- Add month_name column
SELECT
	date,
	MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);


----------------------------------- PRODUCT ANALYSIS -----------------------------
-- Unique product lines
SELECT DISTINCT product_line FROM sales;

-- Most selling product line
SELECT SUM(quantity) as qty, product_line
FROM sales
GROUP BY product_line
ORDER BY qty DESC;

-- Most common payment method
SELECT payment, COUNT(*) AS payment_count
FROM sales
GROUP BY payment
ORDER BY payment_count DESC
LIMIT 1;

-- Most selling product line
SELECT product_line, count(product_line) as Most_selled FROM sales 
GROUP BY product_line
ORDER BY Most_selled DESC
LIMIT 1;

-- Total revenue by month
SELECT month_name AS Month, SUM(total) AS Total_revenue
FROM sales
GROUP BY Month_name 
ORDER BY Total_revenue;


-- Month with largest COGS
SELECT month_name AS Month, SUM(cogs) AS COGS
FROM sales
GROUP BY month_name 
ORDER BY COGS;

-- Product line with largest revenue
SELECT product_line, SUM(total) as Revenue
FROM sales
GROUP BY product_line
ORDER BY Revenue DESC
LIMIT 1;

-- City with the largest revenue
SELECT city, SUM(total) AS Revenue
FROM sales
GROUP BY city, branch 
ORDER BY Revenue;

-- Product line with largest VAT
SELECT product_line, AVG(tax_pct) as Largest_VAT
FROM sales
GROUP BY product_line
ORDER BY Largest_VAT DESC;

-- Fetching each product line and adding a column to those product line showing "Good", "Bad". Good if its greater than average sales

SELECT product_line,
	CASE
		WHEN AVG(quantity) > (SELECT AVG(quantity) FROM sales) THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- Which branch sold more products than average product sold
SELECT branch,city, SUM(quantity) AS qnty
FROM sales
GROUP BY branch,city
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- Average rating of each product line
SELECT product_line,ROUND(AVG(rating), 2) as avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

----------------------- CUSTOMER  ANALYSIS ---------------------
-- Unique customer types 
SELECT DISTINCT customer_type FROM sales;

-- Customer that buys the most
SELECT customer_type, COUNT(*)
FROM sales
GROUP BY customer_type;

-- Gender distribution per branch
SELECT branch, gender, 
COUNT(gender) AS gender_count,
ROUND(COUNT(gender) * 100.0 / SUM(COUNT(gender)) OVER (PARTITION BY branch), 2) AS percentage
FROM sales
GROUP BY branch, gender
ORDER BY branch, gender;

-- Day of the week that has the best avg ratings
SELECT day_name, AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;

-- Day of the week that has the best average ratings per branch?
SELECT branch, day_name, 
ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY branch, day_name
ORDER BY branch, avg_rating DESC;

-------------------- SALES ANALYSIS ---------------

-- Number of sales made in each time of the day per weekday 
SELECT time_of_day, COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;

-- Customer that brings the most revenue
SELECT customer_type, SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue;

-- City with largest tax/VAT percent
SELECT city, ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;




















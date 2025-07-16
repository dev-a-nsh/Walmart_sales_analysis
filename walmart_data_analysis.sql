select * from walmart;

--ABOUT DATA 
SELECT COUNT(*) FROM walmart;

--payment methods and total transactions in each method
SELECT payment_method , COUNT(invoice_id) FROM walmart GROUP BY payment_method;

--different branches we have
SELECT COUNT(DISTINCT branch) FROM walmart;

--Maximum quantity from walmart
SELECT MAX(quantity) FROM walmart;


--Business Problems 

--Q.1 Find different payment method and number of transactions, number of qty sold
SELECT DISTINCT payment_method ,COUNT(*) AS No_of_Payments , SUM(quantity) FROM walmart GROUP BY payment_method;

--Q2 Identify the highest-rated category in each branch, displaying the branch, category AVG RATING
select branch , category , Avg_Rating FROM
(SELECT branch , category , AVG(rating) AS Avg_Rating ,
  RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) desc) AS RANK FROM walmart
  GROUP BY 1,2)
  WHERE rank = 1;

-- Q.3 Identify the busiest day for each branch based on the number of transactions
SELECT branch , day_name , no_of_transactions FROM 
  (SELECT branch , TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name, COUNT(*) AS no_of_transactions ,
   RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank FROM walmart GROUP BY 1 , 2) 
WHERE RANK = 1;

 
--Q4 Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.
SELECT DISTINCT payment_method , SUM(quantity) AS Items_sold
FROM walmart GROUP BY payment_method;

--Q.5 Determine the average, minimum, and maximum rating of category for each city.List the city, average_rating, min_rating, and max_rating.
SELECT city ,category, MAX(rating) , AVG(rating) , MIN(rating) FROM walmart GROUP BY city, category;

-- Q6 Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.
SELECT category , SUM(total*profit_margin) AS total_profit FROM walmart GROUP BY category ORDER BY total_profit DESC;

-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.
WITH cte
AS
(SELECT 
	branch,
	payment_method,
	COUNT(*) as total_trans ,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*)DESC) as rank
FROM walmart 
GROUP BY 1,2)

SELECT * FROM cte WHERE rank = 1;

-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

WITH categorized_sales AS (
  SELECT 
    branch,
    CASE 
      WHEN EXTRACT(HOUR FROM time::time) < 12 THEN 'Morning'
      WHEN EXTRACT(HOUR FROM time::time) BETWEEN 12 AND 17 THEN 'Afternoon'
      ELSE 'Evening'
    END AS day_time
  FROM walmart
)
SELECT 
  branch,
  day_time,
  COUNT(*) AS invoice_count
FROM categorized_sales
GROUP BY branch, day_time
ORDER BY 
  branch,
  CASE 
    WHEN day_time = 'Morning' THEN 1
    WHEN day_time = 'Afternoon' THEN 2
    ELSE 3
  END;
 
-- #9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)
-- rdr == last_rev-cr_rev/ls_rev*100

--2022 sales for each branch
WITH revenue_2022
AS
	(SELECT branch , SUM(total) as revenue 
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) = 2022
	GROUP BY 1),

--2023 sales for each branch
revenue_2023
AS
	(SELECT branch , SUM(total) as revenue 
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) = 2023
	GROUP BY 1)
SELECT 
	ls.branch, 
	ls.revenue as last_year_revenue , 
	cs.revenue as current_year_revenue ,
	ROUND((ls.revenue - cs.revenue)::numeric/ ls.revenue::numeric* 100,2) as rev_decrease_ratio
FROM revenue_2022 as ls 
JOIN revenue_2023 as cs ON 
ls.branch = cs.branch 
WHERE ls.revenue > cs.revenue 
ORDER BY 4 DESC 
LIMIT 5;


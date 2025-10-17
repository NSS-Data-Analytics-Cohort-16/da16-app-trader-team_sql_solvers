/*
SELECT * --7197 rows
FROM app_store_apps;
*/

/*
SELECT * --10840 rows
FROM play_store_apps;
*/

/*
SELECT name, price-- app_store price has numeric format, MAX $299.99 "LAMP Words For Life"
FROM app_store_apps
ORDER BY price DESC
LIMIT 5;
*/

/*
SELECT name, price::money---- play_store price has text format, MAX $400.00 "I'm Rich - Trump Edition"
FROM play_store_apps
ORDER BY price DESC
LIMIT 5;
*/

/*

SELECT name, price 
FROM play_store_apps
WHERE name ILIKE '%Rich - Trump Edition%';
*/

WITH highest_price_cte AS (--to calculate higher of app or play store price
	SELECT
	a.name AS app_store_name,
	p.name AS play_store_name,
	COALESCE(a.price,0) :: MONEY AS app_store_price,
	p.price :: MONEY AS play_store_price,
	COALESCE(
	CASE WHEN a.price :: MONEY > p.price :: MONEY THEN a.price :: MONEY
		 WHEN a.price :: MONEY < p.price :: MONEY THEN p.price :: MONEY
	 	 WHEN a.price :: MONEY = p.price :: MONEY THEN p.price :: MONEY
		 END, 0 ::MONEY) AS highest_price
	FROM app_store_apps a
	FULL JOIN play_store_apps p
	ON a.name = p.name
	ORDER BY highest_price DESC),

purchase_price_cte AS(--multiplying highes price to 10000

SELECT 
	*,
	CASE WHEN highest_price::NUMERIC < '1' THEN 10000 
	ELSE
		ROUND(highest_price :: NUMERIC) * 10000
		END AS purchase_price-- rounding the amount to the nearest dollar
FROM highest_price_cte
ORDER BY purchase_price DESC),

--SELECT
--	*
--FROM purchase_price_cte

earnings_cte AS (
	SELECT *,
	CASE WHEN a.name = p.name THEN 10000
		 ELSE 5000
		 END AS earning_per_month
	FROM purchase_price_cte
	
		)

SELECT
	*
FROM earnings_cte
	
	
	

---------------------------------------------------------------------------------
--WHERE name IN (a.name, p.name)	--price per month 10000
--ELSE - earn price per 5000
---------------------------------------------------------------------------------
--  For every half point that an app gains in rating, its projected lifespan increases by one year. 
--In other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a
--rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to 
--last 9 years.
    
-- - App store ratings should be calculated by taking the average of the scores from both app stores
--and rounding to the nearest 0.5.

WITH combined_rating_cte AS(
	SELECT
		a.name,
		p.name,
		COALESCE(a.rating,0) AS app_store_rating,
		COALESCE(p.rating,0) AS play_store_rating
	FROM app_store_apps a
	FULL JOIN play_store_apps p
	USING (name)
		)

SELECT
	* 
FROM combined_rating_cte

---------------------------------------------------------------------------------

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
-------------------------------------------------------------------------------------------------
-- a. App Trader will purchase apps for 10,000 times the price of the app. 
--For apps that are priced from free up to $1.00, the purchase price is $10,000.
-- For example, an app that costs $2.00 will be purchased for $20,000.
-- The cost of an app is not affected by how many app stores it is on. A $1.00 app on the 
--Apple app store will cost the same as a $1.00 app on both stores. 
-- If an app is on both stores, it's purchase price will be calculated based off of the 
--highest app price between the two stores. 


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
---------------------------------------------------------------------------------
-- b. Apps earn $5000 per month, per app store it is on, from in-app advertising and in-app purchases,
--regardless of the price of the app.
-- An app that costs $200,000 will make the same per month as an app that costs $1.00. 
-- An app that is on both app stores will make $10,000 per month. 

earnings_cte AS (
	SELECT *,
			CASE 
				WHEN app_store_name IS NOT NULL AND play_store_name IS NOT NULL THEN 10000
		 		ELSE 5000
		 	END AS earning_per_month
		 FROM purchase_price_cte
			)
		
SELECT 
	*
FROM earnings_cte
	
	
---------------------------------------------------------------------------------
-- c. App Trader will spend an average of $1000 per month to market an app regardless of the price of
--the app. If App Trader owns rights to the app in both stores, it can market the app for both stores
--for a single cost of $1000 per month.
-- An app that costs $200,000 and an app that costs $1.00 will both cost $1000 a month for marketing,
--regardless of the number of stores it is in.

marketing_cost_cte AS(

)
---------------------------------------------------------------------------------
-- d. For every half point that an app gains in rating, its projected lifespan increases by one year. 
--In other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a
--rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to 
--last 9 years.
    
-- - App store ratings should be calculated by taking the average of the scores from both app stores
--and rounding to the nearest 0.5.

WITH avg_rating_cte AS(
	SELECT
		a.name,
		p.name,
		COALESCE(a.rating,0) AS app_store_rating,
		COALESCE(p.rating,0) AS play_store_rating,
		ROUND(ROUND(COALESCE(a.rating,0) + COALESCE(p.rating,0),0)/2,2) AS avg_ratings
	FROM app_store_apps a
	FULL JOIN play_store_apps p
	USING (name)
	GROUP BY a.name, p.name, a.rating, p.rating
		)

SELECT
	* 
FROM avg_rating_cte

---------------------------------------------------------------------------------
--e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same
--$1000 per month.
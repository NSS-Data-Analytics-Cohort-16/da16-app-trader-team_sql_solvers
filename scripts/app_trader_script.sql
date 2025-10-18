select * from app_store_apps
select * from play_store_apps

WITH cte1 AS (
	
	SELECT a.name AS apps_store_name,
	 		p.name AS play_store_name,
			a.price AS apps_store_price,
			p.price AS play_store_price,
			a.primary_genre AS app_genre,
			p.genres AS play_genre,
			a.content_rating AS app_content_rating,
			p.content_rating AS play_content_rating,

			-- pick the highest price
			
			GREATEST(a.price, CAST(REPLACE(TRIM(p.price), '$', '') AS NUMERIC)) AS highest_price,

			-- to find purchase price[if price <= 1 then 10000 or 10000 times the price]
			
			CASE 
				WHEN GREATEST(a.price, CAST(REPLACE(TRIM(p.price), '$', '') AS NUMERIC)) <=1 THEN 10000
				ELSE GREATEST(a.price, CAST(REPLACE(TRIM(p.price), '$', '') AS NUMERIC))*10000
			END AS purchase_price,

			-- to find store count
			
			CASE 
				WHEN a.name IS NOT NULL AND p.name IS NOT NULL THEN 2
				WHEN a.name IS NULL or p.name IS NULL THEN 1
			END AS store_count,
		
			--a.review_count AS app_review_count,
			--p.review_count AS play_review_count,
			a.rating AS app_rating,
			p.rating AS play_rating,

			--average rating across stores
			
			CASE 
				WHEN a.rating IS NOT NULL AND p.rating IS NOT NULL THEN (a.rating + p.rating)/2
				WHEN a.rating IS NULL  THEN p.rating
				ELSE a.rating
			END AS avg_rating
			
			
		
	FROM app_store_apps AS a
	FULL JOIN play_store_apps AS p
	ON a.name = p.name
	),


cte2 AS (
	SELECT 
		-- to join tow columns into one
		COALESCE (play_store_name, apps_store_name) AS app_name,
		COALESCE(app_genre,play_genre) AS genre,
		COALESCE(app_content_rating,app_content_rating) AS content_rating,
		highest_price,
		purchase_price,
		store_count,
		store_count*5000 AS monthly_earnings,
		COALESCE(ROUND(avg_rating,1),0) AS avg_rating,
		COALESCE(ROUND(ROUND(avg_rating*2)/2,1),0) AS rounded_rating,
		COALESCE(ROUND(1+ ROUND(avg_rating*2)/2/0.5),0) AS lifespan_years,
		COALESCE(ROUND(1+ ROUND(avg_rating*2)/2/0.5) *12,0) AS lifespan_years_to_month
			
	FROM cte1)

-- MAIN QUERRY

SELECT DISTINCT
 	cte2.app_name,
	cte2.genre,
	cte2.content_rating,
	cte2.highest_price,
	cte2.purchase_price,
	cte2.store_count,
	monthly_earnings,
	rounded_rating, 
	lifespan_years,
	lifespan_years_to_month*1000 AS lifetime_marketing_cost,
	lifespan_years_to_month*1000 + cte2.purchase_price AS total_amount_spent,
	lifespan_years_to_month* monthly_earnings AS lifetime_earnings,		
	(lifespan_years_to_month* monthly_earnings) - (lifespan_years_to_month*1000) - cte2.purchase_price AS profit
	
FROM cte2 
LEFT JOIN cte1
ON cte1.apps_store_name = cte2.app_name
AND cte1.play_store_name = cte2.app_name
ORDER BY profit DESC





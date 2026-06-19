#Data cleaning

UPDATE dataset.social_media_datasets
SET region = CASE 
WHEN region = 'IN' THEN 'India'
WHEN region = 'JP' THEN 'Japan'
WHEN region = 'BR' THEN 'Brasil'
WHEN region = 'CA' THEN 'Canada'
WHEN region = 'US' THEN 'United States'
WHEN region = 'UK' THEN 'United Kingdom'
END;



#text into date 

UPDATE dataset.social_media_datasets
SET post_date = NULL
WHERE TRIM(post_date) = '';

ALTER TABLE dataset.social_media_datasets
MODIFY post_date DATE;


SELECT 
     region
FROM dataset.social_media_datasets
WHERE region IS NULL;


UPDATE dataset.social_media_datasets
SET region = 'Unknown'
WHERE region IS NULL;

SELECT 
     category
FROM dataset.social_media_datasets
WHERE category IS NULL;


UPDATE dataset.social_media_datasets
SET category = 'Unknown'
WHERE category IS NULL;

#feature engineering

ALTER TABLE  dataset.social_media_datasets
ADD COLUMN campaign_type VARCHAR(50);

UPDATE dataset.social_media_datasets
SET campaign_type =
	CASE
        WHEN ad_spend < 1000 AND views > 500000 THEN 'UGC-led'
        WHEN ad_spend BETWEEN 1000 AND 10000 AND views / ad_spend > 500 THEN 'Hybrid'
        ELSE 'Paid-ad'
        END;


ALTER TABLE dataset.social_media_datasets
ADD COLUMN roas DECIMAL(10, 2);



UPDATE dataset.social_media_datasets
SET roas = ROUND(revenue / NULLIF(ad_spend, 0), 2);





ALTER TABLE dataset.social_media_datasets
ADD COLUMN ctr DECIMAL(10, 2);

UPDATE dataset.social_media_datasets
SET ctr = ROUND((clicks / NULLIF(views,0)) * 100, 2);



#Data quality check

SELECT COUNT(*) AS total_row,
        COUNT(DISTINCT video_id) AS unique_video_ids
FROM dataset.social_media_datasets;


SELECT * 
FROM dataset.social_media_datasets
WHERE views < 0
    OR likes < 0
    OR revenue < 0
    OR ad_spend < 0;
    
    
    
    
    
#Business Analysis Queries

#platform performance 

SELECT 
     platform,
     SUM(revenue) AS total_revenue,
     SUM(ad_spend) AS total_ad_spend,
     ROUND(AVG(roas),2) AS avg_roas,
     ROUND(AVG(ctr), 2) AS avg_ctr_percentage
FROM dataset.social_media_datasets
GROUP BY platform
ORDER BY total_revenue DESC;

#campaign performance

SELECT 
      campaign_type,
      SUM(revenue) AS total_revenue,
      ROUND(AVG(roas),2) AS avg_roas
FROM dataset.social_media_datasets
GROUP BY campaign_type
ORDER BY total_revenue DESC;


#category performance


SELECT 
      category,
      SUM(revenue) AS total_revenue,
      ROUND(AVG(roas), 2) AS avg_roas
FROM dataset.social_media_datasets
GROUP BY category
ORDER BY total_revenue DESC;


#monthly roas trend

SELECT 
     DATE_FORMAT(post_date,'%y - %m') AS months,
     SUM(views) AS total_views,
     SUM(revenue) AS total_revenue,
     SUM(ad_spend) AS total_ad_spend,
     ROUND(SUM(revenue) / NULLIF(SUM(ad_spend),0),2) AS roas
FROM dataset.social_media_datasets
GROUP BY  DATE_FORMAT(post_date,'%y - %m')
ORDER BY  months;


#revenue by region


SELECT 
      region,
      SUM(revenue) AS total_revenue,
      ROUND(AVG(roas), 2) AS avg_roas
FROM dataset.social_media_datasets
GROUP BY region
ORDER BY total_revenue DESC;


#top 10 campaigns by roas

SELECT 
     video_id,
     platform,
     campaign_type,
     region,
     ad_spend,
     revenue,
     roas
FROM dataset.social_media_datasets
ORDER BY roas DESC
LIMIT 10;



#funnel analysis


SELECT 
	  platform,
      SUM(views) AS total_views,
      SUM(clicks) AS total_clicks,
      SUM(total_conversion) AS total_conversion
FROM dataset.social_media_datasets
GROUP BY platform;


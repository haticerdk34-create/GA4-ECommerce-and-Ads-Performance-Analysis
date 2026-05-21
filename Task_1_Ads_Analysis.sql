SQL
-- Facebook Günlük Harcama Metrikleri
SELECT
    'facebook' AS platform,
    ROUND(AVG(spend)::numeric, 2) AS avg_daily_spend,
    ROUND(MAX(spend)::numeric, 2) AS max_daily_spend,
    ROUND(MIN(spend)::numeric, 2) AS min_daily_spend
FROM facebook_ads_basic_daily

UNION ALL

-- Google Günlük Harcama Metrikleri
SELECT
    'google' AS platform,
    ROUND(AVG(spend)::numeric, 2) AS avg_daily_spend,
    ROUND(MAX(spend)::numeric, 2) AS max_daily_spend,
    ROUND(MIN(spend)::numeric, 2) AS min_daily_spend
FROM google_ads_basic_daily;
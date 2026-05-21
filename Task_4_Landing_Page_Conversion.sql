WITH events_2020 AS (
  SELECT
    user_pseudo_id,

    (
      SELECT value.int_value
      FROM UNNEST(event_params)
      WHERE key = 'ga_session_id'
    ) AS session_id,

    event_name,

    (
      SELECT value.string_value
      FROM UNNEST(event_params)
      WHERE key = 'page_location'
    ) AS page_location

  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

  WHERE
    _TABLE_SUFFIX BETWEEN '20200101' AND '20201231'
    AND event_name IN ('session_start', 'purchase')
),

session_landing AS (
  SELECT
    user_pseudo_id,
    session_id,

    -- session_start anındaki landing page
    REGEXP_EXTRACT(
      page_location,
      r'https?://[^/]+(/[^?]*)'
    ) AS landing_page

  FROM events_2020
  WHERE event_name = 'session_start'
),

session_purchase AS (
  SELECT DISTINCT
    user_pseudo_id,
    session_id
  FROM events_2020
  WHERE event_name = 'purchase'
)

SELECT
  sl.landing_page AS page_path,
  COUNT(DISTINCT CONCAT(sl.user_pseudo_id, '-', sl.session_id)) AS unique_sessions,
  COUNT(DISTINCT CONCAT(sp.user_pseudo_id, '-', sp.session_id)) AS purchase_sessions,
  SAFE_DIVIDE(
    COUNT(DISTINCT CONCAT(sp.user_pseudo_id, '-', sp.session_id)),
    COUNT(DISTINCT CONCAT(sl.user_pseudo_id, '-', sl.session_id))
  ) AS purchase_conversion_rate

FROM session_landing sl
LEFT JOIN session_purchase sp
  ON sl.user_pseudo_id = sp.user_pseudo_id
 AND sl.session_id = sp.session_id

GROUP BY page_path
ORDER BY purchase_conversion_rate DESC;

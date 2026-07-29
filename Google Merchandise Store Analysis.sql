-- Data Exploration:

SELECT *
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210120`
LIMIT 10;

-- Data Validation: Validate marketing channel completeness.

SELECT
    COUNT(*) AS total_events,
    COUNTIF(traffic_source.medium IS NULL) AS missing_channel,
    COUNTIF(traffic_source.source = '(data deleted)') AS anonymized_source,
    COUNTIF(traffic_source.source = '<Other>') AS other_source,
    ROUND(COUNTIF(traffic_source.medium IS NULL) * 100.0 / COUNT(*), 2) AS missing_channel_percent,
    ROUND(COUNTIF(traffic_source.source IN ('(data deleted)', '<Other>')) * 100.0 / COUNT(*), 2) AS excluded_source_percent
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;

-- Data Validation: Validate key ecommerce journey events.

SELECT event_name,COUNT(*) AS total_events
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name IN ('page_view', 'view_item', 'add_to_cart', 'begin_checkout', 'purchase')
GROUP BY event_name
ORDER BY total_events DESC;

-- Data Validation: Validate customer, device, and geographic data completeness.

SELECT
    COUNT(DISTINCT user_pseudo_id) AS total_users,
    COUNTIF(user_pseudo_id IS NULL) AS missing_users,
    COUNTIF(device.category IS NULL) AS missing_device,
    COUNTIF(geo.country IS NULL) AS missing_country,
    ROUND(COUNTIF(user_pseudo_id IS NULL) * 100.0 / COUNT(*), 2) AS missing_user_percent,
    ROUND(COUNTIF(device.category IS NULL) * 100.0 / COUNT(*), 2) AS missing_device_percent,
    ROUND(COUNTIF(geo.country IS NULL) * 100.0 / COUNT(*), 2) AS missing_country_percent
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;

-- Marketing Channel Analysis:
-- Business Question 1: Which marketing channels drive the most visitors and achieve the highest purchase conversion rates?

SELECT
    CASE
        WHEN traffic_source.medium = '(none)' THEN 'Direct'
        WHEN traffic_source.medium = 'organic' THEN 'Organic Search'
        WHEN traffic_source.medium = 'referral' THEN 'Referral'
        WHEN traffic_source.medium = 'cpc' THEN 'Paid Search'
        ELSE traffic_source.medium
    END AS marketing_channel,
    COUNT(DISTINCT user_pseudo_id) AS total_visitors,
    COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) AS purchasing_users,
    ROUND(
        COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) * 100.0 /
        COUNT(DISTINCT user_pseudo_id),
        2
    ) AS conversion_rate
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE traffic_source.medium IS NOT NULL
  AND traffic_source.medium <> '<Other>'
  AND traffic_source.source NOT IN ('(data deleted)', '<Other>')
GROUP BY marketing_channel
ORDER BY conversion_rate DESC;

-- Marketing Channel Analysis
-- Business Question 2: Which marketing channels generate the highest purchase revenue?

SELECT
    CASE
        WHEN traffic_source.medium = '(none)' THEN 'Direct'
        WHEN traffic_source.medium = 'organic' THEN 'Organic Search'
        WHEN traffic_source.medium = 'referral' THEN 'Referral'
        WHEN traffic_source.medium = 'cpc' THEN 'Paid Search'
        ELSE traffic_source.medium
    END AS marketing_channel,
    COUNT(DISTINCT ecommerce.transaction_id) AS total_orders,
    ROUND(SUM(ecommerce.purchase_revenue), 2) AS total_revenue,
    ROUND(AVG(ecommerce.purchase_revenue), 2) AS average_order_value
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name = 'purchase'
  AND traffic_source.medium IS NOT NULL
  AND traffic_source.medium <> '<Other>'
  AND traffic_source.source NOT IN ('(data deleted)', '<Other>')
GROUP BY marketing_channel
ORDER BY total_revenue DESC;

-- Customer Segmentation
-- Business Question 1: Which customer segments generate the highest purchase revenue and average order value?

WITH customer_revenue AS (
SELECT
user_pseudo_id,
COUNT(*) AS total_orders,
SUM(ecommerce.purchase_revenue) AS total_revenue
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name='purchase'
AND ecommerce.purchase_revenue IS NOT NULL
GROUP BY user_pseudo_id
),
customer_segments AS (
SELECT
user_pseudo_id,
total_orders,
total_revenue,
NTILE(4) OVER(ORDER BY total_revenue DESC) AS customer_quartile
FROM customer_revenue
)
SELECT
CASE
WHEN customer_quartile=1 THEN 'High Value'
WHEN customer_quartile IN(2,3) THEN 'Medium Value'
ELSE 'Low Value'
END AS customer_segment,
COUNT(*) AS total_customers,
SUM(total_orders) AS total_orders,
ROUND(SUM(total_revenue),2) AS total_revenue,
ROUND(AVG(SAFE_DIVIDE(total_revenue,total_orders)),2) AS average_order_value
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_revenue DESC;

-- Customer Segmentation
-- Business Question 2: How do repeat customers compare with one-time customers in terms of revenue contribution and average order value?

WITH customer_orders AS (
SELECT
user_pseudo_id,
COUNT(*) AS total_orders,
SUM(ecommerce.purchase_revenue) AS total_revenue
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name='purchase'
GROUP BY user_pseudo_id
)
SELECT
CASE
WHEN total_orders=1 THEN 'One-Time Customer'
ELSE 'Repeat Customer'
END AS customer_type,
COUNT(*) AS total_customers,
SUM(total_orders) AS total_orders,
ROUND(SUM(total_revenue),2) AS total_revenue,
ROUND(AVG(total_revenue),2) AS average_revenue_per_customer
FROM customer_orders
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Product Performance
-- Business Question 1: Which products generate the highest purchase revenue and sales volume?

SELECT
item.item_name AS product_name,
SUM(item.quantity) AS items_sold,
ROUND(SUM(item.price_in_usd*item.quantity),2) AS total_revenue,
ROUND(AVG(item.price_in_usd),2) AS average_selling_price
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
UNNEST(items) AS item
WHERE event_name='purchase'
AND item.item_name IS NOT NULL
GROUP BY product_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Product Performance
-- Business Question: Which products have the highest purchase conversion rate from product views?

WITH product_events AS (
SELECT
item.item_name AS product_name,
COUNT(DISTINCT IF(event_name='view_item',user_pseudo_id,NULL)) AS product_viewers,
COUNT(DISTINCT IF(event_name='purchase',user_pseudo_id,NULL)) AS purchasing_customers
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
UNNEST(items) AS item
WHERE event_name IN('view_item','purchase')
AND item.item_name IS NOT NULL
AND item.item_name<>'(not set)'
GROUP BY product_name
)
SELECT
product_name,
product_viewers,
purchasing_customers,
ROUND(SAFE_DIVIDE(purchasing_customers,product_viewers)*100,2) AS conversion_rate
FROM product_events
WHERE product_viewers>0
ORDER BY conversion_rate DESC,purchasing_customers DESC
LIMIT 10;

-- Device Performance
-- Business Question: Which device categories generate the highest conversion rates and purchase revenue?

SELECT
device.category AS device_category,
COUNT(DISTINCT user_pseudo_id) AS total_users,
COUNT(DISTINCT IF(event_name='purchase',user_pseudo_id,NULL)) AS purchasing_customers,
ROUND(SAFE_DIVIDE(COUNT(DISTINCT IF(event_name='purchase',user_pseudo_id,NULL)),COUNT(DISTINCT user_pseudo_id))*100,2) AS conversion_rate,
ROUND(SUM(IF(event_name='purchase',ecommerce.purchase_revenue,0)),2) AS total_revenue
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE device.category IS NOT NULL
GROUP BY device_category
ORDER BY total_revenue DESC,conversion_rate DESC;

-- Customer Funnel Analysis
-- Business Question 1: Where do customers drop off in the ecommerce purchase funnel from product view to purchase?

WITH funnel_metrics AS (
SELECT
COUNT(DISTINCT IF(event_name='view_item',user_pseudo_id,NULL)) AS product_viewers,
COUNT(DISTINCT IF(event_name='add_to_cart',user_pseudo_id,NULL)) AS cart_users,
COUNT(DISTINCT IF(event_name='begin_checkout',user_pseudo_id,NULL)) AS checkout_users,
COUNT(DISTINCT IF(event_name='purchase',user_pseudo_id,NULL)) AS purchasing_customers
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
)
SELECT
product_viewers,
cart_users,
checkout_users,
purchasing_customers,
ROUND(SAFE_DIVIDE(cart_users,product_viewers)*100,2) AS view_to_cart_rate,
ROUND(SAFE_DIVIDE(checkout_users,cart_users)*100,2) AS cart_to_checkout_rate,
ROUND(SAFE_DIVIDE(purchasing_customers,checkout_users)*100,2) AS checkout_to_purchase_rate,
ROUND(SAFE_DIVIDE(purchasing_customers,product_viewers)*100,2) AS overall_conversion_rate
FROM funnel_metrics;

-- Customer Funnel Analysis
-- Business Question 2: How does the customer purchase funnel differ across device categories?

WITH device_funnel AS (
SELECT
device.category AS device_category,
COUNT(DISTINCT IF(event_name='view_item',user_pseudo_id,NULL)) AS product_viewers,
COUNT(DISTINCT IF(event_name='add_to_cart',user_pseudo_id,NULL)) AS cart_users,
COUNT(DISTINCT IF(event_name='begin_checkout',user_pseudo_id,NULL)) AS checkout_users,
COUNT(DISTINCT IF(event_name='purchase',user_pseudo_id,NULL)) AS purchasing_customers
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE device.category IS NOT NULL
GROUP BY device_category
)
SELECT
device_category,
product_viewers,
cart_users,
checkout_users,
purchasing_customers,
ROUND(SAFE_DIVIDE(cart_users,product_viewers)*100,2) AS view_to_cart_rate,
ROUND(SAFE_DIVIDE(checkout_users,cart_users)*100,2) AS cart_to_checkout_rate,
ROUND(SAFE_DIVIDE(purchasing_customers,checkout_users)*100,2) AS checkout_to_purchase_rate,
ROUND(SAFE_DIVIDE(purchasing_customers,product_viewers)*100,2) AS overall_conversion_rate
FROM device_funnel
ORDER BY overall_conversion_rate DESC,purchasing_customers DESC;

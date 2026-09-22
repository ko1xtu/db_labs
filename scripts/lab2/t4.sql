SELECT tier_name, timing_days, price, pool_included 
FROM tiers
WHERE price >= 3000.00
ORDER BY price DESC;


SELECT first_name, last_name, phone_number
FROM users
ORDER BY last_name ASC
LIMIT 3 OFFSET 1;


SELECT 
    tier_id, 
    COUNT(user_id) AS total_clients,
    SUM(visits_cnt) AS total_visits
FROM visits
WHERE subtn_active = true
GROUP BY tier_id
HAVING SUM(visits_cnt) > 5;


SELECT 
    s.sale_id,
    t.tier_name,
    t.price AS unit_price,
    s.sold_tiers AS quantity,
    (s.sold_tiers * t.price) AS sale_total_price
FROM sales_total s
INNER JOIN tiers t ON s.tier_id = t.tier_id
WHERE s.sold_tiers > 0
ORDER BY s.sale_id ASC;

SELECT 
    u.user_id, 
    u.first_name, 
    u.last_name, 
    v.tier_id, 
    v.subtn_active
FROM users u
LEFT JOIN visits v ON u.user_id = v.user_id;
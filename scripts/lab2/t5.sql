
-- Собирает полные данные о пользователе и его текущем тарифном плане с помощью JOIN
CREATE OR REPLACE VIEW user_visits_v AS
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.phone_number,
    t.tier_name,
    t.price AS tier_price,
    v.visits_cnt,
    v.subtn_active,
    v.on_hold
FROM users u
JOIN visits v ON u.user_id = v.user_id
JOIN tiers t ON v.tier_id = t.tier_id;

-- Объединяет данные о продажах с информацией о товарах и тарифных планах
CREATE OR REPLACE VIEW sales_summary_v AS
SELECT 
    s.sale_id,
    t.tier_name,
    t.price AS tier_price,
    s.sold_tiers,
    p.sale_price AS product_unit_price,
    s.sold_products,
    (s.sold_tiers * t.price + s.sold_products * p.sale_price) AS total_sale_amount
FROM sales_total s
LEFT JOIN tiers t ON s.tier_id = t.tier_id
LEFT JOIN product p ON s.product_id = p.product_id;
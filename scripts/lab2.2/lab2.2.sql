-- 1
SELECT COUNT(1) FROM users;

SELECT sum(sold_products), min(sold_products), max(sold_products), avg(sold_products)
FROM sales_total;

SELECT 
    u.user_id, 
    u.first_name, 
    u.last_name,
    STRING_AGG(t.tier_name, ', ') AS tiers, 
    AVG(v.visits_cnt) AS average_visits
FROM users u, tiers t, visits v
WHERE v.user_id = u.user_id 
  AND v.tier_id = t.tier_id
GROUP BY u.user_id, u.first_name, u.last_name 
ORDER BY average_visits ASC;

-- having
SELECT 
    u.user_id, 
    u.first_name, 
    u.last_name,
    STRING_AGG(t.tier_name, ', ') AS tiers, 
    AVG(v.visits_cnt) AS average_visits
FROM users u, tiers t, visits v
WHERE v.user_id = u.user_id 
  AND v.tier_id = t.tier_id
GROUP BY u.user_id, u.first_name, u.last_name 
HAVING AVG(v.visits_cnt) > 4
ORDER BY average_visits ASC;

-- Операторы и встроенные функции, работа с датами

-- Подзапросы и предложение with

select * from (select * from users) s;

delete from users where user_id in (select user_id from visits where visits_cnt = 5);

select first_name, last_name from users where user_id in 
(select user_id from visits where on_hold = True);

DROP TABLE IF EXISTS active_subs CASCADE;
CREATE TABLE public.active_subs (
    user_id BIGINT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    visits_cnt INT NOT NULL CHECK (visits_cnt >= 0),
    subtn_active BOOLEAN DEFAULT TRUE NOT NULL CHECK (subtn_active = TRUE),
    CONSTRAINT fk_active_subs_user FOREIGN KEY (user_id) 
        REFERENCES public.users(user_id) ON DELETE CASCADE
);


WITH active_users AS (
    SELECT DISTINCT 
        v.user_id,
        v.visits_cnt,
        v.subtn_active
    FROM public.visits v
    WHERE v.subtn_active = TRUE
)
INSERT INTO public.active_subs (user_id, first_name, last_name, visits_cnt, subtn_active)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    au.visits_cnt,
    au.subtn_active
FROM public.users u
JOIN active_users au ON u.user_id = au.user_id;

SELECT * FROM active_subs;
-- Предложение returning

UPDATE product 
SET sale_price = sale_price - 50 WHERE sale_price > 150 
RETURNING *; 



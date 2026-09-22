--ЗАДАНИЕ 3

-- 1
DELETE FROM visits 
WHERE user_id = 5 AND tier_id = 5;

-- 2
DELETE FROM sales_total 
WHERE product_id  = 5;
DELETE FROM product 
WHERE product_id = 5;

-- 4
DELETE FROM visits 
WHERE subtn_active = false AND visits_cnt = 0;

-- 5 
DELETE FROM users 
WHERE id_card_num = '567890';

SELECT * FROM users;
SELECT * FROM tiers;
SELECT * FROM product;
SELECT * FROM visits;
SELECT * FROM sales_total;

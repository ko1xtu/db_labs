--ЗАДАНИЕ 2

-- 1. Обновление номера телефона и паспорта у конкретного пользователя
UPDATE users 
SET phone_number = '+79990001122',
    id_card_num = '999999'
WHERE user_id = 1;

-- 2. Изменение цены и включение бассейна в тарифном плане
UPDATE tiers 
SET price = 2800.00,
    pool_included = true 
WHERE tier_name = 'Базовый 1 месяц';

-- 3. Изменение цены товара с определенным ID
UPDATE product 
SET sale_price = 180.00 
WHERE product_id = 1;

-- 4. Заморозка абонемента и увеличение счетчика посещений для пользователя
UPDATE visits 
SET on_hold = true,
    visits_cnt = visits_cnt + 1 
WHERE user_id = 3 AND tier_id = 2;

-- 5. Обновление количества проданных товаров и тарифов в записи продаж
UPDATE sales_total 
SET sold_products = sold_products + 10,
    sold_tiers = sold_tiers + 2 
WHERE sale_id = 1;

SELECT * FROM users;
SELECT * FROM tiers;
SELECT * FROM product;
SELECT * FROM visits;
SELECT * FROM sales_total;

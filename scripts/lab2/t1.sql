INSERT INTO users (first_name, last_name, phone_number, id_card_num) 
VALUES 
  ('Иван', 'Иванов', '+79991112233', '123456'),
  ('Алексей', 'Петров', '+79992223344', '0909'),
  ('Мария', 'Сидорова', '+79993334455', '345678'),
  ('Елена', 'Смирнова', '+79994445566', '456789'),
  ('Дмитрий', 'Кузнецов', '+79995556677', '567890');

INSERT INTO tiers (tier_name, timing_days, price, pool_included) 
VALUES 
  ('Базовый 1 месяц', 30, 2500.00, false),
  ('Стандарт 3 месяца', 90, 6500.00, true),
  ('Премиум 12 месяцев', 365, 20000.00, true),
  ('Базовый + Бассейн', 30, 3500.00, true),
  ('Разовый визит', 1, 500.00, false);

INSERT INTO product (sale_price) 
VALUES 
  (150.00),
  (200.00),
  (350.00),
  (1200.00),
  (400.00);

INSERT INTO visits (user_id, tier_id, on_hold, visits_cnt, subtn_active) 
VALUES 
  (1, 1, false, 8, true),
  (2, 3, false, 42, true),
  (3, 2, true, 12, false),
  (4, 4, false, 3, true),
  (5, 4, false, 1, false);

INSERT INTO sales_total (product_id, sold_products, tier_id, sold_tiers) 
VALUES 
  (1, 120, 1, 15),
  (2, 45, 2, 8),
  (3, 12, 3, 5),
  (4, 5, 4, 10),
  (5, 18, 4, 30);

SELECT * FROM users;
SELECT * FROM tiers;
SELECT * FROM product;
SELECT * FROM visits;
SELECT * FROM sales_total;
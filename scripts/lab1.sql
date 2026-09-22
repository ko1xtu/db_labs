CREATE DATABASE lab_db;

DROP TABLE IF EXISTS sales_total CASCADE;
DROP TABLE IF EXISTS visits CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS tiers CASCADE;
DROP TABLE IF EXISTS users CASCADE;
-- 1. Пользователи
CREATE TABLE users (
    user_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    id_card_num VARCHAR(50) NOT NULL UNIQUE
);

-- 2. Тарифные планы
CREATE TABLE tiers (
    tier_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tier_name VARCHAR(50) NOT NULL UNIQUE,
    timing_days INT NOT NULL CHECK (timing_days > 0),
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    pool_included BOOLEAN DEFAULT FALSE NOT NULL
);

-- 3. Промежуточная таблица визитов/абонементов
CREATE TABLE visits (
    user_id BIGINT NOT NULL,
    tier_id INT NOT NULL,
    on_hold BOOLEAN DEFAULT FALSE NOT NULL,
    visits_cnt INT NOT NULL,
    subtn_active BOOLEAN DEFAULT TRUE NOT NULL,
    CONSTRAINT fk_visits_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_visits_tier FOREIGN KEY (tier_id) 
        REFERENCES tiers(tier_id) ON DELETE RESTRICT
);

-- 4. Товары
CREATE TABLE product (
    product_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_price NUMERIC(10, 2) NOT NULL CHECK (sale_price >= 0)
);

-- 5. Итоговые продажи
CREATE TABLE sales_total (
    sale_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id BIGINT,
    sold_products BIGINT NOT NULL CHECK (sold_products >= 0),
    tier_id INT,
    sold_tiers BIGINT NOT NULL CHECK (sold_tiers >= 0),
    
    -- Explicit Foreign Keys required by diagram renderers:
    CONSTRAINT fk_sales_product FOREIGN KEY (product_id) 
        REFERENCES product(product_id) ON DELETE RESTRICT,
    CONSTRAINT fk_sales_tier FOREIGN KEY (tier_id) 
        REFERENCES tiers(tier_id) ON DELETE RESTRICT
);

--1
CREATE OR REPLACE FUNCTION save_users(fn VARCHAR(50), ln VARCHAR(50), pn VARCHAR(20), idc VARCHAR(50))
RETURNS BIGINT
AS $$
DECLARE
    u_id BIGINT;
BEGIN
    SELECT user_id INTO u_id FROM users WHERE id_card_num = idc;
    IF u_id IS NULL THEN
        INSERT INTO users(first_name, last_name, phone_number, id_card_num)
        VALUES (fn, ln, pn, idc)
        RETURNING user_id INTO u_id;
    ELSE
        UPDATE users
        SET
            first_name = fn,
            last_name = ln,
            phone_number = pn
        WHERE user_id = u_id;
    END IF;
    RETURN u_id;
END;
$$ LANGUAGE PLPGSQL;
--
SELECT save_users( 'Ежик', 'Соник', '+123456', 'ID-1001'); 
SELECT save_users('Стив', 'Майнкрафт', '+1234056', 'ID-10021'); 
select * from users;

--2---------
DROP FUNCTION IF EXISTS delete_tiers(INT);

CREATE OR REPLACE FUNCTION delete_tiers(_id INT)
RETURNS VOID
AS $$
BEGIN
    DELETE FROM tiers
    WHERE tier_id = _id;
EXCEPTION
    WHEN foreign_key_violation OR integrity_constraint_violation THEN
        RAISE EXCEPTION 'Невозможно выполнить удаление, так как есть внешние ссылки';
END;
$$ LANGUAGE plpgsql;

select delete_tiers(1); --err
select delete_tiers(5);
select * from tiers;
--3-----------
CREATE OR REPLACE FUNCTION min_val_product(num INT)
RETURNS SETOF product
AS $$
BEGIN
    RETURN QUERY SELECT * FROM product WHERE sale_price >= num;
END;
$$ LANGUAGE PLPGSQL;

--SELECT * FROM min_val_product(1000);
--4-----------

DROP TYPE IF EXISTS tier_info CASCADE;
CREATE TYPE tier_info AS (
    tier_name VARCHAR(50),
    timing_days INT,
    price NUMERIC(10, 2)
);

CREATE OR REPLACE FUNCTION filter_tier_info(
    arr tier_info[],
    num INT
)
RETURNS tier_info[]
AS $$
BEGIN
    RETURN ARRAY(
        SELECT (tier_name, timing_days, price)::tier_info
        FROM unnest(arr)
        WHERE price >= num
    );
END;
$$ LANGUAGE PLPGSQL;

SELECT filter_tier_info(
    ARRAY(
        SELECT (tier_name, timing_days, price)::tier_info 
        FROM tiers
    ),
    1500
);


--5
DROP TABLE IF EXISTS log_tiers CASCADE;
CREATE TABLE log_tiers (
    id BIGSERIAL PRIMARY KEY,
    tier_id INT REFERENCES tiers(tier_id),
    change_datetime TIMESTAMP DEFAULT NOW(),
    old_value NUMERIC(10, 2) DEFAULT NULL,
    new_value NUMERIC(10, 2) DEFAULT NULL
);

CREATE OR REPLACE FUNCTION trigger_function()
RETURNS TRIGGER
AS $$
DECLARE
    old_val NUMERIC(10, 2);
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        old_val := OLD.price;
    ELSIF (TG_OP = 'INSERT') THEN
        old_val := NULL;
    END IF;

    INSERT INTO log_tiers (tier_id, old_value, new_value)
    VALUES (NEW.tier_id, old_val, NEW.price);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tiers_log_trigger ON tiers;
CREATE TRIGGER tiers_log_trigger
AFTER INSERT OR UPDATE ON tiers
FOR EACH ROW
EXECUTE FUNCTION trigger_function();

-- 
INSERT INTO tiers (tier_name, timing_days, price, pool_included) VALUES ('Студенческий', 30, 1600.00, FALSE);
UPDATE tiers SET price = 1200.00 WHERE tier_id = 1;
SELECT * FROM log_tiers;

-- 6
CREATE OR REPLACE FUNCTION get_value_by_id(
    tableName VARCHAR,
    columnName VARCHAR,
    idColumn VARCHAR,
    idValue BIGINT
)
RETURNS TEXT
AS $$
DECLARE
    result TEXT;
BEGIN
    EXECUTE 'SELECT ' || quote_ident(columnName) || 
            ' FROM ' || quote_ident(tableName) || 
            ' WHERE ' || quote_ident(idColumn) || ' = $1'
    INTO result
    USING idValue;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;
--
SELECT get_value_by_id('users', 'first_name', 'user_id', 1);
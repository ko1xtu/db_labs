--  72-76, 80
EXPLAIN (ANALYZE) SELECT * FROM users;
EXPLAIN (VERBOSE) SELECT * FROM users;
EXPLAIN (COSTS) SELECT * FROM users;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM users;
EXPLAIN (ANALYZE, TIMING) SELECT * FROM users;

-- 77-79
EXPLAIN (FORMAT XML) 
SELECT * FROM users u 
JOIN visits v ON u.user_id = v.user_id;

EXPLAIN (FORMAT JSON) 
SELECT * FROM users u 
JOIN visits v ON u.user_id = v.user_id;

EXPLAIN (FORMAT YAML) 
SELECT * FROM users u 
JOIN visits v ON u.user_id = v.user_id;

EXPLAIN (TIMING OFF) SELECT * FROM users;

EXPLAIN INSERT INTO product (sale_price) VALUES (420.00);

-- 82-85
EXPLAIN (FORMAT JSON) SELECT * FROM users;


EXPLAIN (FORMAT JSON) SELECT * FROM users WHERE user_id = 2;


EXPLAIN (FORMAT JSON) SELECT user_id FROM users WHERE user_id = 2;

EXPLAIN (FORMAT JSON) SELECT * FROM product WHERE sale_price > 150;

-- (Examples 86-88)

SET enable_mergejoin = OFF;
SET enable_hashjoin = OFF;
EXPLAIN (FORMAT JSON) 
SELECT * FROM users u 
JOIN visits v ON u.user_id = v.user_id;


SET enable_hashjoin = ON;
EXPLAIN (FORMAT JSON) 
SELECT * FROM users u 
JOIN visits v ON u.user_id = v.user_id;

SET enable_mergejoin = ON;
SET enable_hashjoin = OFF;
EXPLAIN (FORMAT JSON) 
SELECT * FROM users u 
JOIN visits v ON u.user_id = v.user_id;

RESET enable_mergejoin;
RESET enable_hashjoin;

-- ============================================================
-- MY ANSWERS — fill in your solution under each numbered header.
-- Keep the "-- N" markers exactly as-is (one query per number) —
-- run_tests.py splits the file on these to run each answer.
-- Written for SQLite (what's runnable locally). See SQLITE_NOTES.md
-- for swaps if you're copying patterns from answers.sql (Postgres).
-- ============================================================

-- 1
SELECT * FROM customers WHERE country = 'Canada';

-- 2
SELECT * FROM products WHERE unit_price > 50 ORDER BY unit_price DESC;

-- 3
SELECT * FROM customers ORDER BY signup_date DESC LIMIT 5;

-- 4
SELECT * FROM orders WHERE status = 'cancelled';

-- 5
SELECT * FROM products WHERE product_name LIKE '%Headphones%';

-- 6
SELECT * FROM employees WHERE hire_date < '2020-01-01';

-- 7
SELECT DISTINCT country FROM customers;

-- 8
SELECT * FROM products WHERE discontinued = TRUE AND stock_quantity > 0;

-- 9
SELECT country, COUNT() AS num_customers FROM customers GROUP BY country ORDER BY num_customers DESC;

-- 10
SELECT product_id, SUM( quantity ) AS num_products FROM order_items GROUP BY product_id ORDER BY num_products DESC;

-- 11
SELECT c.category_name, AVG( p.unit_price ) AS avg_price FROM products p JOIN categories c ON p.category_id = c.category_id GROUP BY c.category_name;

-- 12
SELECT category_id, COUNT(*) AS num_products FROM products GROUP BY category_id HAVING COUNT(*) > 3;

-- 13
SELECT order_id, SUM( quantity * unit_price ) AS total_sales FROM order_items GROUP BY order_id;

-- 14
SELECT customer_id, COUNT(*) AS num_orders FROM orders GROUP BY customer_id HAVING COUNT(*) >= 2;

-- 15
SELECT o.employee_id, AVG(oi_totals.order_total) AS avg_order_value FROM orders o JOIN ( SELECT order_id, SUM(quantity * unit_price * (1 - discount)) AS order_total FROM order_items GROUP BY order_id) oi_totals ON oi_totals.order_id = o.order_id GROUP BY o.employee_id;

-- 16
SELECT c.category_id, MIN( unit_price ) AS min_price, MAX( unit_price ) AS max_price, AVG( unit_price ) AS avg_price FROM categories c JOIN products p ON c.category_id = p.category_id GROUP BY c.category_id;

-- 17
SELECT product_id, COUNT(*) AS num_reviews FROM reviews GROUP BY product_id ORDER BY rating DESC;

-- 18
SELECT product_id, AVG(rating) AS avg_rating FROM reviews GROUP BY product_id HAVING AVG(rating) < 3;

-- 19
SELECT o.order_id, c.first_name, c.last_name, o.order_date FROM orders o JOIN customers c ON o.customer_id = c.customer_id GROUP BY o.order_id, c.first_name, c.last_name;

-- 20
SELECT oi.order_item_id, p.product_name, cat.category_name FROM order_items oi JOIN products p ON p.product_id = oi.product_id JOIN categories cat ON cat.category_id = p.category_id;

-- 21
SELECT c.customer_id, c.first_name, c.last_name FROM customers c LEFT JOIN orders o ON o.customer_id = c.customer_id WHERE o.order_id IS NULL;

-- 22
SELECT p.product_id, p.product_name FROM products p LEFT JOIN order_items oi ON oi.product_id = p.product_id WHERE oi.product_id IS NULL;

-- 23 
SELECT o.order_id, e.first_name, e.last_name, e.department FROM orders o JOIN employees e ON e.employee_id = o.employee_id;

-- 24
SELECT r.review_id, c.first_name, c.last_name, p.product_name, r.rating FROM reviews r JOIN products p ON r.product_id = p.product_id JOIN customers c ON c.customer_id = r.customer_id;

-- 25
SELECT c.customer_id, c.first_name, c.last_name, ref.first_name AS referred_by_first_name FROM customers c LEFT JOIN customers ref ON ref.customer_id = c.referred_by;

-- 26
SELECT c.employee_id, c.first_name, c.last_name, ref.first_name AS manager_first_name FROM employees c LEFT JOIN employees ref ON ref.employee_id = c.manager_id;

-- 27
SELECT a.customer_id, b.customer_id, a.city FROM customers a JOIN customers b ON b.city = a.city AND a.customer_id < b.customer_id;

-- 28
SELECT oi.order_id FROM order_items oi JOIN products p ON p.product_id = oi.product_id GROUP BY oi.order_id HAVING COUNT( DISTINCT p.category_id ) > 1;

-- 29
WITH spend AS (
    SELECT o.customer_id, SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS total_spend
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.customer_id
)
SELECT * FROM spend
WHERE total_spend > (SELECT AVG(total_spend) FROM spend);

-- 30
SELECT product_id, SUM( quantity * unit_price ) AS revenue FROM order_items GROUP BY product_id HAVING SUM( quantity * unit_price ) = ( SELECT MAX( rev ) FROM ( SELECT SUM( quantity * unit_price ) AS rev FROM order_items GROUP BY product_id ) sub );

-- 31
WITH total_revenue_customer AS ( SELECT o.customer_id, SUM( oi.quantity * oi.unit_price * ( 1 - oi.discount ) ) AS revenue FROM orders o JOIN order_items oi ON oi.order_id = o.order_id GROUP BY o.customer_id ) SELECT * FROM total_revenue_customer WHERE revenue > 200;

-- 32


-- 33


-- 34


-- 35


-- 36


-- 37


-- 38


-- 39


-- 40


-- 41


-- 42


-- 43


-- 44


-- 45


-- 46


-- 47


-- 48


-- 49


-- 50


-- 51


-- 52


-- 53


-- 54


-- 55


-- 56


-- 57


-- 58


-- 59


-- 60


-- 61


-- 62


-- 63


-- 64


-- 65


-- 66


-- 67


-- 68


-- 69


-- 70


-- 71


-- 72


-- 73


-- 74


-- 75


-- 76


-- 77


-- 78


-- 79


-- 80


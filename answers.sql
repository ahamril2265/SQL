-- ============================================================
-- Answer key for questions.md — NorthStar Retail dataset
-- Written for PostgreSQL syntax; minor tweaks needed for
-- MySQL (no FULL OUTER JOIN, use LIMIT/OFFSET differently for #33)
-- or SQLite (no RIGHT/FULL JOIN either).
-- ============================================================

-- ===== SECTION 1: SELECT / WHERE / ORDER BY / LIMIT =====

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


-- ===== SECTION 2: Aggregation =====

-- 9
SELECT country, COUNT(*) AS num_customers
FROM customers
GROUP BY country
ORDER BY num_customers DESC;

-- 10
SELECT product_id, SUM(quantity) AS total_qty_sold
FROM order_items
GROUP BY product_id
ORDER BY total_qty_sold DESC;

-- 11
SELECT c.category_name, AVG(p.unit_price) AS avg_price
FROM products p
JOIN categories c ON c.category_id = p.category_id
GROUP BY c.category_name;

-- 12
SELECT category_id, COUNT(*) AS num_products
FROM products
GROUP BY category_id
HAVING COUNT(*) > 3;

-- 13
SELECT order_id, SUM(quantity * unit_price) AS total_revenue
FROM order_items
GROUP BY order_id
ORDER BY order_id;

-- 14
SELECT customer_id, COUNT(*) AS num_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(*) >= 2
ORDER BY num_orders DESC;

-- 15
SELECT o.employee_id, AVG(oi_totals.order_total) AS avg_order_value
FROM orders o
JOIN (
    SELECT order_id, SUM(quantity * unit_price * (1 - discount)) AS order_total
    FROM order_items
    GROUP BY order_id
) oi_totals ON oi_totals.order_id = o.order_id
GROUP BY o.employee_id;

-- 16
SELECT category_id, MIN(unit_price) AS min_price, MAX(unit_price) AS max_price, AVG(unit_price) AS avg_price
FROM products
GROUP BY category_id;

-- 17
SELECT product_id, COUNT(*) AS num_reviews
FROM reviews
GROUP BY product_id
ORDER BY num_reviews DESC;

-- 18
SELECT product_id, AVG(rating) AS avg_rating
FROM reviews
WHERE rating IS NOT NULL
GROUP BY product_id
HAVING AVG(rating) < 3;


-- ===== SECTION 3: JOINs =====

-- 19
SELECT o.order_id, c.first_name, c.last_name, o.order_date
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id;

-- 20
SELECT oi.order_item_id, p.product_name, cat.category_name
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN categories cat ON cat.category_id = p.category_id;

-- 21
SELECT c.customer_id, c.first_name, c.last_name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- 22
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.order_item_id IS NULL;

-- 23
SELECT o.order_id, e.first_name, e.last_name, e.department
FROM orders o
JOIN employees e ON e.employee_id = o.employee_id;

-- 24
SELECT r.review_id, c.first_name, c.last_name, p.product_name, r.rating
FROM reviews r
JOIN customers c ON c.customer_id = r.customer_id
JOIN products p ON p.product_id = r.product_id;

-- 25
SELECT c.customer_id, c.first_name, c.last_name, ref.first_name AS referred_by_first_name
FROM customers c
LEFT JOIN customers ref ON ref.customer_id = c.referred_by;

-- 26
SELECT e.employee_id, e.first_name, e.last_name, m.first_name AS manager_first_name
FROM employees e
LEFT JOIN employees m ON m.employee_id = e.manager_id;

-- 27
SELECT a.customer_id AS customer_a, b.customer_id AS customer_b, a.city
FROM customers a
JOIN customers b ON a.city = b.city AND a.customer_id < b.customer_id;

-- 28
SELECT oi.order_id
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY oi.order_id
HAVING COUNT(DISTINCT p.category_id) > 1;


-- ===== SECTION 4: Subqueries & CTEs =====

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
SELECT product_id, SUM(quantity * unit_price) AS revenue
FROM order_items
GROUP BY product_id
HAVING SUM(quantity * unit_price) = (
    SELECT MAX(rev) FROM (
        SELECT SUM(quantity * unit_price) AS rev
        FROM order_items
        GROUP BY product_id
    ) sub
);

-- 31
WITH customer_revenue AS (
    SELECT o.customer_id, SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS total_revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.customer_id
)
SELECT * FROM customer_revenue WHERE total_revenue > 200;

-- 32
SELECT e.*
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department = e.department
);

-- 33
SELECT MAX(unit_price) AS second_highest
FROM products
WHERE unit_price < (SELECT MAX(unit_price) FROM products);

-- 34
WITH product_sales AS (
    SELECT p.category_id, p.product_id, SUM(oi.quantity) AS total_units
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    GROUP BY p.category_id, p.product_id
)
SELECT *, RANK() OVER (PARTITION BY category_id ORDER BY total_units DESC) AS rank_in_category
FROM product_sales;

-- 35
WITH last_orders AS (
    SELECT customer_id, order_id, status,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rn
    FROM orders
)
SELECT customer_id, order_id, status
FROM last_orders
WHERE rn = 1 AND status = 'cancelled';

-- 36
WITH product_avg AS (
    SELECT product_id, AVG(rating) AS avg_rating
    FROM reviews
    WHERE rating IS NOT NULL
    GROUP BY product_id
)
SELECT * FROM product_avg
WHERE avg_rating > (SELECT AVG(rating) FROM reviews WHERE rating IS NOT NULL);


-- ===== SECTION 5: Window Functions =====

-- 37
WITH spend AS (
    SELECT o.customer_id, SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS total_spend
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.customer_id
)
SELECT customer_id, total_spend,
       RANK() OVER (ORDER BY total_spend DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY total_spend DESC) AS dense_rnk
FROM spend;

-- 38
SELECT customer_id, order_id, order_date,
       LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date
FROM orders;

-- 39
WITH order_revenue AS (
    SELECT o.customer_id, o.order_id, o.order_date,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS order_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.customer_id, o.order_id, o.order_date
)
SELECT *, SUM(order_total) OVER (PARTITION BY customer_id ORDER BY order_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM order_revenue
ORDER BY customer_id, order_date;

-- 40
WITH ranked AS (
    SELECT p.*, ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY unit_price DESC) AS rn
    FROM products p
)
SELECT * FROM ranked WHERE rn <= 2;

-- 41
WITH order_revenue AS (
    SELECT o.customer_id, o.order_id, o.order_date,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS order_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.customer_id, o.order_id, o.order_date
)
SELECT *, AVG(order_total) OVER (PARTITION BY customer_id ORDER BY order_date
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3
FROM order_revenue
ORDER BY customer_id, order_date;

-- 42
SELECT product_id, category_id, unit_price,
       unit_price - AVG(unit_price) OVER (PARTITION BY category_id) AS diff_from_category_avg
FROM products;

-- 43
WITH order_revenue AS (
    SELECT order_id, SUM(quantity * unit_price * (1 - discount)) AS order_total
    FROM order_items
    GROUP BY order_id
)
SELECT *, NTILE(4) OVER (ORDER BY order_total) AS revenue_quartile
FROM order_revenue;

-- 44
SELECT employee_id, order_id, order_date,
       order_date - LAG(order_date) OVER (PARTITION BY employee_id ORDER BY order_date) AS days_since_previous
FROM orders;


-- ===== SECTION 6: Dates & Time Intelligence =====

-- 45
SELECT order_id, ship_date - order_date AS days_to_ship
FROM orders
WHERE status = 'completed' AND ship_date IS NOT NULL;

-- 46
SELECT DATE_TRUNC('month', o.order_date) AS month, SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY month
ORDER BY revenue DESC
LIMIT 1;

-- 47
WITH monthly AS (
    SELECT DATE_TRUNC('month', o.order_date) AS month,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY month
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month), 2) AS mom_growth_pct
FROM monthly
ORDER BY month;

-- 48
WITH first_orders AS (
    SELECT customer_id, MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
)
SELECT c.customer_id, c.signup_date, f.first_order_date
FROM customers c
JOIN first_orders f ON f.customer_id = c.customer_id
WHERE DATE_TRUNC('month', c.signup_date) = DATE_TRUNC('month', f.first_order_date);

-- 49
SELECT order_id, order_date, ship_date, ship_date - order_date AS days_to_ship
FROM orders
WHERE ship_date IS NOT NULL AND ship_date - order_date > 5;

-- 50
SELECT employee_id, AVG(ship_date - order_date) AS avg_shipping_delay
FROM orders
WHERE ship_date IS NOT NULL
GROUP BY employee_id;

-- 51
SELECT DATE_TRUNC('month', signup_date) AS signup_month, COUNT(*) AS new_customers
FROM customers
WHERE EXTRACT(YEAR FROM signup_date) = 2022
GROUP BY signup_month
ORDER BY signup_month;

-- 52
SELECT TO_CHAR(order_date, 'Day') AS day_of_week, COUNT(*) AS num_orders
FROM orders
GROUP BY day_of_week
ORDER BY num_orders DESC;


-- ===== SECTION 7: String & Conditional Logic =====

-- 53
SELECT customer_id, first_name || ' ' || last_name AS full_name
FROM customers;

-- 54
SELECT customer_id, email, SUBSTRING(email FROM POSITION('@' IN email) + 1) AS email_domain
FROM customers;

-- 55
SELECT product_id, product_name, unit_price,
       CASE
           WHEN unit_price < 30 THEN 'Budget'
           WHEN unit_price BETWEEN 30 AND 100 THEN 'Mid-range'
           ELSE 'Premium'
       END AS price_tier
FROM products;

-- 56
SELECT * FROM customers WHERE email NOT LIKE '%@mail.com';

-- 57
SELECT customer_id, UPPER(TRIM(city)) AS city_clean
FROM customers;

-- 58
SELECT
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_count,
    SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_count,
    SUM(CASE WHEN status = 'returned' THEN 1 ELSE 0 END) AS returned_count
FROM orders;


-- ===== SECTION 8: Set Operations & Data Quality =====

-- 59
SELECT DISTINCT oi.product_id
FROM order_items oi
LEFT JOIN products p ON p.product_id = oi.product_id
WHERE p.product_id IS NULL;

-- 60
SELECT DISTINCT city FROM customers
UNION
SELECT 'Headquarters' AS city;

-- 61
SELECT customer_id, product_id, review_date, COUNT(*)
FROM reviews
GROUP BY customer_id, product_id, review_date
HAVING COUNT(*) > 1;

-- 62
SELECT DISTINCT c.customer_id
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN reviews r ON r.customer_id = c.customer_id;

-- 63
SELECT DISTINCT o.customer_id
FROM orders o
WHERE o.customer_id NOT IN (SELECT customer_id FROM reviews);

-- 64
SELECT oi.*
FROM order_items oi
LEFT JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_id IS NULL;


-- ===== SECTION 9: Views, Indexes, Schema Reasoning =====

-- 65
CREATE VIEW order_summary AS
SELECT o.order_id,
       c.first_name || ' ' || c.last_name AS customer_name,
       o.order_date,
       SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS total_revenue,
       COUNT(oi.order_item_id) AS item_count
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, customer_name, o.order_date;

-- 66
-- To speed up "find all orders for a customer in a date range", index the
-- foreign key + filter column together since both are used in WHERE:
CREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date);

-- 67
-- SELECT * FROM orders WHERE customer_id = 3 AND order_date BETWEEN '2022-01-01' AND '2022-06-30';
-- A composite index on (customer_id, order_date) lets the engine seek directly
-- to the customer's rows and then range-scan by date, avoiding a full table scan.
-- Column order matters: the equality column (customer_id) should lead the range column (order_date).

-- 68
-- Example: rewriting Q32 (correlated subquery) as a JOIN with a pre-aggregated CTE.
WITH dept_avg AS (
    SELECT department, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department
)
SELECT e.*
FROM employees e
JOIN dept_avg d ON d.department = e.department
WHERE e.salary > d.avg_salary;
-- Tradeoff: the correlated subquery re-runs the aggregate once per outer row
-- (O(n*m) in a naive planner); the CTE/JOIN version aggregates once and joins,
-- which most optimizers execute more efficiently on larger tables.


-- ===== SECTION 10: Business / Analytics Scenarios =====

-- 69
WITH clv AS (
    SELECT o.customer_id, SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS lifetime_value
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status != 'cancelled'
    GROUP BY o.customer_id
)
SELECT *, RANK() OVER (ORDER BY lifetime_value DESC) AS clv_rank
FROM clv;

-- 70
WITH customer_revenue AS (
    SELECT c.customer_id, c.country,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS revenue
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY c.customer_id, c.country
),
ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY country ORDER BY revenue DESC) AS rn
    FROM customer_revenue
)
SELECT * FROM ranked WHERE rn <= 3;

-- 71
WITH jan AS (
    SELECT DISTINCT customer_id FROM orders
    WHERE order_date BETWEEN '2022-01-01' AND '2022-01-31'
),
feb AS (
    SELECT DISTINCT customer_id FROM orders
    WHERE order_date BETWEEN '2022-02-01' AND '2022-02-28'
)
SELECT
    COUNT(DISTINCT j.customer_id) AS jan_customers,
    COUNT(DISTINCT f.customer_id) AS retained_in_feb,
    ROUND(100.0 * COUNT(DISTINCT f.customer_id) / NULLIF(COUNT(DISTINCT j.customer_id), 0), 2) AS retention_pct
FROM jan j
LEFT JOIN feb f ON f.customer_id = j.customer_id;

-- 72
SELECT a.product_id AS product_a, b.product_id AS product_b, COUNT(*) AS times_bought_together
FROM order_items a
JOIN order_items b ON a.order_id = b.order_id AND a.product_id < b.product_id
GROUP BY a.product_id, b.product_id
HAVING COUNT(*) >= 2
ORDER BY times_bought_together DESC;

-- 73
WITH last_order AS (
    SELECT customer_id, MAX(order_date) AS last_order_date
    FROM orders
    GROUP BY customer_id
),
dataset_max AS (
    SELECT MAX(order_date) AS max_date FROM orders
)
SELECT l.customer_id, l.last_order_date
FROM last_order l, dataset_max d
WHERE d.max_date - l.last_order_date > 60;

-- 74
WITH cohorts AS (
    SELECT customer_id, DATE_TRUNC('month', signup_date) AS cohort_month
    FROM customers
),
order_months AS (
    SELECT o.customer_id, DATE_TRUNC('month', o.order_date) AS order_month
    FROM orders o
)
SELECT c.cohort_month, om.order_month, COUNT(DISTINCT om.customer_id) AS active_customers
FROM cohorts c
JOIN order_months om ON om.customer_id = c.customer_id
GROUP BY c.cohort_month, om.order_month
ORDER BY c.cohort_month, om.order_month;

-- 75
WITH emp_discount AS (
    SELECT o.employee_id, AVG(oi.discount) AS avg_discount
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.employee_id
)
SELECT *,
       avg_discount > (SELECT AVG(discount) FROM order_items) AS above_company_avg
FROM emp_discount;

-- 76
SELECT c.category_id, c.category_name,
       SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS revenue,
       SUM(p.stock_quantity) AS total_stock,
       SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) / NULLIF(SUM(p.stock_quantity), 0) AS revenue_per_stock_unit
FROM categories c
JOIN products p ON p.category_id = c.category_id
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY c.category_id, c.category_name
ORDER BY revenue_per_stock_unit DESC;

-- 77
WITH referred_revenue AS (
    SELECT c.referred_by, SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) AS revenue_generated
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE c.referred_by IS NOT NULL
    GROUP BY c.referred_by
)
SELECT ref.customer_id AS referrer_id, ref.first_name AS referrer_name, rr.revenue_generated
FROM referred_revenue rr
JOIN customers ref ON ref.customer_id = rr.referred_by;

-- 78
SELECT
    o.employee_id,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN o.status IN ('cancelled','returned') THEN 1 ELSE 0 END) AS bad_orders,
    ROUND(100.0 * SUM(CASE WHEN o.status IN ('cancelled','returned') THEN 1 ELSE 0 END) / COUNT(*), 2) AS bad_order_pct
FROM orders o
GROUP BY o.employee_id
UNION ALL
SELECT NULL,
       COUNT(*),
       SUM(CASE WHEN status IN ('cancelled','returned') THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN status IN ('cancelled','returned') THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM orders;

-- 79
WITH emp_stats AS (
    SELECT o.employee_id,
           COUNT(*) AS order_count,
           AVG(oi_totals.order_total) AS avg_order_value
    FROM orders o
    JOIN (
        SELECT order_id, SUM(quantity * unit_price * (1 - discount)) AS order_total
        FROM order_items
        GROUP BY order_id
    ) oi_totals ON oi_totals.order_id = o.order_id
    GROUP BY o.employee_id
)
SELECT *
FROM emp_stats
WHERE order_count < (SELECT AVG(order_count) FROM emp_stats)
  AND avg_order_value < (SELECT AVG(avg_order_value) FROM emp_stats);

-- 80
-- Design: "active" customer for a month = has >=1 order with status = 'completed'
-- in that month. Compute distinct active customers per month, then compare to
-- the prior month using LAG for MoM change.
WITH active_monthly AS (
    SELECT DATE_TRUNC('month', order_date) AS month, COUNT(DISTINCT customer_id) AS active_customers
    FROM orders
    WHERE status = 'completed'
    GROUP BY month
)
SELECT month, active_customers,
       LAG(active_customers) OVER (ORDER BY month) AS prev_month_active,
       active_customers - LAG(active_customers) OVER (ORDER BY month) AS mom_change
FROM active_monthly
ORDER BY month;

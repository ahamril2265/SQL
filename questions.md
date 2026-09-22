# SQL Practice — 80 Questions for Data Roles

Run `schema.sql` first to build the **NorthStar Retail** dataset (customers, employees,
categories, products, orders, order_items, reviews). All questions are written against
that schema. Answers are in `answers.sql` — try to solve each one before peeking.

Difficulty legend: 🟢 Beginner · 🟡 Intermediate · 🔴 Advanced

---

## 1. SELECT, WHERE, ORDER BY, LIMIT (🟢)

1. List all customers from 'Canada'.
2. Get all products with a unit price greater than $50, sorted from most to least expensive.
3. Find the 5 most recently signed-up customers.
4. List all orders with status 'cancelled'.
5. Find all products whose name contains the word "Headphones".
6. Get all employees hired before 2020-01-01.
7. List distinct countries present in the customers table.
8. Find products that are discontinued AND have stock remaining.

## 2. Aggregation: COUNT, SUM, AVG, GROUP BY, HAVING (🟢/🟡)

9. Count how many customers are in each country.
10. Find the total quantity sold per product.
11. Calculate the average unit price per product category.
12. Find categories that have more than 3 products (HAVING).
13. Calculate total revenue (quantity × unit_price, ignoring discount) per order.
14. Find the number of orders placed by each customer, only for customers with 2+ orders.
15. Find the average order value per employee (as the salesperson on the order).
16. Get the min, max, and average product price per category in one query.
17. Count how many reviews each product has received, sorted descending.
18. Find products with an average rating below 3.

## 3. JOINs (🟡)

19. List each order with the customer's first and last name.
20. List each order item with the product name and category name.
21. Find all customers who have never placed an order (LEFT JOIN + IS NULL).
22. Find all products that have never been ordered.
23. List each order along with the employee who handled it (name, department).
24. Show every review with the customer's name and the product name.
25. List all customers and, if they exist, the name of the customer who referred them (self-join).
26. List all employees along with their manager's name (self-join).
27. Find pairs of customers who live in the same city (self-join, excluding self-matches).
28. List orders that include products from more than one category.

## 4. Subqueries & CTEs (🟡/🔴)

29. Find customers who have spent more than the average total spend across all customers.
30. Find the product with the highest total revenue (subquery for the max).
31. Using a CTE, calculate total revenue per customer, then filter to customers who spent over $200.
32. Find employees whose salary is above their department's average salary.
33. Find the second-highest priced product overall (without LIMIT/OFFSET).
34. Using a CTE, rank products by total units sold within each category.
35. Find customers whose most recent order was cancelled.
36. Find products that have a higher average rating than the overall average rating across all products.

## 5. Window Functions (🔴)

37. Rank customers by total spend using RANK() and DENSE_RANK() — compare the outputs.
38. For each customer, show their order date and the date of their previous order (LAG).
39. For each customer, show the running total of their spend over time (SUM ... OVER).
40. Find the top 2 highest-priced products per category using ROW_NUMBER() PARTITION BY.
41. Calculate a 3-order moving average of order revenue per customer.
42. For each product, show its price and the difference from the average price in its category.
43. Assign each order into quartiles (NTILE(4)) based on order revenue.
44. For each employee, find the number of days between consecutive orders they processed (LEAD/LAG).

## 6. Dates & Time Intelligence (🟡/🔴)

45. Calculate the number of days between order_date and ship_date for completed orders.
46. Find the month with the highest total revenue.
47. Calculate month-over-month revenue growth (%) using a CTE or window function.
48. Find customers who signed up in the same month they placed their first order.
49. Find orders that took longer than 5 days to ship.
50. Calculate the average shipping delay (in days) per employee.
51. Find the number of new customers acquired each month in 2022.
52. Identify the busiest day of the week for orders (by count).

## 7. String & Conditional Logic (🟢/🟡)

53. Concatenate first_name and last_name into a full_name column for customers.
54. Extract the domain from each customer's email address.
55. Use CASE WHEN to bucket products into 'Budget' (<$30), 'Mid-range' ($30-$100), and 'Premium' (>$100).
56. Find customers whose email does not contain '@mail.com' (pattern matching practice — assume some do not).
57. Standardize city names to uppercase and trim any extra whitespace.
58. Use CASE WHEN inside an aggregate to count completed vs cancelled vs returned orders in a single row.

## 8. Set Operations & Data Quality (🟡)

59. Find product_ids that exist in order_items but not in products (should be none — verify referential integrity).
60. Use UNION to combine a list of customer cities and employee-less "HQ" cities into one list.
61. Find duplicate reviews (same customer_id, product_id, review_date) if any exist.
62. Use INTERSECT (or equivalent JOIN) to find customers who have both placed an order and left a review.
63. Use EXCEPT/NOT IN to find customers who have placed orders but never left a review.
64. Check for orphaned order_items (order_items referencing a non-existent order_id).

## 9. Views, Indexes, and Schema Reasoning (🟡/🔴)

65. Write a CREATE VIEW statement that exposes a clean "order_summary" (order_id, customer name, order date, total revenue, item count).
66. Explain (in a comment) which columns you would index to speed up "find all orders for a customer in a date range" and write the CREATE INDEX statement.
67. Write a query that would benefit from a composite index on (customer_id, order_date) and justify why.
68. Rewrite a correlated subquery from Section 4 as a JOIN, and explain the performance tradeoff.

## 10. Business/Analytics Scenarios (🔴)

69. Calculate customer lifetime value (CLV) = total revenue per customer minus... (assume no returns cost) grouped and ranked.
70. Identify the top 3 customers by revenue in each country.
71. Calculate the retention rate: % of customers who ordered in both January and February 2022.
72. Find products frequently bought together (appear in the same order_id at least twice across the dataset).
73. Calculate the churn signal: customers whose last order was more than 60 days before the latest order_date in the dataset.
74. Build a cohort analysis: group customers by signup month, and show their order count in each subsequent month.
75. Calculate the average discount given per employee and flag employees who discount more than the company average.
76. Find the category that generates the most revenue per unit of stock (a simple "efficiency" metric).
77. Identify referral chains: for each customer referred by another, calculate how much revenue the referred customer generated.
78. Calculate the percentage of orders that were cancelled or returned, overall and by employee.
79. Write a query to detect employees who might need coaching: below-average order count AND below-average average order value.
80. Design (in words, plus SQL) a query to answer "what is our month-over-month active customer count?" where active = placed at least one completed order that month.

---

### How to use this
- Try each question cold before checking `answers.sql`.
- Time yourself on sections 5, 6, and 10 — window functions and business scenarios are the most common gaps for interview-ready SQL.
- Once comfortable, try rewriting your CTE-based answers as subqueries and vice versa for flexibility.

-- ============================================================
-- Practice Schema: "NorthStar Retail" (mini e-commerce dataset)
-- Compatible with PostgreSQL / MySQL / SQLite (minor tweaks noted)
-- Load this first, then work through questions.sql
-- ============================================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS reviews;

CREATE TABLE customers (
    customer_id     INTEGER PRIMARY KEY,
    first_name      VARCHAR(50),
    last_name       VARCHAR(50),
    email           VARCHAR(100),
    city            VARCHAR(50),
    country         VARCHAR(50),
    signup_date     DATE,
    referred_by     INTEGER REFERENCES customers(customer_id)
);

CREATE TABLE employees (
    employee_id     INTEGER PRIMARY KEY,
    first_name      VARCHAR(50),
    last_name       VARCHAR(50),
    manager_id      INTEGER REFERENCES employees(employee_id),
    department      VARCHAR(50),
    hire_date       DATE,
    salary          NUMERIC(10,2)
);

CREATE TABLE categories (
    category_id     INTEGER PRIMARY KEY,
    category_name   VARCHAR(50)
);

CREATE TABLE products (
    product_id      INTEGER PRIMARY KEY,
    product_name    VARCHAR(100),
    category_id     INTEGER REFERENCES categories(category_id),
    unit_price      NUMERIC(10,2),
    stock_quantity  INTEGER,
    discontinued    BOOLEAN DEFAULT FALSE
);

CREATE TABLE orders (
    order_id        INTEGER PRIMARY KEY,
    customer_id     INTEGER REFERENCES customers(customer_id),
    employee_id     INTEGER REFERENCES employees(employee_id),
    order_date      DATE,
    ship_date       DATE,
    status          VARCHAR(20)   -- 'completed','cancelled','pending','returned'
);

CREATE TABLE order_items (
    order_item_id   INTEGER PRIMARY KEY,
    order_id        INTEGER REFERENCES orders(order_id),
    product_id      INTEGER REFERENCES products(product_id),
    quantity        INTEGER,
    unit_price      NUMERIC(10,2),   -- price at time of sale
    discount        NUMERIC(4,2) DEFAULT 0  -- e.g. 0.10 = 10%
);

CREATE TABLE reviews (
    review_id       INTEGER PRIMARY KEY,
    product_id      INTEGER REFERENCES products(product_id),
    customer_id     INTEGER REFERENCES customers(customer_id),
    rating          INTEGER,   -- 1 to 5
    review_date     DATE,
    review_text     TEXT
);

-- ============================================================
-- Seed data — small enough to eyeball, large enough to be useful
-- ============================================================

INSERT INTO customers (customer_id, first_name, last_name, email, city, country, signup_date, referred_by) VALUES
(1,'Ava','Martin','ava.martin@mail.com','New York','USA','2021-01-15',NULL),
(2,'Liam','Chen','liam.chen@mail.com','Toronto','Canada','2021-02-20',1),
(3,'Sofia','Garcia','sofia.garcia@mail.com','Madrid','Spain','2021-03-05',NULL),
(4,'Noah','Kim','noah.kim@mail.com','Seoul','South Korea','2021-04-10',NULL),
(5,'Emma','Dubois','emma.dubois@mail.com','Paris','France','2021-05-01',3),
(6,'Oliver','Rossi','oliver.rossi@mail.com','Milan','Italy','2021-06-12',NULL),
(7,'Mia','Nowak','mia.nowak@mail.com','Warsaw','Poland','2021-07-18',NULL),
(8,'Lucas','Silva','lucas.silva@mail.com','Lisbon','Portugal','2021-08-22',2),
(9,'Isabella','Muller','isabella.muller@mail.com','Berlin','Germany','2021-09-30',NULL),
(10,'Ethan','Wong','ethan.wong@mail.com','Hong Kong','China','2021-10-14',4),
(11,'Charlotte','Taylor','charlotte.taylor@mail.com','London','UK','2022-01-05',NULL),
(12,'James','Brown','james.brown@mail.com','Manchester','UK','2022-02-11',11),
(13,'Amelia','Wilson','amelia.wilson@mail.com','Sydney','Australia','2022-03-19',NULL),
(14,'Benjamin','Moore','benjamin.moore@mail.com','Melbourne','Australia','2022-04-25',13),
(15,'Harper','Lee','harper.lee@mail.com','Vancouver','Canada','2022-05-30',NULL);

INSERT INTO employees (employee_id, first_name, last_name, manager_id, department, hire_date, salary) VALUES
(1,'Grace','Hall',NULL,'Executive','2018-01-10',150000),
(2,'Henry','Adams',1,'Sales','2018-06-01',95000),
(3,'Ivy','Baker',1,'Support','2019-02-15',85000),
(4,'Jack','Carter',2,'Sales','2019-08-20',72000),
(5,'Kelly','Evans',2,'Sales','2020-03-05',68000),
(6,'Liam','Foster',3,'Support','2020-07-11',60000),
(7,'Mona','Grant',3,'Support','2021-01-25',58000);

INSERT INTO categories (category_id, category_name) VALUES
(1,'Electronics'),
(2,'Home & Kitchen'),
(3,'Books'),
(4,'Sports & Outdoors'),
(5,'Toys');

INSERT INTO products (product_id, product_name, category_id, unit_price, stock_quantity, discontinued) VALUES
(1,'Wireless Mouse',1,25.99,150,FALSE),
(2,'Mechanical Keyboard',1,89.99,80,FALSE),
(3,'USB-C Hub',1,34.50,200,FALSE),
(4,'Noise Cancelling Headphones',1,199.99,60,FALSE),
(5,'Blender',2,49.99,45,FALSE),
(6,'Air Fryer',2,79.99,30,FALSE),
(7,'Cotton Bedsheet Set',2,39.99,100,FALSE),
(8,'SQL for Data Analysts',3,29.99,120,FALSE),
(9,'Data Science Handbook',3,45.00,90,FALSE),
(10,'Mystery Novel',3,14.99,200,TRUE),
(11,'Yoga Mat',4,19.99,180,FALSE),
(12,'Running Shoes',4,74.99,70,FALSE),
(13,'Camping Tent',4,129.99,25,FALSE),
(14,'Building Blocks Set',5,34.99,110,FALSE),
(15,'Remote Control Car',5,59.99,40,TRUE);

INSERT INTO orders (order_id, customer_id, employee_id, order_date, ship_date, status) VALUES
(1,1,4,'2022-01-05','2022-01-07','completed'),
(2,2,4,'2022-01-10','2022-01-12','completed'),
(3,3,5,'2022-01-15',NULL,'cancelled'),
(4,1,4,'2022-02-01','2022-02-03','completed'),
(5,4,5,'2022-02-10','2022-02-14','completed'),
(6,5,4,'2022-02-20','2022-02-22','completed'),
(7,6,5,'2022-03-01',NULL,'pending'),
(8,7,4,'2022-03-05','2022-03-08','completed'),
(9,2,5,'2022-03-15','2022-03-18','returned'),
(10,8,4,'2022-04-01','2022-04-04','completed'),
(11,9,5,'2022-04-10','2022-04-12','completed'),
(12,10,4,'2022-04-20',NULL,'cancelled'),
(13,3,5,'2022-05-01','2022-05-03','completed'),
(14,11,4,'2022-05-15','2022-05-19','completed'),
(15,12,5,'2022-05-25','2022-05-27','completed'),
(16,1,4,'2022-06-01','2022-06-03','completed'),
(17,13,5,'2022-06-10','2022-06-13','completed'),
(18,14,4,'2022-06-20',NULL,'pending'),
(19,2,5,'2022-07-01','2022-07-05','completed'),
(20,15,4,'2022-07-10','2022-07-12','completed'),
(21,4,5,'2022-07-20','2022-07-23','completed'),
(22,6,4,'2022-08-01','2022-08-03','completed'),
(23,9,5,'2022-08-10','2022-08-14','returned'),
(24,11,4,'2022-08-20','2022-08-22','completed'),
(25,1,5,'2022-09-01','2022-09-04','completed');

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price, discount) VALUES
(1,1,1,2,25.99,0),
(2,1,3,1,34.50,0),
(3,2,2,1,89.99,0.10),
(4,3,4,1,199.99,0),
(5,4,8,3,29.99,0),
(6,5,5,1,49.99,0),
(7,5,6,1,79.99,0.05),
(8,6,11,2,19.99,0),
(9,7,12,1,74.99,0),
(10,8,9,2,45.00,0),
(11,9,2,1,89.99,0),
(12,10,7,2,39.99,0.15),
(13,11,1,1,25.99,0),
(14,11,3,2,34.50,0),
(15,12,13,1,129.99,0),
(16,13,4,1,199.99,0.20),
(17,14,8,1,29.99,0),
(18,14,9,1,45.00,0),
(19,15,14,3,34.99,0),
(20,16,1,1,25.99,0),
(21,16,2,1,89.99,0),
(22,17,12,2,74.99,0.10),
(23,18,11,1,19.99,0),
(24,19,6,1,79.99,0),
(25,20,3,2,34.50,0),
(26,21,4,1,199.99,0),
(27,22,5,1,49.99,0),
(28,23,7,3,39.99,0),
(29,24,9,2,45.00,0),
(30,25,1,3,25.99,0),
(31,25,8,2,29.99,0.05);

INSERT INTO reviews (review_id, product_id, customer_id, rating, review_date, review_text) VALUES
(1,1,1,5,'2022-01-10','Great mouse, very responsive.'),
(2,2,2,4,'2022-01-20','Solid keyboard, a bit loud.'),
(3,4,3,2,'2022-01-25','Cancelled before it arrived, refunded fine.'),
(4,8,1,5,'2022-02-05','Best SQL book I have used.'),
(5,5,4,4,'2022-02-15','Blends well, easy to clean.'),
(6,6,5,3,'2022-02-25','Works but basket is small.'),
(7,12,6,5,'2022-03-10','Comfortable for long runs.'),
(8,9,7,4,'2022-03-15','Good depth on statistics chapters.'),
(9,2,2,3,'2022-03-25','Started double-typing after a month.'),
(10,7,8,5,'2022-04-05','Soft and durable sheets.'),
(11,1,9,4,'2022-04-15','Good value for the price.'),
(12,13,10,NULL,'2022-04-25','Order was cancelled, never tried it.'),
(13,4,3,4,'2022-05-05','Sound quality is excellent.'),
(14,8,11,5,'2022-05-20','Perfect for interview prep.'),
(15,9,11,4,'2022-05-20','Companion piece to the SQL book.'),
(16,14,12,5,'2022-05-30','Kids love it.'),
(17,1,1,5,'2022-06-05','Bought a second one as backup.'),
(18,12,13,4,'2022-06-15','True to size.'),
(19,11,14,3,'2022-06-25','Mat is a bit thin.'),
(20,6,2,2,'2022-07-10','Broke after two months.');

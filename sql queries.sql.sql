
-- 1. CREATE MASTER TABLE


CREATE TABLE master_table AS
SELECT 
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    o.order_purchase_timestamp,
    oi.product_id,
    p.product_category_name,
    oi.price,
    pay.payment_value
FROM orders o
JOIN customers c
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN payments pay
    ON o.order_id = pay.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered';


-- 2. VIEW DATA

SELECT * FROM master_table
LIMIT 10;



-- 3. MONTHLY REVENUE ANALYSIS

SELECT 
    strftime('%Y-%m', order_purchase_timestamp) AS month,
    SUM(payment_value) AS revenue
FROM master_table
GROUP BY month
ORDER BY month;


-- 4. TOP PRODUCT CATEGORIES BY REVENUE

SELECT 
    product_category_name,
    SUM(payment_value) AS total_revenue
FROM master_table
GROUP BY product_category_name
ORDER BY total_revenue DESC
LIMIT 10;


-- 5. CUSTOMER FREQUENCY & MONETARY (RFM BASE)

CREATE TABLE rfm_base AS
SELECT 
    customer_unique_id,
    MAX(order_purchase_timestamp) AS last_order_date,
    COUNT(order_id) AS frequency,
    SUM(payment_value) AS monetary
FROM master_table
GROUP BY customer_unique_id;



-- 6. RECENCY CALCULATION

CREATE TABLE rfm_recency AS
SELECT 
    customer_unique_id,
    julianday('now') - julianday(last_order_date) AS recency,
    frequency,
    monetary
FROM rfm_base;


-- 7. VIEW RFM DATA

SELECT * FROM rfm_recency
LIMIT 10;

-- 8. TOTAL REVENUE KPI

SELECT 
    SUM(payment_value) AS total_revenue
FROM master_table;
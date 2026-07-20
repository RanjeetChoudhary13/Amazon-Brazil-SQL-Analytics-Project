-- =====================================================
-- AMAZON BRAZIL SQL PROJECT
-- Name : Ranjeet Anada
-- =====================================================


-- =====================================================
-- Q1. Find the total number of orders fulfilled by each seller state.
-- =====================================================

SELECT
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM sellers s
JOIN order_items oi
ON s.seller_id = oi.seller_id
GROUP BY s.seller_state
ORDER BY total_orders DESC;



-- =====================================================
-- Q2. For each product category, calculate the cumulative revenue generated as orders come in over time.
-- =====================================================

SELECT
    p.product_category_name,
    DATE(o.order_purchase_timestamp) AS order_date,
    SUM(oi.price) AS daily_revenue,
    SUM(SUM(oi.price)) OVER (
        PARTITION BY p.product_category_name
        ORDER BY DATE(o.order_purchase_timestamp)
    ) AS cumulative_revenue
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
JOIN orders o
ON oi.order_id = o.order_id
GROUP BY
    p.product_category_name,
    DATE(o.order_purchase_timestamp);



-- =====================================================
-- Q3. Which payment method do customers use the most, and what is the average order value for each payment type?
-- =====================================================

SELECT
    payment_type,
    COUNT(*) AS total_transactions,
    ROUND(AVG(payment_value),2) AS average_order_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_transactions DESC;


-- =====================================================
-- Q4. Find the customer who has spent the most money across all their orders.
-- =====================================================

SELECT
    o.customer_id,
    SUM(op.payment_value) AS total_spent
FROM orders o
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY o.customer_id
ORDER BY total_spent DESC
LIMIT 1;



-- =====================================================
-- Q5. Find the average review score for each product category.
-- =====================================================

SELECT
    p.product_category_name,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
JOIN order_reviews r
    ON oi.order_id = r.order_id
GROUP BY p.product_category_name
ORDER BY average_review_score DESC;



-- =====================================================
-- Q6. Find the total number of orders placed by each customer,
-- broken down by the state they live in.
-- =====================================================

SELECT
    c.customer_state,
    c.customer_id,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state, c.customer_id
ORDER BY total_orders DESC;



-- =====================================================
-- Q7. Identify sellers who registered on the platform
-- but have never fulfilled a single order.
-- =====================================================

SELECT
    s.seller_id,
    s.seller_state
FROM sellers s
LEFT JOIN order_items oi
    ON s.seller_id = oi.seller_id
WHERE oi.order_id IS NULL;



-- =====================================================
-- Q8. Find the top 5 product categories by total revenue.
-- =====================================================

SELECT
    p.product_category_name,
    SUM(oi.price) AS total_revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 5;



-- =====================================================
-- Q9. Calculate the median delivery time for orders.
-- =====================================================

WITH delivery_time AS (
    SELECT
        DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS delivery_days
    FROM orders
    WHERE order_delivered_customer_date IS NOT NULL
)

SELECT
    AVG(delivery_days) AS median_delivery_days
FROM (
    SELECT
        delivery_days,
        ROW_NUMBER() OVER (ORDER BY delivery_days) AS rn,
        COUNT(*) OVER () AS total_rows
    FROM delivery_time
) t
WHERE rn IN ((total_rows + 1) / 2, (total_rows + 2) / 2);



-- =====================================================
-- Q10. Find products that have never been ordered.
-- =====================================================

SELECT
    p.product_id,
    p.product_category_name
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;



-- =====================================================
-- Q11. Find sellers whose total number of orders is above
-- the average number of orders fulfilled by all sellers.
-- =====================================================

SELECT
    seller_id,
    COUNT(order_id) AS total_orders
FROM order_items
GROUP BY seller_id
HAVING COUNT(order_id) >
(
    SELECT AVG(order_count)
    FROM (
        SELECT COUNT(order_id) AS order_count
        FROM order_items
        GROUP BY seller_id
    ) avg_orders
);



-- =====================================================
-- Q12. Find the average review score for each customer state.
-- =====================================================

SELECT
    c.customer_state,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_reviews r
    ON o.order_id = r.order_id
GROUP BY c.customer_state
ORDER BY average_review_score DESC;



-- =====================================================
-- Q13. Find customers who have placed orders but never
-- submitted a review.
-- =====================================================

SELECT DISTINCT
    c.customer_id
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
LEFT JOIN order_reviews r
    ON o.order_id = r.order_id
WHERE r.review_id IS NULL;



-- =====================================================
-- Q14. Find the month with the highest number of orders.
-- =====================================================

SELECT
    MONTHNAME(order_purchase_timestamp) AS month_name,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY
    MONTH(order_purchase_timestamp),
    MONTHNAME(order_purchase_timestamp)
ORDER BY total_orders DESC
LIMIT 1;


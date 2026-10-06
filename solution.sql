-- Database Setup
CREATE DATABASE creamy_g;
\c creamy_g;

-- ============================================================
-- Question 1: Customer Orders
-- List customer names along with their order IDs and order dates. Only include customers who have placed at least one order.
-- ============================================================
SELECT 
    c.name, 
    o.order_id, 
    o.order_date
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id;


-- ============================================================
-- Question 2: Complete Customer List
-- Display all customers with their names and emails, and include any associated order ID and date if available, even if the customer hasn't placed any orders.
-- ============================================================
SELECT 
    c.name, 
    c.email, 
    o.order_id, 
    o.order_date
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id;


-- ============================================================
-- Question 3: Complete Order List
-- Show all orders with their IDs, dates, and total amounts, alongside the customer name if the order references a valid customer. Include all orders even if the customer reference is invalid or missing.
-- ============================================================
SELECT 
    o.order_id, 
    o.order_date, 
    o.total_amount, 
    c.name AS customer_name
FROM orders o
LEFT JOIN customers c 
    ON o.customer_id = c.customer_id;


-- ============================================================
-- Question 4: Complete Relationship View
-- Create a comprehensive view of customer-to-order relationships showing all customers and orders, including customers without orders and orders without valid customer references.
-- ============================================================
SELECT 
    c.customer_id, 
    c.name AS customer_name, 
    o.order_id, 
    o.order_date, 
    o.total_amount
FROM customers c
FULL OUTER JOIN orders o 
    ON c.customer_id = o.customer_id;


-- ============================================================
-- Question 5: Customers Without Orders
-- Identify customers who have not placed any orders. Display their names, emails, and cities.
-- ============================================================
SELECT 
    c.name, 
    c.email, 
    c.city
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- ============================================================
-- Question 6: Products Never Ordered
-- Find products that have never been included in any order, showing product name, category, and price.
-- ============================================================
SELECT 
    p.product_name, 
    p.category, 
    p.price
FROM products p
LEFT JOIN order_items oi 
    ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;


-- ============================================================
-- Question 7: Orders Missing Customer Data
-- Retrieve orders that have invalid or missing customer references, including order ID, customer ID, order date, and total amount.
-- ============================================================
SELECT 
    o.order_id, 
    o.customer_id, 
    o.order_date, 
    o.total_amount
FROM orders o
LEFT JOIN customers c 
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- ============================================================
-- Question 8: Valid Purchases Only
-- Show customer name, order date, and product name for all transactions where the customer, order, and product all exist. Exclude any orphaned or invalid records.
-- ============================================================
SELECT 
    c.name AS customer_name, 
    o.order_date, 
    p.product_name
FROM order_items oi
INNER JOIN orders o 
    ON oi.order_id = o.order_id
INNER JOIN customers c 
    ON o.customer_id = c.customer_id
INNER JOIN products p 
    ON oi.product_id = p.product_id;


-- ============================================================
-- Question 9: All Customers with Valid Products
-- Display all customers and their order info, but only include records with valid products. Show customer name, order date, product name, and quantity.
-- ============================================================
SELECT 
    c.name AS customer_name, 
    o.order_date, 
    p.product_name, 
    oi.quantity
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi 
    ON o.order_id = oi.order_id
INNER JOIN products p 
    ON oi.product_id = p.product_id;


-- ============================================================
-- Question 10: Complete Order Details with Missing Data Handling
-- List customer name, order date, product name, category, quantity, and unit price for all order items. For orphaned or invalid references, substitute "Unknown Customer" or "Unknown Product" accordingly.
-- ============================================================
SELECT 
    COALESCE(c.name, 'Unknown Customer') AS customer_name,
    o.order_date,
    COALESCE(p.product_name, 'Unknown Product') AS product_name,
    COALESCE(p.category, 'Unknown Category') AS category,
    oi.quantity,
    oi.unit_price
FROM order_items oi
LEFT JOIN orders o 
    ON oi.order_id = o.order_id
LEFT JOIN customers c 
    ON o.customer_id = c.customer_id
LEFT JOIN products p 
    ON oi.product_id = p.product_id;


-- ============================================================
-- Question 11: Customer Order Statistics
-- For each customer, including those with no orders, show: Customer name, Number of orders placed, Total amount spent. Use zero for customers without orders.
-- ============================================================
SELECT 
    c.name AS customer_name,
    COUNT(o.order_id) AS orders_placed,
    COALESCE(SUM(o.total_amount), 0) AS total_amount_spent
FROM customers c
LEFT JOIN orders o 
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;


-- ============================================================
-- Question 12: Product Sales Summary
-- Summarize sales for each product, including those never sold, with: Product name and category, Total quantity sold (0 if none), Total revenue generated (0 if none)
-- ============================================================
SELECT 
    p.product_name,
    p.category,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_revenue
FROM products p
LEFT JOIN order_items oi 
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category;


-- ============================================================
-- Question 13: Category Performance Analysis
-- For each product category, identify: Total number of products in the category, Number of products sold from that category, Number of unsold products from that category
-- ============================================================
SELECT 
    p.category,
    COUNT(DISTINCT p.product_id) AS total_products,
    COUNT(DISTINCT CASE WHEN oi.product_id IS NOT NULL THEN p.product_id END) AS products_sold,
    COUNT(DISTINCT CASE WHEN oi.product_id IS NULL THEN p.product_id END) AS products_unsold
FROM products p
LEFT JOIN order_items oi 
    ON p.product_id = oi.product_id
GROUP BY p.category;


-- ============================================================
-- Question 14: Orphaned Records Report
-- Produce a report showing: Number of orders without valid customers, Number of order items without valid orders, Number of order items without valid products
-- ============================================================
SELECT
    (
        SELECT COUNT(*) 
        FROM orders o 
        LEFT JOIN customers c ON o.customer_id = c.customer_id 
        WHERE c.customer_id IS NULL
    ) AS orders_without_valid_customers,
    (
        SELECT COUNT(*) 
        FROM order_items oi 
        LEFT JOIN orders o ON oi.order_id = o.order_id 
        WHERE o.order_id IS NULL
    ) AS items_without_valid_orders,
    (
        SELECT COUNT(*) 
        FROM order_items oi 
        LEFT JOIN products p ON oi.product_id = p.product_id 
        WHERE p.product_id IS NULL
    ) AS items_without_valid_products;


-- ============================================================
-- Question 15: Complete Data Integrity Check
-- Create a combined report that labels all problematic relationships, such as: Customers with no orders, Orders without customers, Products with no sales, Order items with invalid orders or products
-- ============================================================
SELECT 'Customer with no orders' AS issue_type, CAST(c.customer_id AS VARCHAR) AS record_id, c.name AS description
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL

UNION ALL

SELECT 'Order without customer', CAST(o.order_id AS VARCHAR), CONCAT('Customer ID: ', COALESCE(CAST(o.customer_id AS VARCHAR), 'NULL'))
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT 'Product with no sales', CAST(p.product_id AS VARCHAR), p.product_name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL

UNION ALL

SELECT 'Order item with invalid order', CAST(oi.order_item_id AS VARCHAR), CONCAT('Order ID: ', CAST(oi.order_id AS VARCHAR))
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT 'Order item with invalid product', CAST(oi.order_item_id AS VARCHAR), CONCAT('Product ID: ', COALESCE(CAST(oi.product_id AS VARCHAR), 'NULL'))
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- ============================================================
-- Question 16: Customer Purchase Diversity
-- Find customers who have placed orders and, for each, determine: Customer name, Count of distinct product categories purchased from, List of categories as a comma-separated string
-- ============================================================
SELECT 
    c.name AS customer_name,
    COUNT(DISTINCT p.category) AS distinct_categories_count,
    STRING_AGG(DISTINCT p.category, ', ') AS categories_list
FROM customers c
INNER JOIN orders o 
    ON c.customer_id = o.customer_id
INNER JOIN order_items oi 
    ON o.order_id = oi.order_id
INNER JOIN products p 
    ON oi.product_id = p.product_id
GROUP BY c.customer_id, c.name;


-- ============================================================
-- Question 17: Revenue Reconciliation
-- Compare each order's total amount (from the order table) with the sum of (quantity × unit_price) from associated order items. Show order ID, stated total, calculated total, and the difference. Only include valid customer orders with at least one order item.
-- ============================================================
SELECT 
    o.order_id,
    o.total_amount AS stated_total,
    SUM(oi.quantity * oi.unit_price) AS calculated_total,
    (o.total_amount - SUM(oi.quantity * oi.unit_price)) AS difference
FROM orders o
INNER JOIN customers c 
    ON o.customer_id = c.customer_id
INNER JOIN order_items oi 
    ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount;


-- ============================================================
-- Question 18: Complex Relationship Analysis
-- Identify customers who have: Placed at least one order, Ordered products from the 'Electronics' category, Also ordered products from at least one other category. For qualifying customers, list their name and all categories they ordered from.
-- ============================================================
WITH CustomerCategories AS (
    SELECT 
        c.customer_id,
        c.name AS customer_name,
        p.category
    FROM customers c
    INNER JOIN orders o 
        ON c.customer_id = o.customer_id
    INNER JOIN order_items oi 
        ON o.order_id = oi.order_id
    INNER JOIN products p 
        ON oi.product_id = p.product_id
    GROUP BY c.customer_id, c.name, p.category
)
SELECT 
    customer_name,
    STRING_AGG(category, ', ') AS categories_ordered
FROM CustomerCategories
WHERE customer_id IN (
    SELECT customer_id
    FROM CustomerCategories
    GROUP BY customer_id
    HAVING SUM(CASE WHEN category = 'Electronics' THEN 1 ELSE 0 END) > 0
       AND COUNT(DISTINCT category) > 1
)
GROUP BY customer_id, customer_name;
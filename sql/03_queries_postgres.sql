-- 0. Orders with customer and product details
SELECT 
    o.order_id,
    c.customer_name,
    p.product_name,
    o.quantity,
    o.sell_price,
    o.date
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Products p ON o.product_id = p.product_id

-- 1. Total revenue by category
SELECT category_name, SUM(o.quantity * o.sell_price) AS total_revenue
FROM Orders o
JOIN Products p ON p.product_id = o.product_id
JOIN Categories c ON c.category_id = p.category_id
GROUP BY category_name
ORDER BY total_revenue DESC

-- 2. Top 10 customers by revenue
SELECT customer_name, SUM(o.quantity * o.sell_price) AS revenue
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY customer_name
ORDER BY revenue DESC
LIMIT 10;

-- 3. Monthly revenue trend
SELECT EXTRACT(YEAR FROM o.date) AS year, EXTRACT(MONTH FROM o.date) AS month, SUM(o.quantity * o.sell_price) AS revenue
from Orders o
GROUP BY EXTRACT(YEAR FROM o.date), EXTRACT(MONTH FROM o.date)
ORDER BY EXTRACT(YEAR FROM o.date), EXTRACT(MONTH FROM o.date)

-- 4. Products with no sales (dead stock)
select DISTINCT p.product_name, category_name
FROM Products p
LEFT JOIN Orders o ON p.product_id = o.product_id
JOIN Categories c ON c.category_id = p.category_id
WHERE o.order_id IS NULL

-- 5. Average order value by country
SELECT customer_country, AVG(o.sell_price * o.quantity) AS average_order_value
from Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY customer_country
ORDER BY average_order_value DESC

-- 6. Sell-through rate by category
SELECT 
    c.category_name,
    sold.total_quantity_sold,
    avail.total_available_quantity,
    ROUND(sold.total_quantity_sold * 100.0 / avail.total_available_quantity, 2) AS sell_through_rate
FROM Categories c
JOIN (
    SELECT category_id, SUM(o.quantity) AS Total_quantity_sold
	From Orders o
	JOIN Products p ON p.product_id = o.product_id
	GROUP BY category_id
	) AS sold ON sold.category_id = c.category_id
JOIN (
    SELECT category_id, SUM(quantity) AS Total_available_quantity
	From Products
	GROUP BY category_id
	) AS avail ON avail.category_id = c.category_id
ORDER BY sell_through_rate DESC

-- 7. Top 5 suppliers by revenue
SELECT supplier_name, SUM(o.quantity * o.sell_price) AS total_revenue_generated
from Orders o
JOIN Products p ON o.product_id = p.product_id
JOIN Suppliers s ON p.supplier_id = s.supplier_id
GROUP BY supplier_name
ORDER BY total_revenue_generated DESC
LIMIT 5;

-- 8. Product revenue contribution per category (CTE + Window Function)
WITH product_revenue AS (
    SELECT product_name, category_name, SUM(o.quantity * o.sell_price) AS product_revenue
	from Orders o
	JOIN Products p ON p.product_id = o.product_id
	JOIN Categories c ON c.category_id = p.category_id
	GROUP BY product_name, category_name
)
SELECT 
    product_name,
    category_name,
    product_revenue,
    SUM(product_revenue) OVER (PARTITION BY category_name) AS category_total,
    ROUND(product_revenue * 100.0 / SUM(product_revenue) OVER (PARTITION BY category_name), 2) AS contribution_pct
FROM product_revenue
ORDER BY category_name, contribution_pct DESC

-- 9. Running total of revenue over time
WITH monthly_revenue_trend AS (
	-- 3. Monthly revenue trend
	SELECT EXTRACT(YEAR FROM o.date) AS year, EXTRACT(MONTH FROM o.date) AS month, SUM(o.quantity * o.sell_price) AS revenue
	from Orders o
	GROUP BY EXTRACT(YEAR FROM o.date), EXTRACT(MONTH FROM o.date)
)
SELECT year, month, revenue, SUM(revenue) OVER (ORDER BY year, month) AS running_revenue_overtime
from monthly_revenue_trend
ORDER BY YEAR, MONTH

-- 10. Average buy price vs sell price per category (margin analysis)
SELECT 
	category_name, 
	AVG(sell_price) AS average_sell_price, 
	AVG(buy_price) AS average_buy_price,
	ROUND(AVG(o.sell_price) - AVG(p.buy_price), 2) AS avg_margin
from Orders o
JOIN Products p ON o.product_id = p.product_id
JOIN Categories c ON c.category_id = p.category_id
GROUP BY category_name
ORDER BY avg_margin DESC
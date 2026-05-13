-- 1. Sales summary by category for a given date range
CREATE PROCEDURE sales_summary
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT category_name, SUM(o.quantity * o.sell_price) AS total_revenue
	FROM Orders o
	JOIN Products p ON p.product_id = o.product_id
	JOIN Categories c ON c.category_id = p.category_id
	WHERE date >= @StartDate AND date <= @EndDate
	GROUP BY category_name
	ORDER BY total_revenue DESC
END

-- 2. Top N customers by revenue
CREATE PROCEDURE top_customers
	@TopN INT
AS
BEGIN
	SELECT TOP (@TopN) customer_name, SUM(o.quantity * o.sell_price) AS revenue
	FROM Orders o
	JOIN Customers c ON o.customer_id = c.customer_id
	GROUP BY customer_name
	ORDER BY revenue DESC;
END

-- 3. Flag low stock products by threshold
CREATE PROCEDURE flag_low_stock
	@Threshold INT
AS
BEGIN
	SELECT product_name, category_name, supplier_name, quantity
	from Products p
	JOIN Categories c ON p.category_id = c.category_id
	JOIN Suppliers s ON p.supplier_id = s.supplier_id
	WHERE quantity < (@Threshold)
END
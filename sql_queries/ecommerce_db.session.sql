CREATE TABLE orders (
    order_id VARCHAR(20),
    order_date DATE,
    customer_name VARCHAR(100),
    state VARCHAR(50),
    city VARCHAR(50)
);


CREATE TABLE order_details (
    order_id VARCHAR(20),
    amount NUMERIC,
    profit NUMERIC,
    quantity INT,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    is_negative_profit BOOLEAN
);

CREATE TABLE sales_target (
    month_of_order_date VARCHAR(10),
    category VARCHAR(50),
    target NUMERIC
);  

--identifying the current database
SELECT current_database();
SELECT datname FROM pg_database;


SELECT * FROM orders LIMIT 5;
SELECT * FROM order_details LIMIT 5;
SELECT * FROM sales_target LIMIT 5;


--Number of total orders
SELECT COUNT(*) FROM orders;

--How many unique products in the order_details table
SELECT COUNT(DISTINCT sub_category) FROM order_details;

--total revenue generated from all the orders
SELECT SUM(amount) AS total_revenue FROM order_details;

--What is the average order amount in the order_details table
SELECT AVG(amount) AS average_order_amount FROM order_details;

--What is the average order amount if we had a profit
SELECT AVG(amount) AS average_order_amount_with_profit 
FROM order_details 
WHERE is_negative_profit = FALSE;

--compare average order amount with and without profit
SELECT 
    AVG(amount) AS average_order_amount_with_profit,
    (SELECT AVG(amount) FROM order_details WHERE is_negative_profit = TRUE) AS average_order_amount_without_profit
FROM order_details 
WHERE is_negative_profit = FALSE;


--how many orders were placed in each month of the year
SELECT 
    TO_CHAR(order_date, 'Month') AS month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY month
ORDER BY total_orders DESC;

--identify the top 5 customers who have placed the most orders
SELECT
    customer_name,
    COUNT(*) AS total_orders
FROM orders
GROUP BY customer_name
ORDER BY total_orders DESC
LIMIT 5;

--identify the top 5 products with the highest quantity sold
SELECT
    sub_category,
    SUM(quantity) AS total_quantity_sold
FROM order_details
GROUP BY sub_category
ORDER BY total_quantity_sold DESC
LIMIT 5;

--identify the top 5 products with the highest revenue generated
SELECT
    sub_category,
    SUM(amount) AS total_revenue_generated
FROM order_details
GROUP BY sub_category
ORDER BY total_revenue_generated DESC
LIMIT 5;

--identify the top 10 customers who have generated the highest revenue
SELECT
    o.customer_name,
    SUM(od.amount) AS total_revenue_generated
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.customer_name
ORDER BY total_revenue_generated DESC
LIMIT 10;


--avergae quantity, amount, and profit per order
SELECT
    AVG(quantity) AS average_quantity_per_order,
    AVG(amount) AS average_amount_per_order,
    AVG(profit) AS average_profit_per_order
FROM order_details;


--Which products in sales_target were never purchased?
SELECT category
FROM sales_target
WHERE category NOT IN (
    SELECT DISTINCT category
    FROM order_details
);


--For each product, how does actual revenue compare to target revenue?
WITH actual_revenue AS (
    SELECT 
        DATE_TRUNC('month', o.order_date) AS month,
        od.category,
        SUM(od.amount) AS total_revenue
    FROM order_details od
    JOIN orders o ON od.order_id = o.order_id
    GROUP BY month, category
)
SELECT 
    TO_CHAR(st.month_of_order_date, 'Month') AS target_month,
    st.category,
    st.target AS target_revenue,
    COALESCE(ar.total_revenue, 0) AS actual_revenue,
    COALESCE(ar.total_revenue, 0) - st.target AS revenue_difference
FROM sales_target st
LEFT JOIN actual_revenue ar ON st.month_of_order_date = ar.month AND st.category = ar.category
ORDER BY st.month_of_order_date, st.category;



--which customers have placed the more than 5 orders
SELECT
    customer_name,
    COUNT(*) AS total_orders
FROM orders
group by customer_name
having count(*) > 5;


--which orders have more than 3 items
SELECT
    order_id,
    SUM(quantity) AS total_items
FROM order_details
GROUP BY order_id
HAVING SUM(quantity) > 3;


--calculate the total revenue for each day
SELECT
    o.order_date,
    SUM(od.amount) AS total_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.order_date
ORDER BY o.order_date;

--who are the top 10 customers by lifetime value
SELECT
    o.customer_name,
    SUM(od.amount) AS total_revenue_generated
FROM orders o 
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.customer_name
ORDER BY total_revenue_generated DESC
LIMIT 10;

--what is the month over month revenue growth
SELECT
    TO_CHAR(o.order_date, 'Month') AS order_month,
    SUM(od.amount) AS total_revenue
FROM orders o
JOIN order_details od USING (order_id)
GROUP BY order_month
ORDER BY order_month;



--Which product was the top seller in each month?
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', o.order_date) AS month,
        od.sub_category, 
        SUM(od.amount) AS total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY DATE_TRUNC('month', o.order_date) 
            ORDER BY SUM(od.amount) DESC
        ) AS rn
    FROM orders o
    JOIN order_details od USING (order_id)
    GROUP BY month, od.sub_category
)
SELECT
    TO_CHAR(month, 'Month') AS order_month,
    sub_category,
    total_revenue
FROM monthly_sales
WHERE rn = 1
ORDER BY order_month;




--What percentage of total revenue comes from the top 20% of customers?
WITH top_customers AS (
    SELECT
        o.customer_name,
        SUM(od.amount) AS total_revenue
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.customer_name
    ORDER BY total_revenue DESC
    LIMIT (SELECT COUNT(*) * 0.2 FROM orders)
)
SELECT 
    SUM(total_revenue) AS top_20_percent_revenue,
    (SELECT SUM(amount) FROM order_details) AS total_revenue,
    (SUM(total_revenue) / (SELECT SUM(amount) FROM order_details)) * 100 AS percentage
FROM top_customers;


--what products are most profitable based on their profit margin and units sold?
WITH product_profitability AS (
    SELECT
        sub_category,
        SUM(profit) AS total_profit,
        SUM(quantity) AS total_units_sold
    FROM order_details
    GROUP BY sub_category
)
SELECT 
    sub_category,
    total_profit,
    total_units_sold,
    (total_profit / total_units_sold) AS profit_margin
FROM product_profitability
ORDER BY profit_margin DESC;


--Which orders have unusually high revenue compared to the average?


WITH avg_revenue AS (
    SELECT AVG(amount) AS average_revenue
    FROM order_details
),
sub_category_revenue AS (
    SELECT
        sub_category,
        AVG(amount) AS average_revenue
    FROM order_details
    GROUP BY sub_category
)
SELECT 
    sc.sub_category,
    sc.average_revenue AS average_revenue_by_sub_category,
    ar.average_revenue AS overall_average_revenue
FROM sub_category_revenue sc
CROSS JOIN avg_revenue ar
WHERE sc.average_revenue > ar.average_revenue
ORDER BY sc.average_revenue DESC;



--Which customers made purchases in multiple months (retention)?
SELECT
    customer_name,
    COUNT(DISTINCT DATE_TRUNC('month', order_date)) AS months_purchased
FROM orders 
GROUP BY customer_name
HAVING COUNT(DISTINCT DATE_TRUNC('month', order_date)) > 1;



--What is the 7‑day moving average of total quantity sold?
SELECT
    o.order_date,
    SUM(od.quantity) AS total_quantity_sold,
    AVG(SUM(od.quantity)) OVER (ORDER BY o.order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_average_7day
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY o.order_date
ORDER BY o.order_date;

--Which sub‑categories consistently produce negative profit across multiple months?
WITH neg AS (
    SELECT
        od.sub_category,
        DATE_TRUNC('month', o.order_date) AS order_month
    FROM order_details od
    JOIN orders o USING (order_id)
    WHERE od.is_negative_profit = TRUE
)
SELECT
    sub_category,
    COUNT(DISTINCT order_month) AS months_with_negative_profit
FROM neg
GROUP BY sub_category
HAVING COUNT(DISTINCT order_month) > 1
ORDER BY months_with_negative_profit DESC;



--Which orders have the highest ratio of negative profit to total revenue?

WITH order_totals AS (
    SELECT
        order_id,
        SUM(amount) AS total_revenue,
        SUM(CASE WHEN is_negative_profit = TRUE THEN profit ELSE 0 END) AS total_negative_profit
    FROM order_details
    GROUP BY order_id
),
ratios AS (
    SELECT
        order_id,
        total_revenue,
        total_negative_profit,
        (total_negative_profit / total_revenue) AS negative_profit_ratio
    FROM order_totals
)

SELECT
    order_id,
    total_revenue,
    total_negative_profit,
    negative_profit_ratio
FROM ratios
ORDER BY negative_profit_ratio;


--month over month revenue change
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_date) As month,
        SUM(od.amount) AS total_revenue
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY month
)
SELECT
    TO_CHAR(month, 'Month') AS order_month,
    total_revenue,
    total_revenue - LAG(total_revenue) OVER (ORDER BY month) AS revenue_change
FROM monthly_revenue;



--top sub-category by total quantity sold each month
SELECT TO_CHAR(month, 'Month') AS month, sub_category, total_qty
FROM (
    SELECT
        DATE_TRUNC('month', o.order_date) as month,
        od.sub_category,
        SUM(od.quantity) AS total_qty,
        ROW_NUMBER() OVER (
                PARTITION BY DATE_TRUNC('month', o.order_date)
            ) AS rn
        FROM orders o 
        JOIN order_details od USING (order_id)
        GROUP BY month, od.sub_category
        ) AS t
WHERE rn = 1


--Which customers purchased the most negative‑profit items? ranked
WITH customers_with_most_negative_profits AS (
    SELECT
        o.customer_name,
        COUNT(*) AS number_of_neg_items,
        SUM(od.profit) AS total_negative_profit
    FROM orders o
    JOIN order_details od USING (order_id)
    WHERE od.is_negative_profit = TRUE
    GROUP BY o.customer_name
    ORDER BY total_negative_profit DESC
)
SELECT
    customer_name,
    number_of_neg_items,
    total_negative_profit,
    RANK() OVER (ORDER BY total_negative_profit) AS rank
FROM customers_with_most_negative_profits;



--Which categories have the highest percentage of negative‑profit transactions?
WITH percentage_of_negative_profits_by_category AS (
    SELECT category,
        SUM(
            CASE
                WHEN is_negative_profit = TRUE THEN profit
                ELSE 0
            END
        ) AS total_negative_profit,
        COUNT(
            CASE
                WHEN is_negative_profit = TRUE THEN 1
                ELSE 0
            END
        ) AS number_of_negative_profits,
        COUNT(*) AS total_transactions
    FROM order_details
    GROUP BY category
)
SELECT category,
    total_negative_profit,
    (
        number_of_negative_profits::numeric / total_transactions
    ) * 100 AS negative_transaction_percentage
FROM percentage_of_negative_profits_by_category;

--Which categories have the highest percentage of negative‑profit transactions?
WITH percentage_of_negative_profits_by_category AS (
    SELECT
        category,
        SUM(CASE WHEN is_negative_profit = TRUE THEN profit ELSE 0 END) AS total_negative_profit,
        SUM(CASE WHEN is_negative_profit = TRUE THEN 1 ELSE 0 END) AS number_of_negative_profits,
        COUNT(*) AS total_transactions
    FROM order_details
    GROUP BY category
)
SELECT
    category,
    total_negative_profit,
    ROUND(
        (number_of_negative_profits::numeric / total_transactions) * 100, 2) AS negative_transaction_percentage
FROM percentage_of_negative_profits_by_category;

--which categories failed to meet monthly targets?
WITH monthly_targets AS (
    SELECT
        od.category,
        DATE_TRUNC('month', o.order_date) AS order_month,
        st.target,
        SUM(od.amount) AS total_revenue
    FROM orders o
    JOIN order_details od USING (order_id)
    JOIN sales_target st ON DATE_TRUNC('month', o.order_date) = DATE_TRUNC('month', st.month_of_order_date)
    GROUP BY od.category, order_month, st.target
)

SELECT
    category,
    TO_CHAR(order_month, 'Month') AS order_month,
    total_revenue,
    target,
    CASE
        WHEN total_revenue > target THEN 'Above Target'
        WHEN total_revenue = target THEN 'At Target'
        ELSE 'Below Target'
    END AS target_status
FROM monthly_targets
ORDER BY order_month;



SELECT * from orders limit 5;
SELECT * FROM order_details LIMIT 5;
SELECT * FROM sales_target;


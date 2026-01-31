USE company_analytics;

-- ===========================================
-- 1. Basic SELECT + ORDER BY + LIMIT
-- ===========================================
-- List the 5 highest-paid employees

SELECT
    emp_id,
    first_name,
    last_name,
    salary
FROM employees
ORDER BY salary DESC
LIMIT 5;

-- ===========================================
-- 2. WHERE with multiple conditions (AND/OR/IN/BETWEEN)
-- ===========================================
-- Employees hired in 2023 or later, in Sales or Engineering

SELECT
    emp_id,
    first_name,
    last_name,
    salary,
    hire_date
FROM employees
WHERE hire_date >= '2023-01-01'
    AND dept_id IN (
      SELECT dept_id FROM departments
      WHERE dept_name IN ('Sales', 'Engineering')
  )
ORDER BY hire_date;

-- ===========================================
-- 3. INNER JOIN employees + departments + offices
-- ===========================================
-- Show each employee with department and office city

SELECT
    e.emp_id,
    e.first_name,
    e.last_name,
    d.dept_name,
    o.city     AS office_city,
    o.country  AS office_country
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN offices o     ON e.office_id = o.office_id
ORDER BY d.dept_name, e.last_name;


-- ===========================================
-- 4. Aggregate + GROUP BY:
--    total net revenue per client
-- ===========================================
-- net_revenue = quantity * unit_price * (1 - discount_pct/100)

SELECT
    c.client_id,
    c.client_name,
    SUM(quantity * unit_price * (1 - discount_pct / 100.0)) AS total_revenue
FROM sales s
JOIN clients c ON s.client_id = c.client_id
WHERE s.status = 'WON'
GROUP BY c.client_id, c.client_name
ORDER BY total_revenue DESC;


-- ===========================================
-- 5. GROUP BY + HAVING
-- ===========================================
-- Clients with total revenue above 25,000

SELECT
    c.client_name,
    ROUND(SUM(s.quantity * s.unit_price * (1 - s.discount_pct / 100.0)), 2) AS total_revenue
FROM sales s
JOIN clients c ON s.client_id = c.client_id
WHERE s.status = 'WON'
GROUP BY c.client_name
HAVING total_revenue > 15000
ORDER BY total_revenue DESC;


-- ===========================================
-- 6. COUNT(*) and COUNT(DISTINCT)
-- ===========================================
-- How many clients per industry, and how many distinct countries they come from

SELECT
    industry,
    COUNT(*)              AS num_clients,
    COUNT(DISTINCT country) AS num_countries
FROM clients
GROUP BY industry
ORDER BY num_clients DESC;


-- ===========================================
-- 7. LEFT JOIN + IS NULL:
--    clients with NO sales
-- ===========================================

SELECT
    c.client_id,
    c.client_name,
    c.industry
FROM clients c
LEFT JOIN sales s ON c.client_id = s.client_id
WHERE s.sale_id IS NULL
ORDER BY c.client_name;


-- ===========================================
-- 8. Scalar subquery:
--    employees above their department average salary
-- ===========================================

SELECT
    e.emp_id,
    e.first_name,
    e.last_name,
    d.dept_name,
    e.salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.dept_id = e.dept_id
)
ORDER BY d.dept_name, e.salary DESC;


-- ===========================================
-- 9. Correlated subquery + EXISTS:
--    clients with more than 2 WON sales
-- ===========================================

SELECT
    c.client_id,
    c.client_name
FROM clients c
WHERE EXISTS (
    SELECT 1
    FROM sales s
    WHERE s.client_id = c.client_id
      AND s.status = 'WON'
    GROUP BY s.client_id
    HAVING COUNT(*) > 2
)
ORDER BY c.client_name;


-- ===========================================
-- 10. Date functions:
--     monthly revenue by year/month
-- ===========================================

SELECT
    YEAR(sale_date) AS year,
    MONTH(sale_date) AS month,
    SUM(quantity * unit_price * (1 - discount_pct / 100.0)) AS total_revenue
FROM sales
WHERE status = 'WON'
GROUP BY YEAR(sale_date), MONTH(sale_date)
ORDER BY year, month;


-- ===========================================
-- 11. CASE expression:
--     summarize pipeline by status group
-- ===========================================

SELECT
    CASE
        WHEN status = 'WON' THEN 'Closed Won'
        WHEN status = 'LOST' THEN 'Closed Lost'
        ELSE 'Open'
    END AS status_group,
    COUNT(*) AS num_deals,
    SUM(quantity * unit_price * (1 - discount_pct / 100.0)) AS total_value
FROM sales
GROUP BY status_group
ORDER BY num_deals DESC;


-- ===========================================
-- 12. Self JOIN + COALESCE:
--     employees with their manager names
-- ===========================================

SELECT
    e.emp_id,
    e.first_name,
    e.last_name,
    COALESCE(CONCAT(m.first_name, ' ', m.last_name), 'No manager') AS manager_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id
ORDER BY manager_name, e.last_name;


-- ===========================================
-- 13. Window function:
--     rank employees by total revenue (RANK)
-- ===========================================

WITH employee_revenue AS (
    SELECT
        e.emp_id,
        e.first_name,
        e.last_name,
        SUM(CASE WHEN s.status = 'WON'
                 THEN quantity * unit_price * (1 - discount_pct / 100.0)
                 ELSE 0 END) AS total_revenue
    FROM employees e
    LEFT JOIN sales s ON e.emp_id = s.emp_id
    GROUP BY e.emp_id, e.first_name, e.last_name
)
SELECT
    emp_id,
    first_name,
    last_name,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM employee_revenue
ORDER BY revenue_rank;


-- ===========================================
-- 14. Window function:
--     running total of revenue per client over time
-- ===========================================

SELECT
    c.client_name,
    s.sale_date,
    quantity * unit_price * (1 - discount_pct / 100.0) AS deal_value,
    SUM(quantity * unit_price * (1 - discount_pct / 100.0))
        OVER (PARTITION BY c.client_id ORDER BY s.sale_date) AS running_total
FROM sales s
JOIN clients c ON s.client_id = c.client_id
WHERE s.status = 'WON'
ORDER BY c.client_name, s.sale_date;


-- ===========================================
-- 15. CTE:
--     top client by revenue per year
-- ===========================================

WITH client_year_revenue AS (
    SELECT
        YEAR(sale_date) AS year,
        c.client_id,
        c.client_name,
        SUM(quantity * unit_price * (1 - discount_pct / 100.0)) AS total_revenue
    FROM sales s
    JOIN clients c ON s.client_id = c.client_id
    WHERE s.status = 'WON'
    GROUP BY YEAR(sale_date), c.client_id, c.client_name
),
ranked AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY year ORDER BY total_revenue DESC) AS rnk
    FROM client_year_revenue
)
SELECT
    year,
    client_name,
    total_revenue
FROM ranked
WHERE rnk = 1
ORDER BY year;


-- ===========================================
-- 16. UNION: employees vs clients in Serbia
-- ===========================================

SELECT
    'Employee' AS entity_type,
    e.emp_id   AS id,
    CONCAT(e.first_name, ' ', e.last_name) AS name,
    o.city,
    o.country
FROM employees e
JOIN offices o ON e.office_id = o.office_id
WHERE o.country = 'Serbia'

UNION ALL

SELECT
    'Client' AS entity_type,
    c.client_id AS id,
    c.client_name AS name,
    NULL AS city,
    c.country
FROM clients c
WHERE c.country = 'Serbia'
ORDER BY entity_type, name;


-- ===========================================
-- 17. VIEW: reusable summarized data
-- ===========================================
-- Create a view summarizing revenue per client.

CREATE OR REPLACE VIEW client_revenue_summary AS
SELECT
    c.client_id,
    c.client_name,
    SUM(CASE WHEN s.status = 'WON'
             THEN quantity * unit_price * (1 - discount_pct / 100.0)
             ELSE 0 END) AS total_revenue,
    COUNT(*) AS num_deals
FROM clients c
LEFT JOIN sales s ON c.client_id = s.client_id
GROUP BY c.client_id, c.client_name;

-- Use the view
SELECT *
FROM client_revenue_summary
ORDER BY total_revenue DESC;


-- ===========================================
-- 18. IN vs EXISTS (simple example)
-- ===========================================
-- Clients that have at least one WON sale (IN version)

SELECT
    client_id,
    client_name
FROM clients
WHERE client_id IN (
    SELECT DISTINCT client_id
    FROM sales
    WHERE status = 'WON'
);

-- Same logic using EXISTS

SELECT
    c.client_id,
    c.client_name
FROM clients c
WHERE EXISTS (
    SELECT 1
    FROM sales s
    WHERE s.client_id = c.client_id
      AND s.status = 'WON'
);


-- ===========================================
-- 19. GROUP BY with multiple dimensions:
--     revenue by employee and status
-- ===========================================

SELECT
    e.emp_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    s.status,
    COUNT(*) AS num_deals,
    SUM(quantity * unit_price * (1 - discount_pct / 100.0)) AS total_value
FROM sales s
JOIN employees e ON s.emp_id = e.emp_id
GROUP BY e.emp_id, employee_name, s.status
ORDER BY employee_name, s.status;


-- ===========================================
-- 20. Simple TEXT search with LIKE
-- ===========================================
-- Find clients whose name contains the word 'City' (case-insensitive depending on collation)

SELECT
    client_id,
    client_name,
    industry
FROM clients
WHERE client_name LIKE '%City%'
ORDER BY client_name;

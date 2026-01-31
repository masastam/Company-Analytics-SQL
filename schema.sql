-- =========================================
-- 01_schema.sql
-- Company Sales & Employee Analytics (MySQL)
-- =========================================

USE company_analytics;
DROP TABLE IF EXISTS
  sales,
  products,
  clients,
  employees,
  offices,
  departments;

-- ---------- departments ----------
CREATE TABLE departments (
  dept_id INT AUTO_INCREMENT PRIMARY KEY,
  dept_name VARCHAR(50) NOT NULL UNIQUE
);

-- ---------- offices ----------
CREATE TABLE offices (
  office_id INT AUTO_INCREMENT PRIMARY KEY,
  city VARCHAR(50) NOT NULL,
  country VARCHAR(50) NOT NULL
);

-- ---------- employees ----------
CREATE TABLE employees (
  emp_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name  VARCHAR(50) NOT NULL,
  email VARCHAR(100) UNIQUE,
  dept_id INT,
  office_id INT,
  manager_id INT,
  salary INT NOT NULL,
  hire_date DATE NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,

  CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE SET NULL,
  CONSTRAINT fk_emp_office FOREIGN KEY (office_id) REFERENCES offices(office_id) ON DELETE SET NULL,
  CONSTRAINT fk_emp_manager FOREIGN KEY (manager_id) REFERENCES employees(emp_id) ON DELETE SET NULL
);

-- ---------- clients ----------
CREATE TABLE clients (
  client_id INT AUTO_INCREMENT PRIMARY KEY,
  client_name VARCHAR(100) NOT NULL,
  industry VARCHAR(50) NOT NULL,
  country VARCHAR(50) NOT NULL,
  created_at DATE NOT NULL
);

-- ---------- products ----------
CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  product_name VARCHAR(100) NOT NULL,
  category VARCHAR(50) NOT NULL,
  list_price DECIMAL(10,2) NOT NULL
);

-- ---------- sales ----------
CREATE TABLE sales (
  sale_id INT AUTO_INCREMENT PRIMARY KEY,
  sale_date DATE NOT NULL,
  emp_id INT,
  client_id INT,
  product_id INT,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  discount_pct DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  status ENUM('WON','LOST','PENDING') NOT NULL,

  CONSTRAINT fk_sales_emp FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE SET NULL,
  CONSTRAINT fk_sales_client FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE SET NULL,
  CONSTRAINT fk_sales_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE SET NULL
);

SHOW TABLES;

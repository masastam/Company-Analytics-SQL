USE company_analytics;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE sales;
TRUNCATE TABLE employees;
TRUNCATE TABLE clients;
TRUNCATE TABLE departments;
TRUNCATE TABLE offices;

SET FOREIGN_KEY_CHECKS = 1;
    
INSERT INTO departments (dept_name) VALUES
('Sales'),
('Engineering'),
('Marketing'),
('HR'),
('Finance');

INSERT INTO offices (city, country) VALUES
('Belgrade', 'Serbia'),
('Novi Sad', 'Serbia'),
('Berlin', 'Germany'),
('London', 'UK');

INSERT INTO employees (first_name, last_name, email, dept_id, office_id, manager_id, salary, hire_date, is_active) VALUES
('Milos',  'Nikolic',  'milos.nikolic@company.com', 1, 1, NULL, 1800, '2023-03-01', 1),
('Ana',    'Jovic',    'ana.jovic@company.com',     2, 3, NULL, 2600, '2022-09-15', 1),
('Ivan',   'Petrovic', 'ivan.petrovic@company.com', 3, 4, NULL, 2100, '2023-01-10', 1),
('Sara',   'Kovacevic','sara.kovacevic@company.com',4, 1, NULL, 1700, '2022-11-20', 1),
('Marko',  'Ilic',     'marko.ilic@company.com',    5, 3, NULL, 2400, '2022-06-05', 1),
('Jelena', 'Stojanovic','jelena.stojanovic@company.com', 1, 1, 1, 1500, '2023-07-12', 1),
('Nikola', 'Simic',     'nikola.simic@company.com',      1, 2, 1, 1400, '2024-02-01', 1),
('Mina',   'Vukovic',   'mina.vukovic@company.com',      2, 3, 2, 2300, '2023-10-03', 1),
('Luka',   'Djordjevic','luka.djordjevic@company.com',   2, 1, 2, 2200, '2024-05-18', 1),
('Teodora','Savic',     'teodora.savic@company.com',     3, 4, 3, 1900, '2024-03-22', 1),
('Petar',  'Matic',     'petar.matic@company.com',      1, 4, 1, 1550, '2023-09-02', 0);

INSERT INTO clients (client_name, industry, country, created_at) VALUES
('Logistics Company',  'Logistics',   'Serbia',  '2023-01-15'),
('City Hotels',        'Hospitality', 'Germany', '2023-02-10'),
('Medical Clinic',     'Healthcare',  'UK',      '2023-05-08'),
('City Bank',          'Finance',     'Serbia',  '2023-06-21'),
('Retail Group',       'Retail',      'UK',      '2023-09-12'),
('Learning Centar',    'Education',   'Germany', '2024-01-03'),
('Wellness Spa',       'Wellness',    'Serbia',  '2024-04-30');

INSERT INTO products (product_name, category, list_price) VALUES
('Sales Analytics Suite',      'Software',  11000.00),
('Data Integration Service',   'Service',    7500.00),
('Enterprise Data Warehouse',  'Software',  19500.00),
('Monitoring & Alerting Tool', 'Software',   5800.00),
('Business Consulting Package','Service',    3200.00);

INSERT INTO sales (sale_date, emp_id, client_id, product_id, quantity, unit_price, discount_pct, status) VALUES
('2024-01-12', 1, 1, 1, 1, 11000.00,  0.00, 'WON'),      -- Logistics Company
('2024-01-25', 6, 2, 2, 1,  7500.00, 10.00, 'WON'),      -- City Hotels
('2024-02-10', 7, 3, 5, 2,  3200.00,  0.00, 'LOST'),     -- Medical Clinic
('2024-02-18', 1, 4, 3, 1, 19500.00,  5.00, 'WON'),      -- City Bank
('2024-03-05', 6, 5, 1, 1, 11000.00, 15.00, 'WON'),      -- Retail Group
('2024-03-14', 7, 2, 4, 2,  5800.00,  0.00, 'PENDING'),  -- City Hotels
('2024-04-02', 1, 6, 3, 1, 19500.00,  0.00, 'LOST'),     -- Learning Centar
('2024-04-20', 6, 7, 5, 3,  3200.00,  0.00, 'WON'),      -- Wellness Spa
('2024-05-11', 7, 1, 2, 1,  7500.00,  0.00, 'WON'),      -- Logistics Company
('2024-06-01', 6, 6, 1, 1, 11000.00,  0.00, 'WON'),      -- Learning Centar
('2024-06-15', 1, 3, 4, 1,  5800.00, 10.00, 'WON'),      -- Medical Clinic
('2024-07-09', 7, 4, 5, 2,  3200.00,  5.00, 'WON'),      -- City Bank
('2024-08-22', 6, 5, 2, 1,  7500.00,  0.00, 'PENDING');  -- Retail Group


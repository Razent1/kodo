--Dimension Tables
--dim_customers - Contains details about customers.
CREATE TABLE dim_customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(255),
    company VARCHAR(50)
);

--dim_time - Contains date and time attributes for analysis.
CREATE TABLE dim_time (
    time_id INT NOT NULL PRIMARY KEY,
    date DATE,
    year SMALLINT,
    quarter SMALLINT,
    month SMALLINT,
    day SMALLINT,
    weekday VARCHAR(9)
);

--dim_shipping - Contains information about the shipping status.
CREATE TABLE dim_shipping (
    shipping_id INT NOT NULL PRIMARY KEY,
    tracking_code VARCHAR(255),
    shipping_status VARCHAR(255)
);

--dim_billing - Contains information about billing
CREATE TABLE dim_billing (
    billing_id INT NOT NULL PRIMARY KEY,
    payment_method VARCHAR(255),
    payment_status VARCHAR(255)
);

----dim_address - Contains information about the add.
CREATE TABLE dim_address (
    address_id INT NOT NULL PRIMARY KEY,
    street VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20),
    country VARCHAR(100)
);


--Fact Table
--The fact_orders table records each transaction, including foreign keys to the dimension tables and measures like amount.
CREATE TABLE fact_orders (
    order_id INT NOT NULL PRIMARY KEY,
    customer_id INT,
    product_id INT,
    time_id INT,
    shipping_id INT,
    address_id INT,
    billing_id INT,
    amount DECIMAL(10, 2),
    currency VARCHAR(255),
    order_status VARCHAR(255),
    FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id),
    FOREIGN KEY (time_id) REFERENCES dim_time(time_id),
    FOREIGN KEY (shipping_id) REFERENCES dim_shipping(shipping_id),
    FOREIGN KEY (address_id) REFERENCES dim_address(address_id),
    FOREIGN KEY (billing_id) REFERENCES dim_billing(billing_id)
);


--Examples of queries
-- Number of Orders and Total Sales by Date
SELECT
    t.date,
    COUNT(f.order_id) AS number_of_orders,
    SUM(f.amount) AS total_sales
FROM
    fact_orders f
JOIN
    dim_time t ON f.time_id = t.time_id
WHERE
    t.year = 2023 AND t.month = 1
GROUP BY
    t.date
ORDER BY
    t.date;

--This query estimates the Customer Lifetime Value based on total sales per customer.
SELECT
    c.customer_id,
    c.name AS customer_name,
    SUM(f.amount) AS total_spent,
    COUNT(DISTINCT f.order_id) AS total_orders
FROM
    fact_orders f
JOIN
    dim_customers c ON f.customer_id = c.customer_id
GROUP BY
    c.customer_id, c.name
ORDER BY
    total_spent DESC;

--This query calculates the average order value for each company.
SELECT
    c.company,
    AVG(f.amount) AS average_order_value
FROM
    fact_orders f
JOIN
    dim_customers c ON f.customer_id = c.customer_id
GROUP BY
    c.company;

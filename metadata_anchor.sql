--Anchors
--Auto-incrementing IDs:
-- These are used here for simplicity. Depending on your database system, you might use sequences or other mechanisms to generate unique identifiers.
CREATE TABLE order_anchor (
    order_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY
);

CREATE TABLE customer_anchor (
    customer_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY
);

CREATE TABLE address_anchor (
    address_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY
);

CREATE TABLE billing_anchor (
    billing_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY
);

--Attributes for Orders

CREATE TABLE order_amount (
    order_amount_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    order_id INT,
    amount DECIMAL(10,2),
    valid_from TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    FOREIGN KEY (order_id) REFERENCES order_anchor(order_id)
);

CREATE TABLE order_currency (
    order_currency_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    order_id INT,
    currency VARCHAR(3),
    valid_from TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    FOREIGN KEY (order_id) REFERENCES order_anchor(order_id)
);

CREATE TABLE order_status (
    order_status_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    order_id INT,
    order_status VARCHAR(255),
    valid_from TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    FOREIGN KEY (order_id) REFERENCES order_anchor(order_id)
);

--Attributes for Customers

CREATE TABLE customer_name (
    customer_name_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    customer_id INT,
    name VARCHAR(255),
    valid_from TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    FOREIGN KEY (customer_id) REFERENCES customer_anchor(customer_id)
);

CREATE TABLE customer_company (
    customer_company_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    customer_id INT,
    company VARCHAR(255),
    valid_from TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    FOREIGN KEY (customer_id) REFERENCES customer_anchor(customer_id)
);

--Attributes for Addresses
CREATE TABLE address_name (
    address_name_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    address_id INT,
    name VARCHAR(255),
    valid_from TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    FOREIGN KEY (address_id) REFERENCES address_anchor(address_id)
);

CREATE TABLE address_street (
    address_street_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    address_id INT,
    street VARCHAR(255),
    valid_from TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    FOREIGN KEY (address_id) REFERENCES address_anchor(address_id)
);

CREATE TABLE address_zip_code (
    address_zip_code_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    address_id INT,
    zip_code VARCHAR(10),
    valid_from TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    FOREIGN KEY (address_id) REFERENCES address_anchor(address_id)
);

CREATE TABLE address_city (
    address_city_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    address_id INT,
    city VARCHAR(255),
    valid_from TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    FOREIGN KEY (address_id) REFERENCES address_anchor(address_id)
);

CREATE TABLE address_country (
    address_country_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    address_id INT,
    country VARCHAR(255),
    valid_from TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    FOREIGN KEY (address_id) REFERENCES address_anchor(address_id)
);

--Attributes for Billing

CREATE TABLE billing_payment_method (
    billing_payment_method_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    billing_id INT,
    method VARCHAR(255),
    valid_from TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    FOREIGN KEY (billing_id) REFERENCES billing_anchor(billing_id)
);

CREATE TABLE billing_payment_status (
    billing_payment_status_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    billing_id INT,
    status VARCHAR(255),
    valid_from TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    FOREIGN KEY (billing_id) REFERENCES billing_anchor(billing_id)
);

--Ties

CREATE TABLE order_customer_tie (
    order_customer_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    order_id INT,
    customer_id INT,
    valid_from TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    FOREIGN KEY (order_id) REFERENCES order_anchor(order_id),
    FOREIGN KEY (customer_id) REFERENCES customer_anchor(customer_id)
);

CREATE TABLE order_address_tie (
    order_address_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    order_id INT,
    address_id INT,
    valid_from TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    FOREIGN KEY (order_id) REFERENCES order_anchor(order_id),
    FOREIGN KEY (address_id) REFERENCES address_anchor(address_id)
);

CREATE TABLE order_billing_tie (
    order_billing_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    order_id INT,
    billing_id INT,
    valid_from TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    FOREIGN KEY (order_id) REFERENCES order_anchor(order_id),
    FOREIGN KEY (billing_id) REFERENCES billing_anchor(billing_id)
);

CREATE TABLE address_billing_tie (
    address_billing_id INT NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    address_id INT,
    billing_id INT,
    valid_from TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    FOREIGN KEY (address_id) REFERENCES address_anchor(address_id),
    FOREIGN KEY (billing_id) REFERENCES billing_anchor(billing_id)
);

--Examples of queries

--Assuming there's a tie between orders and addresses for shipping, this query fetches the shipping address details for orders.

SELECT
    o.order_id,
    address_street.street,
    address_city.city,
    address_country.country
FROM
    order_anchor o
JOIN
    order_address_tie oat ON o.order_id = oat.order_id  AND oat.valid_to > CURRENT_TIMESTAMP
JOIN
    address_street ON oat.address_id = address_street.address_id AND address_street.valid_to > CURRENT_TIMESTAMP
JOIN
    address_city ON  oat.address_id = address_city.address_id AND address_city.valid_to > CURRENT_TIMESTAMP
JOIN
    address_country ON oat.address_id = address_country.address_id AND address_country.valid_to > CURRENT_TIMESTAMP;

--This query estimates the Customer Lifetime Value by summing up all sales amounts associated with each customer.

SELECT
    c.customer_id,
    SUM(oa.amount) AS lifetime_value
FROM
    customer_anchor c
JOIN
    order_customer_tie oct ON c.customer_id = oct.customer_id AND oct.valid_to > CURRENT_TIMESTAMP
JOIN
    order_amount oa ON oct.order_id = oa.order_id AND oa.valid_to > CURRENT_TIMESTAMP
GROUP BY
    c.customer_id
ORDER BY
    lifetime_value DESC;





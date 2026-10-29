use inventory_management;
CREATE TABLE dim_date (
    date_key      INT PRIMARY KEY,          -- format YYYYMMDD
    full_date     DATE NOT NULL,
    day           TINYINT,
    day_name      VARCHAR(10),
    week          TINYINT,
    month         TINYINT,
    month_name    VARCHAR(15),
    quarter       VARCHAR(2),
    year          SMALLINT,
    is_weekend    TINYINT
);
 
-- DIM REGION -----------------------------------------------------------------
CREATE TABLE dim_region (
    region_key   INT AUTO_INCREMENT PRIMARY KEY,
    region_name  VARCHAR(50) UNIQUE NOT NULL
);
 
-- DIM PRODUCT (Category + Supplier combo, since dataset has category-level granularity)
CREATE TABLE dim_product (
    product_key  INT AUTO_INCREMENT PRIMARY KEY,
    category     VARCHAR(50) NOT NULL,
    supplier     VARCHAR(50) NOT NULL,
    UNIQUE KEY uq_product (category, supplier)
);
 
-- DIM WAREHOUSE ---------------------------------------------------------------
CREATE TABLE dim_warehouse (
    warehouse_key   INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_name  VARCHAR(50) UNIQUE NOT NULL,
    warehouse_capacity INT          -- snapshot/avg capacity (also kept in fact for trend)
);

 
CREATE TABLE fact_inventory_orders (
    fact_id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    date_key             INT NOT NULL,
    region_key           INT NOT NULL,
    product_key          INT NOT NULL,
    warehouse_key        INT NOT NULL,
 
    order_status         VARCHAR(50),
    order_accuracy_flag  TINYINT,        -- 1 = TRUE, 0 = FALSE
    backorder_flag       TINYINT,        -- 1 = TRUE, 0 = FALSE
 
    units_sold           INT,
    inventory_level      INT,
    transportation_cost  DECIMAL(10,6),
    lead_time_days       INT,
    cost_of_goods_sold   DECIMAL(12,2),
    average_inventory    DECIMAL(10,4),
    warehouse_capacity   INT,
 
    CONSTRAINT fk_fact_date      FOREIGN KEY (date_key)      REFERENCES dim_date(date_key),
    CONSTRAINT fk_fact_region    FOREIGN KEY (region_key)    REFERENCES dim_region(region_key),
    CONSTRAINT fk_fact_product   FOREIGN KEY (product_key)   REFERENCES dim_product(product_key),
    CONSTRAINT fk_fact_warehouse FOREIGN KEY (warehouse_key) REFERENCES dim_warehouse(warehouse_key)
);

INSERT INTO dim_region (region_name)
SELECT DISTINCT region FROM inventory_supplychain;
 
-- Populate dim_product
INSERT INTO dim_product (category, supplier)
SELECT DISTINCT category, supplier FROM inventory_supplychain;
 
-- Populate dim_warehouse (avg capacity per warehouse used as reference attribute)
INSERT INTO dim_warehouse (warehouse_name, warehouse_capacity)
SELECT warehouse, ROUND(AVG(warehouse_capacity))
FROM inventory_supplychain
GROUP BY warehouse;
 
-- Populate dim_date (driven from distinct order dates in staging)
INSERT INTO dim_date (date_key, full_date, day, day_name, week, month, month_name, quarter, year, is_weekend)
SELECT
    CAST(DATE_FORMAT(order_date,'%Y%m%d') AS UNSIGNED) AS date_key,
    order_date,
    DAY(order_date),
    DAYNAME(order_date),
    WEEK(order_date),
    MONTH(order_date),
    MONTHNAME(order_date),
    CONCAT('Q', QUARTER(order_date)),
    YEAR(order_date),
    IF(DAYOFWEEK(order_date) IN (1,7), 1, 0)
FROM (SELECT DISTINCT order_date FROM inventory_supplychain) d;
 
 

INSERT INTO fact_inventory_orders (
    date_key, region_key, product_key, warehouse_key,
    order_status, order_accuracy_flag, backorder_flag,
    units_sold, inventory_level, transportation_cost,
    lead_time_days, cost_of_goods_sold, average_inventory, warehouse_capacity
)
SELECT
    CAST(DATE_FORMAT(s.order_date,'%Y%m%d') AS UNSIGNED),
    r.region_key,
    p.product_key,
    w.warehouse_key,
    s.order_status,
    IF(s.order_accuracy = 'TRUE', 1, 0),
    IF(s.backorder = 'TRUE', 1, 0),
    s.units_sold,
    s.inventory_level,
    s.transportation_cost,
    s.lead_time_days,
    s.cost_of_goods_sold,
    s.average_inventory,
    s.warehouse_capacity
FROM inventory_supplychain s
JOIN dim_region    r ON r.region_name = s.region
JOIN dim_product   p ON p.category = s.category AND p.supplier = s.supplier
JOIN dim_warehouse w ON w.warehouse_name = s.warehouse;


 
 
 
CREATE TABLE IF NOT EXISTS firstaid_stock (
    zone_name VARCHAR(50) NOT NULL,
    item_name VARCHAR(50) NOT NULL,
    stock INT NOT NULL,
    PRIMARY KEY (zone_name, item_name)
);

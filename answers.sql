Answer 1:
USE exampledb;

-- Original table
CREATE TABLE ProductDetail (
  OrderID INT,
  CustomerName VARCHAR(50),
  Products VARCHAR(255)
);

-- Insert sample data into ProductDetail
INSERT INTO ProductDetail (OrderID, CustomerName, Products) VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

USE exampledb;

-- Create the Orders table with CustomerName fully dependent on OrderID
-- to eliminate transitive dependency
CREATE TABLE Orders (
  OrderID INT PRIMARY KEY,
  CustomerName VARCHAR(50)
);

USE exampledb;

-- Create the new OrderProducts table (with composite primary key on OrderID and Product)
-- to eliminate transitive dependency
CREATE TABLE OrderProducts (
  OrderProductID INT AUTO_INCREMENT PRIMARY KEY,
  OrderID INT,
  Product VARCHAR(50),
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

USE exampledb;

-- Insert distinct order data into the Orders table to eliminate partial dependency
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM ProductDetail;

USE exampledb;

-- The CONCAT combined with REPLACE converts the comma-separated product list into a valid JSON array.
-- JSON_TABLE then converts that JSON array into a table. Each element is extracted as a separate row (alias jt.product).
-- This query will output one row per product per order, effectively normalizing the data into 1NF.
SELECT OrderID, CustomerName, jt.product AS Product
FROM ProductDetail,
JSON_TABLE(
CONCAT('["', REPLACE(Products, ', ', '","'),'"]'),
"$[*]" 
COLUMNS (product VARCHAR(50) PATH "$")
) AS jt;



Answer 2:

USE example;

-- Create the original OrderDetails table in 1NF
CREATE TABLE OrderDetails1NF (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    Quantity INT
);

USE example;

-- Insert sample data into OrderDetails1NF
INSERT INTO OrderDetails1NF (OrderID, CustomerName, Product, Quantity) VALUES
(101, 'John Doe', 'Laptop', 2),
(101, 'John Doe', 'Mouse', 1),
(102, 'Jane Smith', 'Tablet', 3),
(102, 'Jane Smith', 'Keyboard', 1),
(102, 'Jane Smith', 'Mouse', 2),
(103, 'Emily Clark', 'Phone', 1);


USE example;

-- Create the Orders table with CustomerName fully dependent on OrderID
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL
);


USE example;

-- Create the new OrderDetails table (with composite primary key on OrderID and Product)
CREATE TABLE OrderDetails (
    OrderID INT,
    Product VARCHAR(100) NOT NULL,
    Quantity INT NOT NULL,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);


USE example;

-- Insert distinct order data into the Orders table to eliminate partial dependency
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails1NF;


USE example;

-- Insert data into the new OrderDetails table with details of each order item
INSERT INTO OrderDetails (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails1NF;

USE example;

-- Optional: Verify the data inserted into Orders and OrderDetails
SELECT * FROM Orders;
SELECT * FROM OrderDetails;


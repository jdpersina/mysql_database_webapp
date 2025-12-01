DROP PROCEDURE  IF EXISTS sp_resetdb;
DELIMITER //
CREATE PROCEDURE sp_resetdb()
BEGIN
    SET FOREIGN_KEY_CHECKS=0;
    SET AUTOCOMMIT = 0;

    DROP TABLE IF EXISTS CustomerInvoice_Has_FoodItems;
    DROP TABLE IF EXISTS SupplierInvoice_Has_FoodItems;
    DROP TABLE IF EXISTS CustomerInvoices;
    DROP TABLE IF EXISTS SupplierInvoices;
    DROP TABLE IF EXISTS Customers;
    DROP TABLE IF EXISTS Suppliers;
    DROP TABLE IF EXISTS FoodItems;
    DROP TABLE IF EXISTS Cultures;

    CREATE TABLE Cultures (
        cultureID INT NOT NULL PRIMARY KEY,
        cultureName VARCHAR(100) NOT NULL
    );

    CREATE TABLE FoodItems (
        foodItemID INT NOT NULL PRIMARY KEY,
        itemName VARCHAR(100),
        cultureID INT,
        FOREIGN KEY (cultureID) REFERENCES Cultures(cultureID)
    );

    CREATE TABLE Suppliers (
        supplierID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        supplierName VARCHAR(100),
        smuggler TINYINT,
        blackmailable TINYINT,
        cultureID INT,
        FOREIGN KEY (cultureID) REFERENCES Cultures(cultureID)
    );

    CREATE TABLE Customers (
        customerID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        customerName VARCHAR(100) NOT NULL,
        gullibilityRating INT,
        blackmailable INT,
        cultureID INT,
        favoriteFood INT,
        FOREIGN KEY (cultureID) REFERENCES Cultures(cultureID),
        FOREIGN KEY (favoriteFood) REFERENCES FoodItems(foodItemID)
    );

    CREATE TABLE CustomerInvoices (
        customerInvoiceID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
        customerID INT,
        FOREIGN KEY (customerID) REFERENCES Customers(customerID)
    );

    CREATE TABLE SupplierInvoices (
        supplierInvoiceID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
        supplierID INT,
        FOREIGN KEY (supplierID) REFERENCES Suppliers(supplierID)
    );

    CREATE TABLE CustomerInvoice_Has_FoodItems (
        customerInvoiceID INT NOT NULL,
        foodItemID INT NOT NULL,
        quantity INT NOT NULL,
        PRIMARY KEY (customerInvoiceID, foodItemID),
        FOREIGN KEY (customerInvoiceID) REFERENCES CustomerInvoices(customerInvoiceID),
        FOREIGN KEY (foodItemID) REFERENCES FoodItems(foodItemID)
    );

    CREATE TABLE SupplierInvoice_Has_FoodItems (
        supplierInvoiceID INT NOT NULL,
        foodItemID INT NOT NULL,
        quantity INT NOT NULL,
        PRIMARY KEY (supplierInvoiceID, foodItemID),
        FOREIGN KEY (supplierInvoiceID) REFERENCES SupplierInvoices(supplierInvoiceID),
        FOREIGN KEY (foodItemID) REFERENCES FoodItems(foodItemID)
    );


-- Do IDs by hand because this is a category table that will rarely be updated. 
INSERT INTO Cultures (cultureID, cultureName) VALUES 
    (1, 'Ferengi'),
    (2, 'Bajoran'),
    (3, 'Cardassian'),
    (4, 'Human'),
    (5, 'Trill'),
    (6, 'Klingon'),
    (7, 'Vulcan'),
    (8, 'Andorian'),
    (9, 'Orion')
;
    -- Building Food Items List. Will be creating a sort by function for Menu page
    INSERT INTO FoodItems (foodItemID, itemName, cultureID) VALUES
        (1, 'Root beer', 4),
        (2, 'Yamok sauce', 3),
        (3, 'Raktajino', 6),
        (4, 'Gagh', 6),
        (5, 'Kanar', 3),
        (6, 'Plomeek soup', 7),
        (7, 'Hasperat', 2),
        (8, 'Bloodwine', 6),
        (9, 'Tube Grubs', 1),
        (10, 'Jumja Stick', 2),
        (11, 'Andorian Ale', 8),
        (12, 'Ratampa Stew', 2),
        (13, 'Prune Juice', 4),
        (14, 'Champagne', 4),
        (15, 'Millipede Juice', 1),
        (16, 'Tea, Earl Grey, Hot', 4),
        (17, 'Peanuts & Cracker Jacks', 4),
        (18, 'Pancakes', 4),
        (19, 'Mapa Bread', 2),
        (20, 'Taspar Eggs', 3),
        (21, 'Tevmel', 7),
        (22, 'Red Spice', 7),
        (23, 'Senarian Egg Broth', 5),
        (24, 'Syto Beans', 5),
        (25, 'Kytherian Crab', 1),
        (26, 'Bacon and Eggs', 4)
    ;

    INSERT INTO Customers (customerName, gullibilityRating, blackmailable, cultureID, favoriteFood) VALUES
        ('Jadzia Dax', 2, 0, 5, 3),
        ('Miles O''Brien', 4, 0, 4, 1),
        ('Kira Nerys', 1, 0, 2, 7),
        ('Benjamin Sisko', 1, 0, 4, 3),
        ('Damar', 5, 1, 3, 5),
        ('T''Pol', 1, 0, 7, 6),
        ('Worf', 3, 0, 6, 4),
        ('Rom', 5, 1, 1, 1)
    ;

INSERT INTO Suppliers (supplierName, smuggler, blackmailable, cultureID) VALUES 
    ('Cassidy Yates', 1, 1, 4),
    ('Cousin Gaila', 1, 1, 1),
    ('Starfleet', 0, 0, 4),
    ('Orion Syndicate', 1, 0, 9)
;

INSERT INTO CustomerInvoices (customerID) VALUES
    (1),
    (1),
    (2),
    (3)
;

 INSERT INTO SupplierInvoices (supplierID) VALUES
    (3),
    (2),
    (1),
    (3)
;

INSERT INTO CustomerInvoice_Has_FoodItems (customerInvoiceID, foodItemID, quantity) VALUES 
    (1, 1, 2),
    (1, 2, 5),
    (1, 3, 10), 
    (2, 3, 1),
    (3, 1, 10)
;

INSERT INTO SupplierInvoice_Has_FoodItems (supplierInvoiceID, foodItemID, quantity) VALUES 
    (1, 1, 20),
    (1, 2, 10),
    (1, 3, 50),
    (2, 1, 5),
    (3, 2, 100),
    (4, 1, 50)
;

    SET FOREIGN_KEY_CHECKS=1;
    SET AUTOCOMMIT = 1;
COMMIT;
END //

DELIMITER ;

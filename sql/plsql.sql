-- #############################
-- RESET DB
-- #############################
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
        (6, 'Klingon')
    ;

    INSERT INTO FoodItems (foodItemID, itemName, cultureID) VALUES
        (1, 'Root beer', 4),
        (2, 'Yamok sauce', 3),
        (3, 'Raktajino', 6)
    ;

    INSERT INTO Customers (customerName, gullibilityRating, blackmailable, cultureID, favoriteFood) VALUES
        ('Jadzia Dax', 2, 3, 5, 3),
        ('Miles O''Brien', 3, 3, 4, 1),
        ('Kira Nerys', 1, 5, 2, 3)
    ;

    INSERT INTO Suppliers (supplierName, smuggler, blackmailable, cultureID) VALUES 
        ('Cassidy Yates', 1, 1, 4),
        ('Cousin Gaila', 1, 1, 1),
        ('Starfleet', 0, 0, 4)
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
COMMIT;
END //


DELIMITER ;

-- #############################
-- CREATE Customers
-- #############################
DROP PROCEDURE IF EXISTS sp_CreateCustomer;

DELIMITER //
CREATE PROCEDURE sp_CreateCustomer(
    IN p_customerName VARCHAR(100),
    IN p_gullibilityRating INT,
    IN p_blackmailable INT,
    IN p_cultureID INT,
    IN p_favoriteFood INT
)
BEGIN
    DECLARE error_message VARCHAR(255);

    -- Error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Validate foreign key references exist
        IF p_cultureID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Cultures WHERE cultureID = p_cultureID) THEN
            SET error_message = CONCAT('Invalid cultureID: ', p_cultureID, ' does not exist in Cultures table');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        IF p_favoriteFood IS NOT NULL AND NOT EXISTS (SELECT 1 FROM FoodItems WHERE foodItemID = p_favoriteFood) THEN
            SET error_message = CONCAT('Invalid favoriteFood: ', p_favoriteFood, ' does not exist in FoodItems table');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        -- Insert the new customer
        INSERT INTO Customers (customerName, gullibilityRating, blackmailable, cultureID, favoriteFood)
        VALUES (p_customerName, p_gullibilityRating, p_blackmailable, p_cultureID, p_favoriteFood);

    COMMIT;

END //
DELIMITER ;

-- #############################
-- UPDATE Customers
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateCustomer;

DELIMITER //
CREATE PROCEDURE sp_UpdateCustomer(
    IN p_customerID INT,
    IN p_customerName VARCHAR(100),
    IN p_gullibilityRating INT,
    IN p_blackmailable INT,
    IN p_cultureID INT,
    IN p_favoriteFood INT
)
BEGIN
    DECLARE error_message VARCHAR(255);

    -- Error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Validate customer exists
        IF NOT EXISTS (SELECT 1 FROM Customers WHERE customerID = p_customerID) THEN
            SET error_message = CONCAT('No matching record found in Customers for customerID: ', p_customerID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        -- Validate foreign key references exist
        IF p_cultureID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Cultures WHERE cultureID = p_cultureID) THEN
            SET error_message = CONCAT('Invalid cultureID: ', p_cultureID, ' does not exist in Cultures table');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        IF p_favoriteFood IS NOT NULL AND NOT EXISTS (SELECT 1 FROM FoodItems WHERE foodItemID = p_favoriteFood) THEN
            SET error_message = CONCAT('Invalid favoriteFood: ', p_favoriteFood, ' does not exist in FoodItems table');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        -- Update the customer
        UPDATE Customers
        SET 
            customerName = p_customerName,
            gullibilityRating = p_gullibilityRating,
            blackmailable = p_blackmailable,
            cultureID = p_cultureID,
            favoriteFood = p_favoriteFood
        WHERE customerID = p_customerID;

    COMMIT;

END //
DELIMITER ;


-- #############################
-- DELETE Customers
-- #############################
DROP PROCEDURE IF EXISTS sp_DeleteCustomer;

DELIMITER //
CREATE PROCEDURE sp_DeleteCustomer(IN p_customerID INT)
BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propagate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        -- Delete from intersection table first
        -- This removes all food items associated with customer invoices for this customer
        DELETE cihfi FROM CustomerInvoice_Has_FoodItems cihfi
        INNER JOIN CustomerInvoices ci ON cihfi.customerInvoiceID = ci.customerInvoiceID
        WHERE ci.customerID = p_customerID;
        
        -- Delete customer invoices
        DELETE FROM CustomerInvoices WHERE customerID = p_customerID;
        
        -- Delete the customer
        DELETE FROM Customers WHERE customerID = p_customerID;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found in Customers for customerID: ', p_customerID);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- Citation: Starter code provided on Canvas in: Exploration - Implementing CUD operations in your app, accessed on 2025-11-16
-- Citation: Claude LLM, accessed on 2025-11-16 with prompt: "Please update this stored procedure using data from this ddl to reflect deleting a customer [files provided]"
-- Citation: Claude LLM, accessed on 2025-11-21 with prompt: "Can you please create update and create procedures following this schema? [file provided]"
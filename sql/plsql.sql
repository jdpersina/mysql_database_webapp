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
-- UPDATE Customers (Safe Version)
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

        -- Normalize empty or invalid foreign keys to NULL
        IF p_cultureID IS NULL OR p_cultureID = 0 THEN
            SET p_cultureID = NULL;
        END IF;

        IF p_favoriteFood IS NULL OR p_favoriteFood = 0 THEN
            SET p_favoriteFood = NULL;
        END IF;

        -- Validate foreign key references exist (only if not NULL)
        IF p_cultureID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Cultures WHERE cultureID = p_cultureID) THEN
            SET error_message = CONCAT('Invalid cultureID: ', p_cultureID, ' does not exist in Cultures table');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        IF p_favoriteFood IS NOT NULL AND NOT EXISTS (SELECT 1 FROM FoodItems WHERE foodItemID = p_favoriteFood) THEN
            SET error_message = CONCAT('Invalid favoriteFood: ', p_favoriteFood, ' does not exist in FoodItems table');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        -- Update only fields that are provided
        UPDATE Customers
        SET 
            customerName = COALESCE(p_customerName, customerName),
            gullibilityRating = COALESCE(p_gullibilityRating, gullibilityRating),
            blackmailable = COALESCE(p_blackmailable, blackmailable),
            cultureID = COALESCE(p_cultureID, cultureID),
            favoriteFood = COALESCE(p_favoriteFood, favoriteFood)
        WHERE customerID = p_customerID;

    COMMIT;

END //
DELIMITER ;

-- Citation: Claude LLM, accessed on 2025-11-21 with prompt: "Can you please create update and create procedures following this schema? [file provided]"



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


-- #############################
-- CREATE CustomerInvoice
-- #############################

DROP PROCEDURE IF EXISTS sp_CreateCustomerInvoice;
DELIMITER //
CREATE PROCEDURE sp_CreateCustomerInvoice(
    IN p_customerID INT,
    OUT p_invoiceID INT
)
BEGIN
    DECLARE v_customerExists INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    SELECT COUNT(*) INTO v_customerExists 
    FROM Customers 
    WHERE customerID = p_customerID;
    
    IF v_customerExists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer ID does not exist';
    END IF;
    
    INSERT INTO CustomerInvoices (customerID) 
    VALUES (p_customerID);
    
    SET p_invoiceID = LAST_INSERT_ID();
    
    COMMIT;
    
    SELECT p_invoiceID AS newInvoiceID;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_AddCustomerInvoiceItem;
DELIMITER //
CREATE PROCEDURE sp_AddCustomerInvoiceItem(
    IN p_invoiceID INT,
    IN p_foodItemID INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_invoiceExists INT;
    DECLARE v_foodItemExists INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Validate invoice exists
    SELECT COUNT(*) INTO v_invoiceExists 
    FROM CustomerInvoices 
    WHERE customerInvoiceID = p_invoiceID;
    
    IF v_invoiceExists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invoice ID does not exist';
    END IF;
    
    -- Validate food item exists
    SELECT COUNT(*) INTO v_foodItemExists 
    FROM FoodItems 
    WHERE foodItemID = p_foodItemID;
    
    IF v_foodItemExists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Food item ID does not exist';
    END IF;
    
    -- Validate quantity
    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be greater than zero';
    END IF;
    
    INSERT INTO CustomerInvoice_Has_FoodItems (customerInvoiceID, foodItemID, quantity)
    VALUES (p_invoiceID, p_foodItemID, p_quantity);
    
    COMMIT;
END //
DELIMITER ;

-- Citation: Claude LLM, accessed on 2025-11-24 with prompt: "What is the best practice for creating and updating a customer-facing invoice for a schema like this? [ simplified file provided]"


-- #############################
-- UPDATE CustomerInvoice
-- #############################

-- Update the customer on an invoice
DROP PROCEDURE IF EXISTS sp_UpdateCustomerInvoiceCustomer;
DELIMITER //
CREATE PROCEDURE sp_UpdateCustomerInvoiceCustomer(
    IN p_invoiceID INT,
    IN p_customerID INT
)
BEGIN
    DECLARE v_invoiceExists INT;
    DECLARE v_customerExists INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Validate invoice exists
    SELECT COUNT(*) INTO v_invoiceExists 
    FROM CustomerInvoices 
    WHERE customerInvoiceID = p_invoiceID;
    
    IF v_invoiceExists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invoice ID does not exist';
    END IF;
    
    -- Validate customer exists
    SELECT COUNT(*) INTO v_customerExists 
    FROM Customers 
    WHERE customerID = p_customerID;
    
    IF v_customerExists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer ID does not exist';
    END IF;
    
    UPDATE CustomerInvoices 
    SET customerID = p_customerID 
    WHERE customerInvoiceID = p_invoiceID;
    
    COMMIT;
END //
DELIMITER ;

-- Remove a specific item from an invoice
DROP PROCEDURE IF EXISTS sp_RemoveCustomerInvoiceItem;
DELIMITER //
CREATE PROCEDURE sp_RemoveCustomerInvoiceItem(
    IN p_invoiceID INT,
    IN p_foodItemID INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    DELETE FROM CustomerInvoice_Has_FoodItems
    WHERE customerInvoiceID = p_invoiceID 
    AND foodItemID = p_foodItemID;
    
    COMMIT;
END //
DELIMITER ;

-- Update quantity for an item on an invoice
DROP PROCEDURE IF EXISTS sp_UpdateCustomerInvoiceQuantity;
DELIMITER //
CREATE PROCEDURE sp_UpdateCustomerInvoiceQuantity(
    IN p_invoiceID INT,
    IN p_foodItemID INT,
    IN p_quantity INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be greater than zero';
    END IF;
    
    UPDATE CustomerInvoice_Has_FoodItems
    SET quantity = p_quantity
    WHERE customerInvoiceID = p_invoiceID 
    AND foodItemID = p_foodItemID;
    
    COMMIT;
END //
DELIMITER ;

-- Citation: Claude LLM, accessed on 2025-11-24 with prompt: "I need to develop a stored procedure to update a customer invoice based on this schema [simplified SQL provided]"



-- #############################
-- DELETE SupplierInvoice
-- #############################

DROP PROCEDURE IF EXISTS sp_DeleteSupplierInvoice;

DELIMITER //
CREATE PROCEDURE sp_DeleteSupplierInvoice(IN p_supplierInvoiceID INT)
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

    -- This query will Delete the Supplier Invoice (For tax purposes)
    START TRANSACTION;

        -- 1) Delete FoodItems from Invoice
        DELETE FROM SupplierInvoice_Has_FoodItems
        WHERE supplierInvoiceID = p_supplierInvoiceID;  

        -- 2) Delete the invoice itself
        DELETE FROM SupplierInvoices
        WHERE supplierInvoiceID = p_supplierInvoiceID;

        -- Validate that the record was deleted
        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found in SupplierInvoices for ID: ', p_supplierInvoiceID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- Citation: Claude LLM, accessed on 2025-11-22 with prompt: "Let's turn the highlighted SQL code into a stored procedure. [file provided]"

-- #############################
-- DELETE CustomerInvoice
-- #############################

DROP PROCEDURE IF EXISTS sp_DeleteCustomerInvoice;

DELIMITER //
CREATE PROCEDURE sp_DeleteCustomerInvoice(IN p_customerInvoiceID INT)
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

    -- This query will Delete the Customer Invoice (For tax purposes)
    START TRANSACTION;

        -- 1) Delete FoodItems from Invoice
        DELETE FROM CustomerInvoice_Has_FoodItems
        WHERE customerInvoiceID = p_customerInvoiceID;  

        -- 2) Delete the invoice itself
        DELETE FROM CustomerInvoices
        WHERE customerInvoiceID = p_customerInvoiceID;

        -- Validate that the record was deleted
        IF ROW_COUNT() = 0 THEN
            SET error_message = CONCAT('No matching record found in CustomerInvoices for ID: ', p_customerInvoiceID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- Citation: 11/22/25 Adapted from previous procedure sp_DeleteSupplierInvoice
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

    INSERT INTO Cultures (cultureID, cultureName) VALUES 
        (1, 'Ferengi'),
        (2, 'Bajoran'),
        (3, 'Cardassian'),
        (4, 'Human'),
        (5, 'Trill'),
        (6, 'Klingon'),
        (7, 'Vulcan'),
        (8, 'Andorian')
    ;

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
        (10, 'Jumja Stick', 2)
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
        (3, 1, 10),
        (4, 7, 1),
        (4, 3, 1)
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

-- Citation: Table creation & insert our own hand-authored SQL.

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
-- CREATE Suppliers
-- #############################
DROP PROCEDURE IF EXISTS sp_CreateSupplier;

DELIMITER //
CREATE PROCEDURE sp_CreateSupplier(
    IN p_supplierName   VARCHAR(100),
    IN p_smuggler       TINYINT,
    IN p_blackmailable  TINYINT,
    IN p_cultureID      INT
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
        IF p_cultureID IS NOT NULL 
           AND NOT EXISTS (SELECT 1 FROM Cultures WHERE cultureID = p_cultureID) THEN
            SET error_message = CONCAT('Invalid cultureID: ', p_cultureID, ' does not exist in Cultures table');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        -- Insert the new supplier
        INSERT INTO Suppliers (supplierName, smuggler, blackmailable, cultureID)
        VALUES (p_supplierName, p_smuggler, p_blackmailable, p_cultureID);

    COMMIT;
END //
DELIMITER ;

-- #############################
-- UPDATE Suppliers
-- #############################
DROP PROCEDURE IF EXISTS sp_UpdateSupplier;

DELIMITER //
CREATE PROCEDURE sp_UpdateSupplier(
    IN p_supplierID      INT,
    IN p_supplierName    VARCHAR(100),
    IN p_smuggler        TINYINT,
    IN p_blackmailable   TINYINT,
    IN p_cultureID       INT
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

        -- Validate supplier exists
        IF NOT EXISTS (SELECT 1 FROM Suppliers WHERE supplierID = p_supplierID) THEN
            SET error_message = CONCAT('No matching record found in Suppliers for supplierID: ', p_supplierID);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        -- Normalize empty or invalid foreign keys to NULL
        IF p_cultureID IS NULL OR p_cultureID = 0 THEN
            SET p_cultureID = NULL;
        END IF;

        -- Validate foreign key references exist (only if not NULL)
        IF p_cultureID IS NOT NULL 
           AND NOT EXISTS (SELECT 1 FROM Cultures WHERE cultureID = p_cultureID) THEN
            SET error_message = CONCAT('Invalid cultureID: ', p_cultureID, ' does not exist in Cultures table');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        -- Update only fields that are provided
        UPDATE Suppliers
        SET 
            supplierName  = COALESCE(p_supplierName, supplierName),
            smuggler      = COALESCE(p_smuggler, smuggler),
            blackmailable = COALESCE(p_blackmailable, blackmailable),
            cultureID     = COALESCE(p_cultureID, cultureID)
        WHERE supplierID = p_supplierID;

    COMMIT;

END //
DELIMITER ;

-- #############################
-- DELETE Supplier
-- #############################

DELIMITER //

CREATE PROCEDURE sp_DeleteSupplier(IN p_supplierID INT)
BEGIN
    DECLARE rows_affected INT DEFAULT 0;
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

        -- Delete join-table rows for this supplier's invoices
        DELETE sfhi
        FROM SupplierInvoice_Has_FoodItems AS sfhi
        JOIN SupplierInvoices AS si 
              ON sfhi.supplierInvoiceID = si.supplierInvoiceID
        WHERE si.supplierID = p_supplierID;

        -- Delete supplier invoices
        DELETE FROM SupplierInvoices
        WHERE supplierID = p_supplierID;

        -- Delete the supplier itself
        DELETE FROM Suppliers
        WHERE supplierID = p_supplierID;

        -- How many suppliers were deleted?
        SET rows_affected = ROW_COUNT();

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF rows_affected = 0 THEN
            SET error_message = CONCAT('No matching record found in Suppliers for supplierID: ', p_supplierID);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        ELSE
            COMMIT;
            SELECT 'Supplier successfully deleted.' AS result;
        END IF;

END //

DELIMITER ;

-- Citation: ChatGPT Let's create a Stored Procedure out of this SQL code (Supplied Delete Supplier DML). Edited to align with Existing DELETE Customer Procedure 11/29/25


-- #############################
-- ADD SupplierInvoice Item
-- #############################

DROP PROCEDURE IF EXISTS sp_AddSupplierInvoiceItem;
DELIMITER //
CREATE PROCEDURE sp_AddSupplierInvoiceItem(
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
    
    -- Validate supplier invoice exists
    SELECT COUNT(*) INTO v_invoiceExists 
    FROM SupplierInvoices 
    WHERE supplierInvoiceID = p_invoiceID;
    
    IF v_invoiceExists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Supplier invoice ID does not exist';
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
    
    -- Insert the line item
    INSERT INTO SupplierInvoice_Has_FoodItems (supplierInvoiceID, foodItemID, quantity)
    VALUES (p_invoiceID, p_foodItemID, p_quantity);
    
    COMMIT;
END //
DELIMITER ;


-- #############################
-- CREATE SupplierInvoice
-- #############################

DROP PROCEDURE IF EXISTS sp_CreateSupplierInvoice;

DELIMITER //
CREATE PROCEDURE sp_CreateSupplierInvoice(
    IN p_supplierID INT,
    OUT p_invoiceID INT
)
BEGIN
    DECLARE v_supplierExists INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;

    -- Check if the supplier exists
    SELECT COUNT(*) INTO v_supplierExists
    FROM Suppliers
    WHERE supplierID = p_supplierID;

    IF v_supplierExists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Supplier does not exist';
    END IF;

    -- Create the invoice
    INSERT INTO SupplierInvoices (supplierID)
    VALUES (p_supplierID);

    -- Get the new invoice ID
    SET p_invoiceID = LAST_INSERT_ID();

    COMMIT;

    SELECT p_invoiceID AS newInvoiceID;

END //
DELIMITER ;

-- #############################
-- UPDATE SupplierInvoice
-- #############################

DROP PROCEDURE IF EXISTS sp_UpdateSupplierInvoiceQuantity;
DELIMITER //
CREATE PROCEDURE sp_UpdateSupplierInvoiceQuantity(
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
    
    -- Validate quantity
    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be greater than zero';
    END IF;
    
    -- Update the quantity for this item on this supplier invoice
    UPDATE SupplierInvoice_Has_FoodItems
    SET quantity = p_quantity
    WHERE supplierInvoiceID = p_invoiceID
      AND foodItemID = p_foodItemID;
    
    COMMIT;
END //
DELIMITER ;

-- #############################
-- DELETE SupplierInvoice Item
-- #############################

DROP PROCEDURE IF EXISTS sp_RemoveSupplierInvoiceItem;
DELIMITER //
CREATE PROCEDURE sp_RemoveSupplierInvoiceItem(
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
    
    DELETE FROM SupplierInvoice_Has_FoodItems
    WHERE supplierInvoiceID = p_invoiceID 
      AND foodItemID = p_foodItemID;
    
    COMMIT;
END //
DELIMITER ;

-- CITATION: The above Supplier Invoices Procedures were adapted from the Customer Invoices procedures created earlier, with appropriate modifications for Supplier context. 12/3/2025.

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

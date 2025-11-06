START TRANSACTION;

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

COMMIT;
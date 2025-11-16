-- Select Information on a supplier (dynamic search/dropdown input)
SELECT supplierName, smuggler, blackmailable, cultureName
FROM Suppliers
LEFT JOIN Cultures ON Suppliers.cultureID = Cultures.cultureID
WHERE supplierName = @sNameInput
;

-- Select Information on a Customers (dynamic search/dropdown input)
SELECT customerName, gullibilityRating AS gullibility, blackmailable, cultureName,
itemName AS favoriteFood
FROM Customers
LEFT JOIN Cultures ON Customers.cultureID = Cultures.cultureID
LEFT JOIN FoodItems ON Customers.favoriteFood = FoodItems.foodItemID
WHERE customerName = @cNameInput
;

-- Select Info on a Culture (dropdown input), selects three suppliers, customers, and foods related to culture
SELECT Cultures.cultureName,

    -- Up to 3 suppliers
    (SELECT GROUP_CONCAT(Suppliers.supplierName SEPARATOR ', ')
	FROM Suppliers
	WHERE Suppliers.cultureID = Cultures.cultureID
	LIMIT 3) AS supplierNames,

    -- Up to 3 customers
    (SELECT GROUP_CONCAT(Customers.customerName SEPARATOR ', ')
	FROM Customers 
	WHERE Customers.cultureID = Cultures.cultureID
	LIMIT 3) AS customerNames,

    -- Up to 3 foods
    (SELECT GROUP_CONCAT(FoodItems.itemName SEPARATOR ', ')
	FROM FoodItems 
	WHERE FoodItems.cultureID = Cultures.cultureID
	LIMIT 3) AS foodNames

FROM Cultures 
WHERE Cultures.cultureName = @cNameInput
;

-- This query will pull Top 5 most popular food items 
SELECT itemName as foodItem, COUNT(CustomerInvoice_Has_FoodItems.customerInvoiceID) AS numberOfCustomerInvoices
FROM FoodItems
JOIN CustomerInvoice_Has_FoodItems ON FoodItems.foodItemID = CustomerInvoice_Has_FoodItems.foodItemID
GROUP BY FoodItems.foodItemID, FoodItems.itemName
ORDER BY numberOfCustomerInvoices DESC
LIMIT 5
;

-- This Query will select info on a food item including top supplier, top customer by dynamic dropdown
SELECT FoodItems.itemName AS foodName, Cultures.cultureName,

    -- Top Customer for this food item
    (SELECT Customers.customerName
	FROM CustomerInvoice_Has_FoodItems
	JOIN CustomerInvoices ON CustomerInvoice_Has_FoodItems.customerInvoiceID = CustomerInvoices.customerInvoiceID
	JOIN Customers ON CustomerInvoices.customerID = Customers.customerID
	WHERE CustomerInvoice_Has_FoodItems.foodItemID = FoodItems.foodItemID
	GROUP BY Customers.customerID, Customers.customerName
	ORDER BY SUM(CustomerInvoice_Has_FoodItems.quantity) DESC
	LIMIT 1) AS topCustomer,

    -- Top Supplier for this food item
    (SELECT Suppliers.supplierName
	FROM SupplierInvoice_Has_FoodItems
	JOIN SupplierInvoices ON SupplierInvoice_Has_FoodItems.supplierInvoiceID = SupplierInvoices.supplierInvoiceID
	JOIN Suppliers ON SupplierInvoices.supplierID = Suppliers.supplierID
	WHERE SupplierInvoice_Has_FoodItems.foodItemID = FoodItems.foodItemID
	GROUP BY Suppliers.supplierID, Suppliers.supplierName
	ORDER BY SUM(SupplierInvoice_Has_FoodItems.quantity) DESC
	LIMIT 1) AS topSupplier

FROM FoodItems
JOIN Cultures ON FoodItems.cultureID = Cultures.cultureID
WHERE FoodItems.itemName = @fNameInput
;

-- This query inserts a supplier invoice with user inputs (dynamic dropdown)
START TRANSACTION;

	-- 1) Insert invoice using supplierName
	INSERT INTO SupplierInvoices (supplierID)
	VALUES (
		(SELECT supplierID 
		FROM Suppliers 
		WHERE supplierName = @sNameInput)
	);

	-- 2) Insert food item entry using itemName
	INSERT INTO SupplierInvoice_Has_FoodItems (supplierInvoiceID, foodItemID, quantity)
	VALUES (
		LAST_INSERT_ID(),            -- LAST_INSERT_ID function supplied by Chat GPT
		(SELECT foodItemID 
		FROM FoodItems 
		WHERE itemName = @fNameInput),
		25
	);

COMMIT;

-- This query inserts a customer invoice with user inputs (dynamic dropdown)
START TRANSACTION;

	-- 1) Insert invoice using supplierName
	INSERT INTO CustomerInvoices (customerID)
	VALUES (
		(SELECT customerID 
		FROM Customers
		WHERE customerName = @cNameInput)
	);

	-- 2) Insert food item entry using itemName
	INSERT INTO CustomerInvoice_Has_FoodItems (customerInvoiceID, foodItemID, quantity)
	VALUES (
		LAST_INSERT_ID(),         -- LAST_INSERT_ID function supplied by Chat GPT
		(SELECT foodItemID 
		FROM FoodItems 
		WHERE itemName = @fNameInput),
		25
	);

COMMIT;

-- This query grabs information on a customer invoice per user input of a customer InvoiceID
SELECT CustomerInvoices.customerInvoiceID, Customers.customerName,
	GROUP_CONCAT(CONCAT(FoodItems.itemName,' (',CustomerInvoice_Has_FoodItems.quantity,')') SEPARATOR ', ') AS foodItems
FROM CustomerInvoices 
JOIN Customers ON CustomerInvoices.customerID = Customers.customerID
JOIN CustomerInvoice_Has_FoodItems ON CustomerInvoices.customerInvoiceID = CustomerInvoice_Has_FoodItems.customerInvoiceID
JOIN FoodItems ON CustomerInvoice_Has_FoodItems.foodItemID = FoodItems.foodItemID
WHERE CustomerInvoices.customerInvoiceID = @cIDInput
;

-- This query grabs information on a customer invoice per user input of a customer InvoiceID

SELECT SupplierInvoices.supplierInvoiceID, Suppliers.supplierName,
    GROUP_CONCAT(CONCAT(FoodItems.itemName, ' (', SupplierInvoice_Has_FoodItems.quantity, ')') SEPARATOR ', ') AS foodItems
FROM SupplierInvoices
JOIN Suppliers ON SupplierInvoices.supplierID = Suppliers.supplierID
JOIN SupplierInvoice_Has_FoodItems ON SupplierInvoices.supplierInvoiceID = SupplierInvoice_Has_FoodItems.supplierInvoiceID
JOIN FoodItems ON SupplierInvoice_Has_FoodItems.foodItemID = FoodItems.foodItemID
WHERE SupplierInvoices.supplierInvoiceID = @sIDInput
;

-- This query will Delete the Supplier Invoice (For tax purposes)
START TRANSACTION;

-- 1) Delete FoodItems from Invoice
DELETE FROM SupplierInvoice_Has_FoodItems
WHERE supplierInvoiceID = @sIDInput;   -- replace with the invoice ID you want to remove

-- 2) Delete the invoice itself
DELETE FROM SupplierInvoices
WHERE supplierInvoiceID = @sIDInput;   -- same invoice ID

COMMIT;


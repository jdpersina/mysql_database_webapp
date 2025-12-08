-- Citation: Our own work.
DROP PROCEDURE IF EXISTS sp_load_quarkdb;
DELIMITER //
CREATE PROCEDURE sp_load_quarkdb()
BEGIN

	SET FOREIGN_KEY_CHECKS=0;

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

	SET FOREIGN_KEY_CHECKS=1;
END //

DELIMITER ;

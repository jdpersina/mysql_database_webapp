/*
    SETUP
*/

// Express
const express = require('express');
const app = express();
const PORT = 8188;

// Handlebars
const { engine } = require('express-handlebars');
app.engine('.hbs', engine({extname: ".hbs",
    helpers: {
        eq: (a, b) => a == b
    }
}));
app.set('view engine', '.hbs');

// Database 
const db = require('./db-connector');

// Middleware to parse JSON and urlencoded form data
app.use(express.json());
app.use(express.urlencoded({extended: true}));

// Serve static files (CSS, JS, images) from 'public' folder
app.use(express.static('public'));

// Citation: Claude LLM, accessed 2025-11-24 with prompt, "Can you please help me add the Handlebars helper to my Express setup? [setup code provided]"

/*
    ROUTES
*/

app.get('/', async function (req, res) {
    try {        
        res.render('index');
    } catch (error) {
        console.error("Error executing queries:", error);
        res.status(500).send("An error occurred while executing the database queries.");
    }
});

app.post('/reset', async function (req, res) {
    try {
        const query1 = `CALL sp_resetdb;`;

        await db.query(query1);

        console.log("Reset ran!")

        // Redirect the user to the updated webpage
        res.redirect('/');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

/* CUSTOMER ROUTES */ 
app.get('/customers', async function (req, res) {
    try {
        const customerQuery = `SELECT customerName, gullibilityRating AS gullibility, blackmailable, Cultures.cultureName AS cultureName,
                                    FoodItems.itemName AS favoriteFood, customerID
                                    FROM Customers
                                    LEFT JOIN Cultures ON Customers.cultureID = Cultures.cultureID
                                    LEFT JOIN FoodItems ON Customers.favoriteFood = FoodItems.foodItemID
                                    ;`;
        const [customers] = await db.query(customerQuery);

        res.render('customers', { customers: customers });
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.get('/add-customer', async (req, res) => {

    const foodItemsQuery = `SELECT * from FoodItems;`;
    const [foodItems] = await db.query(foodItemsQuery);

    const culturesQuery = `SELECT * from Cultures;`;
    const [cultures] = await db.query(culturesQuery);

    res.render('customer-new', { cultures: cultures, foodItems: foodItems });
});

app.post('/create-new-customer', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;

        // Create and execute our queries
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_CreateCustomer(?, ?, ?, ?, ?);`;

        // Store ID of last inserted row
        const [rows] = await db.query(query1, [
            data.create_customer_name,
            data.create_customer_gullibility,
            data.create_customer_blackmailable,
            data.create_customer_culture,
            data.create_customer_favorite_food
        ]);


        // Redirect the user to the updated webpage
        res.redirect('/customers');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.get('/update-customer', async function (req, res) {
    try {
        const customerQuery = `SELECT customerName, gullibilityRating AS gullibility, blackmailable, Cultures.cultureName AS cultureName,
                                    FoodItems.itemName AS favoriteFood, customerID
                                    FROM Customers
                                    LEFT JOIN Cultures ON Customers.cultureID = Cultures.cultureID
                                    LEFT JOIN FoodItems ON Customers.favoriteFood = FoodItems.foodItemID
                                    ;`;
        const [customers] = await db.query(customerQuery);

        const foodItemQuery = `SELECT * from FoodItems;`
        const [foodItems] = await db.query(foodItemQuery)

        const cultureQuery = `SELECT * from Cultures;`
        const [cultures] = await db.query(cultureQuery)

        res.render('customer-update', { customers: customers, foodItems: foodItems, cultures: cultures });
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.post('/update-existing-customer', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;

        // Create and execute our queries
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_UpdateCustomer(?, ?, ?, ?, ?, ?);`;

        const sanitize = (value) => {
            if (value === undefined || value === null || value === "" || value === "NULL") {
                return null;
            }
            return value;
        };

        const customerID = parseInt(data.customerID); // always required
        const customerName = sanitize(data.customerName); // required, but still sanitize
        const gullibilityRating = sanitize(data.gullibilityRating) !== null ? parseInt(data.gullibilityRating) : null;
        const blackmailable = sanitize(data.blackmailable) !== null ? parseInt(data.blackmailable) : null;
        const cultureID = sanitize(data.cultureID) !== null ? parseInt(data.cultureID) : null;
        const favoriteFoodID = sanitize(data.favoriteFoodID) !== null ? parseInt(data.favoriteFoodID) : null;

        // Store ID of last inserted row
        const [rows] = await db.query(query1, [
            customerID,
            customerName,
            gullibilityRating,
            blackmailable,
            cultureID,
            favoriteFoodID
        ]);

        // Redirect the user to the updated webpage
        res.redirect('/customers');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.post('/delete-customer', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_DeleteCustomer(?);`;
        await db.query(query1, [data.delete_customer_id]);

        console.log(`DELETE customer. ID: ${data.delete_customer_id} ` +
            `Name: ${data.delete_customer_name}`
        );

        // Redirect the user to the updated webpage data
        res.redirect('/customers');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.get('/invoices/customers', async function (req, res) {
    try {
        const cInvoiceQuery = `SELECT 
                                    ci.customerInvoiceID,
                                    c.customerName,
                                    COUNT(cihf.foodItemID) AS itemCount,
                                    GROUP_CONCAT(
                                        CONCAT(fi.itemName, ' (', cihf.quantity, ')')
                                        ORDER BY fi.itemName
                                        SEPARATOR ', '
                                    ) AS items
                                FROM CustomerInvoices ci
                                INNER JOIN Customers c ON ci.customerID = c.customerID
                                LEFT JOIN CustomerInvoice_Has_FoodItems cihf ON ci.customerInvoiceID = cihf.customerInvoiceID
                                LEFT JOIN FoodItems fi ON cihf.foodItemID = fi.foodItemID
                                GROUP BY ci.customerInvoiceID, c.customerName
                                ORDER BY ci.customerInvoiceID DESC;`
        const [cInvoices] = await db.query(cInvoiceQuery);

        const foodItemQuery = `SELECT * from FoodItems;`
        const [foodItems] = await db.query(foodItemQuery)

        const customerQuery = `SELECT customerID, customerName from Customers;`
        const [customers] = await db.query(customerQuery)

        res.render('customer-invoices', { invoices: cInvoices, foodItems: foodItems, customers: customers });
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

// Citation: Claude LLM, accessed on 2025-11-24 with prompt: "Can this query please also provide the item quantity count? [query provided]"

app.post('/invoices/customers/add', async (req, res) => {
    const { create_invoice_customer, create_invoice_fooditem, create_invoice_quantity } = req.body;
    
    try {
        // Start transaction
        await db.query('START TRANSACTION');
        
        // Create the invoice
        const [invoiceResult] = await db.query(
            'CALL sp_CreateCustomerInvoice(?, @invoiceID)',
            [create_invoice_customer]
        );
        const invoiceID = invoiceResult[0][0].newInvoiceID;
        
        // Ensure fooditem and quantity are arrays
        const foodItems = Array.isArray(create_invoice_fooditem) 
            ? create_invoice_fooditem 
            : [create_invoice_fooditem];
        const quantities = Array.isArray(create_invoice_quantity) 
            ? create_invoice_quantity 
            : [create_invoice_quantity];
        
        // Add each item to the invoice
        for (let i = 0; i < foodItems.length; i++) {
            await db.query(
                'CALL sp_AddCustomerInvoiceItem(?, ?, ?)',
                [invoiceID, foodItems[i], quantities[i]]
            );
        }
        
        await db.query('COMMIT');
        res.redirect('/invoices/customers');
        
    } catch (error) {
        await db.query('ROLLBACK');
        console.error('Error creating invoice:', error);
        res.status(500).send('Error creating invoice');
    }
});

// Get single invoice for editing
app.get('/invoices/customers/edit/:id', async (req, res) => {
    const invoiceID = req.params.id;

    console.log("Invoice ID:", invoiceID)
    
    try {
        // Get invoice with customer info
        const [invoice] = await db.query(`
            SELECT 
                ci.customerInvoiceID,
                ci.customerID,
                c.customerName
            FROM CustomerInvoices ci
            JOIN Customers c ON ci.customerID = c.customerID
            WHERE ci.customerInvoiceID = ?
        `, [invoiceID]);
        
        if (invoice.length === 0) {
            return res.status(404).send('Invoice not found');
        }
        
        // Get items on this invoice
        const [items] = await db.query(`
            SELECT 
                fi.foodItemID,
                fi.itemName,
                cif.quantity
            FROM CustomerInvoice_Has_FoodItems cif
            JOIN FoodItems fi ON cif.foodItemID = fi.foodItemID
            WHERE cif.customerInvoiceID = ?
            ORDER BY fi.itemName
        `, [invoiceID]);
        
        // Get all customers for dropdown
        const [customers] = await db.query('SELECT customerID, customerName FROM Customers ORDER BY customerName');
        
        // Get all food items for dropdown
        const [foodItems] = await db.query('SELECT foodItemID, itemName FROM FoodItems ORDER BY itemName');
        
        res.render('customer-invoice-edit', { 
            invoice: invoice[0],
            items,
            customers, 
            foodItems 
        });
        
    } catch (error) {
        console.error('Error fetching invoice:', error);
        res.status(500).send('Error fetching invoice');
    }
});

// Update invoice customer
app.post('/invoices/customers/update/:id', async (req, res) => {
    const invoiceID = req.params.id;
    const { update_invoice_customer } = req.body;
    
    try {
        await db.query('CALL sp_UpdateCustomerInvoiceCustomer(?, ?)', [invoiceID, update_invoice_customer]);
        res.redirect('/invoices/customers');
    } catch (error) {
        console.error('Error updating invoice customer:', error);
        res.status(500).send('Error updating invoice');
    }
});

// Add item to existing invoice
app.post('/invoices/customers/:id/add-item', async (req, res) => {
    const invoiceID = req.params.id;
    const { foodItemID, quantity } = req.body;
    
    try {
        await db.query('CALL sp_AddCustomerInvoiceItem(?, ?, ?)', [invoiceID, foodItemID, quantity]);
        res.redirect(`/invoices/customers/edit/${invoiceID}`);
    } catch (error) {
        console.error('Error adding item:', error);
        res.status(500).send('Error adding item');
    }
});

// Update item quantity
app.post('/invoices/customers/:invoiceID/update-item/:foodItemID', async (req, res) => {
    const { invoiceID, foodItemID } = req.params;
    const { quantity } = req.body;
    
    try {
        await db.query('CALL sp_UpdateCustomerInvoiceQuantity(?, ?, ?)', [invoiceID, foodItemID, quantity]);
        res.redirect(`/invoices/customers/edit/${invoiceID}`);
    } catch (error) {
        console.error('Error updating item quantity:', error);
        res.status(500).send('Error updating item');
    }
});

// Remove item from invoice
app.post('/invoices/customers/:invoiceID/remove-item/:foodItemID', async (req, res) => {
    const { invoiceID, foodItemID } = req.params;
    
    try {
        await db.query('CALL sp_RemoveCustomerInvoiceItem(?, ?)', [invoiceID, foodItemID]);
        res.redirect(`/invoices/customers/edit/${invoiceID}`);
    } catch (error) {
        console.error('Error removing item:', error);
        res.status(500).send('Error removing item');
    }
});

// Citation: Claude LLM accessed 2025-11-24 with prompt: "What is the best practice for handling routing in Express for updating customer invoices?"

app.post('/invoices/customers/delete', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;

        console.log("Data", data)

        // Create and execute our query
        // Using parameterized queries (Prevents SQL injection attacks)
        const query1 = `CALL sp_DeleteCustomerInvoice(?);`;
        await db.query(query1, [data.delete_invoice_id]);

        console.log(`DELETE customer invoice. ID: ${data.delete_invoice_id}`);

        // Redirect the user to the updated webpage data
        res.redirect('/invoices/customers');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

/* SUPPLIER ROUTES */

app.get('/suppliers', async function (req, res) {
     try {
        const supplierQuery = `SELECT * from Suppliers;`;
        const [suppliers] = await db.query(supplierQuery);

        const foodItemsQuery = `SELECT * from FoodItems;`;
        const [foodItems] = await db.query(foodItemsQuery);

        const culturesQuery = `SELECT * from Cultures;`;
        const [cultures] = await db.query(culturesQuery);


        res.render('suppliers', { suppliers: suppliers, foodItems: foodItems, cultures: cultures});
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.get('/invoices/suppliers', async function (req, res) {
    try {
const sInvoiceQuery = `
                        SELECT 
                            si.supplierInvoiceID,
                            s.supplierName,
                            COUNT(sihf.foodItemID) AS itemCount,
                            GROUP_CONCAT(
                                CONCAT(fi.itemName, ' (', sihf.quantity, ')')
                                ORDER BY fi.itemName
                                SEPARATOR ', '
                            ) AS items
                        FROM SupplierInvoices si
                        INNER JOIN Suppliers s ON si.supplierID = s.supplierID
                        LEFT JOIN SupplierInvoice_Has_FoodItems sihf ON si.supplierInvoiceID = sihf.supplierInvoiceID
                        LEFT JOIN FoodItems fi ON sihf.foodItemID = fi.foodItemID
                        GROUP BY si.supplierInvoiceID, s.supplierName
                        ORDER BY si.supplierInvoiceID DESC;`;
        const [sInvoices] = await db.query(sInvoiceQuery);

        const foodItemQuery = `SELECT * from FoodItems;`
        const [foodItems] = await db.query(foodItemQuery)

        const supplierQuery = `SELECT supplierID, supplierName from Suppliers;`
        const [suppliers] = await db.query(supplierQuery)

        res.render('supplier-invoices', { invoices: sInvoices, foodItems: foodItems, suppliers: suppliers });
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

app.get('/add-supplier', async (req, res) => {
    const culturesQuery = `SELECT * from Cultures;`;
    const [cultures] = await db.query(culturesQuery);

    res.render('supplier-new', {cultures: cultures});
});

app.get('/update-supplier', async (req, res) => {
    try {
        const [suppliers] = await db.query('SELECT * FROM Suppliers;');
        const [cultures]  = await db.query('SELECT * FROM Cultures;');

        res.render('supplier-update', { suppliers, cultures });
    } catch (error) {
        console.error('Error loading suppliers for update:', error);
        res.status(500).send('Error loading suppliers for update.');
    }
});

app.post('/update-existing-supplier', async (req, res) => {
    try {
        const data = req.body;

        const query = 'CALL sp_UpdateSupplier(?, ?, ?, ?, ?);';

        const [rows] = await db.query(query, [
            data.update_supplier_id,
            data.update_supplier_name,
            data.update_supplier_smuggler,
            data.update_supplier_blackmailable,
            data.update_supplier_culture
        ]);

        res.redirect('/suppliers');
    } catch (error) {
        console.error('Error updating supplier:', error);
        res.status(500).send('An error occurred while executing the database queries.');
    }
});

app.post('/create-new-supplier', async (req, res) => {
    try {
		//Parse Frontend form info
        const data = req.body;

        // Create and execute our queries using parameterized queries 
        const query = 'CALL sp_CreateSupplier(?, ?, ?, ?);';
        
        const [rows] = await db.query(query, [
            data.create_supplier_name,
            data.create_supplier_smuggler,
            data.create_supplier_blackmailable,
            data.create_supplier_culture
        ]);

        // Go back to the suppliers page to see the new row
        res.redirect('/suppliers');
    } catch (error) {
        console.error('Error creating supplier:', error);
        res.status(500).send('An error occurred while executing database queries');
    }
});

app.post('/delete-supplier', async function (req, res) {
    try {
        // Parse frontend form information
        let data = req.body;

        // Create and execute our query
        const query1 = `CALL sp_DeleteSupplier(?);`;
        await db.query(query1, [data.delete_supplier_id]);

        console.log(
            `DELETE supplier. ID: ${data.delete_supplier_id} ` +
            `Name: ${data.delete_supplier_name}`
        );

        // Redirect the user to the updated webpage data
        res.redirect('/suppliers');
    } catch (error) {
        console.error('Error executing queries:', error);
        // Send a generic error message to the browser
        res.status(500).send(
            'An error occurred while executing the database queries.'
        );
    }
});

// CITATION: The structure and approach for these supplier routes were inspired by the customer routes above, following best practices for Express routing and error handling.

// Create New Supplier Invoice
console.log('Registering POST /invoices/suppliers/add');
// Create New Supplier Invoice
app.post('/invoices/suppliers/add', async (req, res) => {
    const { create_invoice_supplier, create_invoice_fooditem, create_invoice_quantity } = req.body;

    try {
        // Start transaction
        await db.query('START TRANSACTION');
        
        // Create the supplier invoice (header)
        const [invoiceResult] = await db.query(
            'CALL sp_CreateSupplierInvoice(?, @invoiceID)',
            [create_invoice_supplier]
        );

        // Match the SELECT p_invoiceID AS newInvoiceID in the proc
        const invoiceID = invoiceResult[0][0].newInvoiceID;
        
        // Normalize to arrays (handles single item vs multiple)
        const foodItems = Array.isArray(create_invoice_fooditem)
            ? create_invoice_fooditem
            : [create_invoice_fooditem];

        const quantities = Array.isArray(create_invoice_quantity)
            ? create_invoice_quantity
            : [create_invoice_quantity];

        // Add each item to the supplier invoice
        for (let i = 0; i < foodItems.length; i++) {
            await db.query(
                'CALL sp_AddSupplierInvoiceItem(?, ?, ?)',
                [invoiceID, foodItems[i], quantities[i]]
            );
        }

        // Commit the whole thing
        await db.query('COMMIT');
        res.redirect('/invoices/suppliers');

    } catch (error) {
        await db.query('ROLLBACK');
        console.error('Error creating supplier invoice:', error);
        res.status(500).send('Error creating supplier invoice');
    }
});

// Get single supplier invoice for editing
app.get('/invoices/suppliers/edit/:id', async (req, res) => {
    const invoiceID = req.params.id;

    try {
        // Get invoice header with supplier info
        const [invoice] = await db.query(`
            SELECT 
                si.supplierInvoiceID,
                si.supplierID,
                s.supplierName
            FROM SupplierInvoices si
            JOIN Suppliers s ON si.supplierID = s.supplierID
            WHERE si.supplierInvoiceID = ?
        `, [invoiceID]);

        if (invoice.length === 0) {
            return res.status(404).send('Supplier invoice not found');
        }

        // Get items on this supplier invoice
        const [items] = await db.query(`
            SELECT 
                fi.foodItemID,
                fi.itemName,
                sihf.quantity
            FROM SupplierInvoice_Has_FoodItems sihf
            JOIN FoodItems fi ON sihf.foodItemID = fi.foodItemID
            WHERE sihf.supplierInvoiceID = ?
            ORDER BY fi.itemName
        `, [invoiceID]);

        // Get all suppliers for dropdown
        const [suppliers] = await db.query(
            'SELECT supplierID, supplierName FROM Suppliers ORDER BY supplierName'
        );

        // Get all food items for dropdown
        const [foodItems] = await db.query(
            'SELECT foodItemID, itemName FROM FoodItems ORDER BY itemName'
        );

        res.render('supplier-invoice-edit', {
            invoice: invoice[0],
            items,
            suppliers,
            foodItems
        });

    } catch (error) {
        console.error('Error fetching supplier invoice:', error);
        res.status(500).send('Error fetching supplier invoice');
    }
});

// Add item to existing supplier invoice
app.post('/invoices/suppliers/:id/add-item', async (req, res) => {
    const invoiceID = req.params.id;
    const { foodItemID, quantity } = req.body;

    try {
        await db.query('CALL sp_AddSupplierInvoiceItem(?, ?, ?)', [
            invoiceID,
            foodItemID,
            quantity
        ]);
        res.redirect(`/invoices/suppliers/edit/${invoiceID}`);
    } catch (error) {
        console.error('Error adding item to supplier invoice:', error);
        res.status(500).send('Error adding item');
    }
});

// Update item quantity on supplier invoice
app.post('/invoices/suppliers/:invoiceID/update-item/:foodItemID', async (req, res) => {
    const { invoiceID, foodItemID } = req.params;
    const { quantity } = req.body;

    try {
        await db.query('CALL sp_UpdateSupplierInvoiceQuantity(?, ?, ?)', [
            invoiceID,
            foodItemID,
            quantity
        ]);

        res.redirect(`/invoices/suppliers/edit/${invoiceID}`);
    } catch (error) {
        console.error('Error updating supplier invoice item quantity:', error);
        res.status(500).send('Error updating item');
    }
});

// Delete entire supplier invoice
app.post('/invoices/suppliers/delete', async (req, res) => {
    try {
        const data = req.body;

        const query = 'CALL sp_DeleteSupplierInvoice(?);';
        await db.query(query, [data.delete_invoice_id]);

        console.log(`DELETE supplier invoice. ID: ${data.delete_invoice_id}`);

        res.redirect('/invoices/suppliers');
    } catch (error) {
        console.error('Error deleting supplier invoice:', error);
        res.status(500).send('An error occurred while deleting supplier invoice.');
    }
});

// Remove item from supplier invoice
app.post('/invoices/suppliers/:invoiceID/remove-item/:foodItemID', async (req, res) => {
    const { invoiceID, foodItemID } = req.params;

    try {
        await db.query('CALL sp_RemoveSupplierInvoiceItem(?, ?)', [
            invoiceID,
            foodItemID
        ]);

        res.redirect(`/invoices/suppliers/edit/${invoiceID}`);
    } catch (error) {
        console.error('Error removing item from supplier invoice:', error);
        res.status(500).send('Error removing item');
    }
});

// CITATION: The structure and approach for these supplier invoice routes were inspired by the customer invoice routes above, following best practices for Express routing and error handling.

/* OTHER ROUTES */

app.get('/cultures', async (req, res) => {
    const culturesQuery = `SELECT * from Cultures;`;
    const [cultures] = await db.query(culturesQuery);

    res.render('cultures', { cultures: cultures });
});

app.get('/menu', async (req, res) => {

    const foodItemQuery = ` 
        SELECT f.foodItemID, f.itemName, c.cultureName
            FROM FoodItems f
            LEFT JOIN Cultures c ON f.cultureID = c.cultureID
            ORDER BY c.cultureName, f.itemName;`
    const [foodItems] = await db.query(foodItemQuery)

    res.render('fooditems', {foodItems: foodItems});
});

/*
    LISTENER
*/

app.listen(PORT, function(){
    console.log("===== SERVER STARTING - SUPPLIER SINGULAR =====");
    console.log('Express started on http://localhost:' + PORT + '; press Ctrl-C to terminate...')
});
/*
    SETUP
*/

// Express
const express = require('express');
const app = express();
const PORT = 8188;

// Handlebars
const { engine } = require('express-handlebars');
app.engine('.hbs', engine({extname: ".hbs"}));
app.set('view engine', '.hbs');

// Database 
const db = require('./db-connector');

// Middleware to parse JSON and urlencoded form data
app.use(express.json());
app.use(express.urlencoded({extended: true}));

// Serve static files (CSS, JS, images) from 'public' folder
app.use(express.static('public'));


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

/* CUSTOMER ROUTES */ 
app.get('/customers', async function (req, res) {
    try {
        const customerQuery = `SELECT customerName, gullibilityRating AS gullibility, blackmailable, cultureName,
                                    favoriteFood
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

app.get('/add-customer', (req, res) => {
    res.render('customer-new');
});

app.get('/update-customer', (req, res) => {
    res.render('customer-update');
});

app.get('/invoices/customers', async function (req, res) {
    try {
        const cInvoiceQuery = `SELECT 
                                    ci.customerInvoiceID,
                                    c.customerName,
                                    COUNT(cihf.foodItemID) AS itemCount,
                                    GROUP_CONCAT(fi.itemName SEPARATOR ', ') AS items
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

/* SUPPLIER ROUTES */

app.get('/suppliers', async function (req, res) {
     try {
        const supplierQuery = `SELECT * from Suppliers;`;
        const [suppliers] = await db.query(supplierQuery);

        const foodItemsQuery = `SELECT * from FoodItems;`;
        const [foodItems] = await db.query(foodItemsQuery);

        const culturesQuery = `SELECT * from Cultures;`;
        const [cultures] = await db.query(culturesQuery);


        // Render the bsg-people.hbs file, and also send the renderer
        //  an object that contains our bsg_people and bsg_homeworld information
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
        const sInvoiceQuery = `SELECT 
                                    si.supplierInvoiceID,
                                    s.supplierName,
                                    COUNT(sihf.foodItemID) AS itemCount,
                                    GROUP_CONCAT(fi.itemName SEPARATOR ', ') AS items
                                FROM SupplierInvoices si
                                INNER JOIN Suppliers s ON si.supplierID = s.supplierID
                                LEFT JOIN SupplierInvoice_Has_FoodItems sihf ON si.supplierInvoiceID = sihf.supplierInvoiceID
                                LEFT JOIN FoodItems fi ON sihf.foodItemID = fi.foodItemID
                                GROUP BY si.supplierInvoiceID, s.supplierName
                                ORDER BY si.supplierInvoiceID DESC;`
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

app.get('/add-supplier', (req, res) => {
    res.render('supplier-new');
});
app.get('/update-supplier', (req, res) => {
    res.render('supplier-update');
});

/* OTHER ROUTES */

app.get('/cultures', (req, res) => {
    res.render('cultures');
});

app.get('/menu', (req, res) => {
    res.render('fooditems');
});

app.get('/invoices', (req, res) => {
    res.render('invoices');
});

/*
    LISTENER
*/

app.listen(PORT, function(){
    console.log("===== SERVER STARTING - SUPPLIER SINGULAR =====");
    console.log('Express started on http://localhost:' + PORT + '; press Ctrl-C to terminate...')
});
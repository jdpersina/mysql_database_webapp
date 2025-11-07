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
        // Define our queries
        const query1 = 'DROP TABLE IF EXISTS diagnostic;';
        const query2 = 'CREATE TABLE diagnostic(id INT PRIMARY KEY AUTO_INCREMENT, text VARCHAR(255) NOT NULL);';
        const query3 = 'INSERT INTO diagnostic (text) VALUES ("New test query");';
        const query4 = 'SELECT * FROM diagnostic;';
        
        // Execute each query synchronously (await).
        await db.query(query1);
        await db.query(query2);
        await db.query(query3);
        const [rows] = await db.query(query4);
        
        // Render the index template with the data
        res.render('index', { 
            data: rows,
            dataJson: JSON.stringify(rows, null, 2)
        });

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

        // const foodItemsQuery = `SELECT * from FoodItems;`;
        // const [foodItems] = await db.query(foodItemsQuery);

        // const culturesQuery = `SELECT * from Cultures;`;
        // const [cultures] = await db.query(culturesQuery);


        // Render the bsg-people.hbs file, and also send the renderer
        //  an object that contains our bsg_people and bsg_homeworld information
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
        const customerQuery = `SELECT * from Customers;`;
        const [customers] = await db.query(customerQuery);

        const foodItemsQuery = `SELECT * from FoodItems;`;
        const [foodItems] = await db.query(foodItemsQuery);

        const invoicesQuery = `SELECT * from CustomerInvoices`;
        const [invoices] = await db.query(invoicesQuery);

        res.render('customer-invoices', { customers: customers, foodItems: foodItems, invoices: invoices});
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
        const supplierQuery = `SELECT * from Suppliers;`;
        const [suppliers] = await db.query(supplierQuery);

        const foodItemsQuery = `SELECT * from FoodItems;`;
        const [foodItems] = await db.query(foodItemsQuery);

        const invoicesQuery = `SELECT * from SupplierInvoices`;
        const [invoices] = await db.query(invoicesQuery);

        res.render('supplier-invoices', { suppliers: suppliers, foodItems: foodItems, invoices: invoices});
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
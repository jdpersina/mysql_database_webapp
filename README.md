# Overview
Quark's Bar, Grill, Gaming House and Holosuite Arcade is a business serving patrons on the space station Deep Space Nine (DS9). DS9 is a Cardassian Space Station in Bajoran Space that was ceded to the Bajorans at the conclusion of Cardassia’s 50 years long occupation of Bajor. Because DS9 is an important trading hub in the Sector, Bajor has invited Starfleet to administer it on their behalf. 

Quark’s Bar, as it’s known, is a popular tourist location on the station and serves as many as 200 customers in a regular business day. Quark, the owner, is a Ferengi, and like any good Ferengi, he follows the Rules of Acquisition - and, as Rule #74 says, “Knowledge equals profit.” 

Quark’s Bar needs a database to keep track of the ever-evolving landscape that is DS9. Selling more than 100 different types of delicacies, managing two dozen different suppliers (legitimate and otherwise), and keeping track of 1000+ customers (who each have a favorite food!) from over 40 cultures on the station alone… It’s enough to make any Ferengi’s head spin! 

# To Run
Clone repo to local machine and run npm i to install required modules. Check to ensure that _your_ hostname, username, and password are correct in the db-connector.js file to connect to a remote database. 

# General Citations
ChatGPT and Claude LLM were used through at various times to help create styling and modify forms. Additionally, the base code from CS340 Fall 2025 quarter was used extensively. In-code citations can be found on relevant pages/in relevant sections of the code. 

Notable sections where LLMs were used include the global CSS file and throughout the app.js and individual forms to make updates from the class starter code to logic that would support our database functionality. While the structure was generally decided by us, we leveraged LLMs to implement the details, such as actually coding the table items.

Notable sections where class starter code was used include the Express setup in db-connector.js and the app.js files, as well as the UI pages for Customers & Suppliers, which were then extensively modified and used as the basis for Customer & Supplier Invoice pages. Again, the details of the changes were made by us, and generally implemented by AI. The PLSQL was another area where we made extensive use of AI to create the basic stored procedures. In most cases, we provided the database schema for the table, asked for a stored procedure, and then modified it based on our project needs. In most cases, the code that used AI was an extensive "collaboration" because almost nothing came straight from an LLM and went into the project unmodified in some way. 

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
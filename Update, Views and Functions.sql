/* 1. */
/* Update statement to change values */
UPDATE tblItem
set ItemDescription = 'Desk Lamps'
where tblItem.ItemDescription like 'Desk Lamp';

/* Create and insert new data record*/ 
SET IDENTITY_INSERT tblSale ON
INSERT INTO tblSale(SaleID, CustomerID, EmployeeID, SubTotal, SaleDate, Tax, Total)
	VALUES (100, 10, 1, 200, 'Jan 15 2015 12:00 AM', 41, 241);
SET IDENTITY_INSERT tblSale OFF

SET IDENTITY_INSERT tblSaleItem	ON
INSERT INTO tblSaleItem(SaleItemID, SaleID, ItemID, ItemPrice)
	VALUES (1, 100, 2, 200);
SET IDENTITY_INSERT tblSaleItem OFF

/* DELETING ADDED DATA */
DELETE FROM tblSale
where SaleID = 100;

-- One delete statement needed, when the sale gets deleted
-- everything connected through keys get deleted as well

/* Create and view new View */
CREATE VIEW vueSaleSummary 
	AS SELECT s.SaleID, 
	s.SaleDate, 
	si.SaleItemID, 
	si.ItemID,
	i.ItemDescription, 
	i.ItemPrice
FROM tblSale AS s
	LEFT OUTER JOIN tblSaleItem AS SI
	ON s.SaleID = si.SaleID
	LEFT OUTER JOIN tblItem AS I 
	ON si.ItemID = i.ItemID;

select * from vueSaleSummary;

/* 2. */


/* CREATING First Name Function */


CREATE FUNCTION dbo.ufnGetFirstName (@fullname varchar(100))
returns varchar(50)
AS
BEGIN
--declare the local variable: lastName
DECLARE @firstName varchar(50);
--declare the index variable to find the index of the separator that separates last name from first name
DECLARE @separatorIndex int;
--get the separator index value
--check if the default separator (,) exists
SET @separatorIndex = CHARINDEX(',', @fullname);
IF @separatorIndex > 0 
	BEGIN 
		SET @firstName =SUBSTRING(@fullname, @separatorIndex+2, (LEN(@fullname)));
	END
--if it does, use the substring function to find the last name
--if it does not, let's assume the space is the separator and the full name format is FirstName LastName
--find the index for the space, then find the last name
ELSE
	BEGIN
		SET @separatorIndex = CHARINDEX(' ', @fullname);
		SET @firstName = SUBSTRING(@fullname, 1, @separatorIndex-1);
	END
--return the last name
RETURN @firstName
END



/* CREATING Last Name Function */
CREATE FUNCTION dbo.ufnGetLastName (@fullname varchar(100))
returns varchar(50)
AS
BEGIN
--declare the local variable: lastName
DECLARE @lastName varchar(50);
--declare the index variable to find the index of the separator that separates last name from first name
DECLARE @separatorIndex int;
--get the separator index value
--check if the default separator (,) exists
SET @separatorIndex = CHARINDEX(',', @fullname);
IF @separatorIndex > 0 
	BEGIN 
		SET @lastName =SUBSTRING(@fullname, 1, @separatorIndex-1);
	END
--if it does, use the substring function to find the last name
--if it does not, let's assume the space is the separator and the full name format is FirstName LastName
--find the index for the space, then find the last name
ELSE
	BEGIN
		SET @separatorIndex = CHARINDEX(' ', @fullname);
		SET @lastName = SUBSTRING(@fullname, @separatorIndex+1, (LEN(@fullname)-@separatorIndex));
	END
--return the last name
RETURN @lastName
END

/* Creating w/o discount function */

CREATE FUNCTION dbo.ufnGetOrderGrandTotalWithoutDiscount (@orderID int)
returns float
AS
BEGIN
--Declare local variables: 
--@grandTotal float, @unitPrice float, @quantity int
DECLARE @grandTotal float, @unitPrice float, @quantity int;
--Initiate the local variable values to be zero
SET @grandTotal=0;
SET @unitPrice=0;
SET @quantity=0;
--Declare a cursor to get UnitPrice and Quantity for all products from tblPSMOrderDetail where OrderID=@orderID
DECLARE cs CURSOR FOR select UnitPrice, Quantity from tblPSMOrderDetail where OrderID=@orderID;
--Open the cursor
OPEN cs;
--Fetch UnitPrice and Quantity into @unitPrice, @quantity
FETCH next from cs INTO @unitPrice, @quantity
--Use @@FETCH_STATUS to check if there are more records in the cursor
--@@FETCH_STATUS=0 --> it successfully fetched a row; @@FETCH_STATUS=-1 --> no more
WHILE @@FETCH_STATUS=0
BEGIN
	--calculate the grand total without discount 
	SET @grandTotal = @grandTotal + @unitPrice * @quantity;
	--fetch next row from the cursor
	FETCH next from cs INTO @unitPrice, @quantity
END
--close the cursor
CLOSE cs;
--deallocate the cursor in memory
DEALLOCATE cs;
--return @grandTotal
return @grandTotal;
END

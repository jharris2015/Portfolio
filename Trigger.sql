/**
This trigger will ensure that a row has the last name value if the fullname is provided.
This example is an AFTER INSERT trigger, which means that it is invoked after the data has 
been inserted into the table.

Test script:
select * from tblPersonNames;
--Test lastname is not provided
Insert into tblPersonNames (FullName) values ('Kyle Westminster');
Insert into tblPersonNames (FullName) values ('Jackson, Liam');

--Test the provided lastname matches the extracted lastname from the fullname
Insert into tblPersonNames (FullName, LastName) values ('Jack London', 'London');
--Test the provided lastname does not match the extracted lastname from the fullname
Insert into tblPersonNames (FullName, LastName) values ('Hemingway, Ernest', 'Hemingwey');
*/


CREATE TRIGGER dbo.utrLastnameAfterInsertTblPersonNames ON tblPersonNames AFTER INSERT
AS
BEGIN
--Declare the local variables: @ln varchar(50), @lnExtracted varchar(50), @fullname varchar(100);
	DECLARE @ln varchar(50)='', @lnExtracted varchar(50)='', @fullname varchar(100)='';
--Declare the local variable: @pid int;
	DECLARE @pid int=0;
--Get inserted values from inserted
	SELECT @ln=LastName, @fullname=FullName from inserted;

--Check if Fullname is provided:
--If the fullname is provided
	IF @fullname IS NOT NULL
	BEGIN
	--Check if lastname is provided:
	--If the lastname is provided
	  IF @ln IS NOT NULL	
	  BEGIN
			--Extract the lastname from the fullname
			SET @lnExtracted = dbo.ufnGetLastName(@fullname);
			--If the provided lastname does not match the extracted lastname,
			--we update the LastName column with the extracted lastname
			IF @ln <> @lnExtracted
			BEGIN
				SET @pid = @@IDENTITY
				PRINT 'The last names do not match. We use the lastname from the fullname';
				UPDATE tblPersonNames SET LastName=@lnExtracted WHERE PersonID=@pid;
				PRINT @fullname + '''s last name has been updated';
			END
			ELSE 
			BEGIN
			--If the provided lastname matches the extracted lastname, we just print a message
				print 'The lastnames match, we do not need to do anything';
			END	
	END  
	--If the lastname is not provided:
	 ELSE 
	 BEGIN
	--extract the lastname from the fullname and update the LastName column of the row
	 SET @lnExtracted=dbo.ufnGetLastName(@fullname);
	 SET @pid = @@IDENTITY;
	 UPDATE tblPersonNames SET LastName=@lnExtracted WHERE PersonID=@pid;
	 PRINT 'Lastname is not provided. We have updated the lastname field';
	 END
	END		
	ELSE
	BEGIN
--If the fullname is not provided, we just print a message
		PRINT 'Full name is not provided. We cannot get the last name';
	END
END

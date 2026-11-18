--*************************************************************************--
-- Title: Assignment06
-- Author: Mjjamsuwan
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 11/16/2026,Mjjamsuwan,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_Mjjamsuwan')
	 Begin 
	  Alter Database [Assignment06DB_Mjjamsuwan] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_Mjjamsuwan;
	 End
	Create Database Assignment06DB_Mjjamsuwan;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_Mjjamsuwan;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

-- First, we will create table base on SQL query to 

-- Select CategoryID, CategoryName
-- From dbo.Categories

-- OR create view called vCategories and simply run;

-- Select * From dbo.vCategories

-- Second, create one view per table as Categories, Products, Employees, and Inventories with SchemaBinding.

-- Categoies View

Create View dbo.vCategories
With SchemaBinding
As 
Select CategoryID, CategoryName
From dbo.Categories;
Go 


-- Products View
 
Create View dbo.vProducts
With SchemaBinding
As 
Select ProductID, ProductName, CategoryID, UnitPrice
From dbo.Products;
Go 

-- Employees View

Create View dbo.vEmployees
With SchemaBinding
As 
Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
From dbo.Employees;
Go 

-- Inventories View

Create View dbo.vInventories 
With SchemaBinding
As 
Select InventoryID, InventoryDate, EmployeeID ProductID, [Count]
From dbo.Inventories;
Go 



-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- Step 1
-- we have 2 layers
-- 1. Table = Categories, Products. Employees, Invwntories
-- 2. View = vCategories, vProducts,vEmployees, vInventories

-- Step 2 Deny Select on 4 tables: to block direct 
-- Select * From Categories
-- Select * From Products
-- Select * From Employees
-- Select * From Inventories

-- Step 3 Grant Select on 4 tables to allow;
-- Select * From vCategories
-- Select * From vProducts
-- Select * From vEmployees
-- Select * From vInventories

-- Step 4 Write and put it together

Deny Select On dbo.Categories To Public;
Deny Select On dbo.Products To Public;
Deny Select On dbo.Employees To Public;
Deny Select On dbo.Inventories To Public;
Go

Grant Select On dbo.vCategories To Public;
Grant Select On dbo.vProducts To Public;
Grant Select On dbo.vEmployees To Public;
Grant Select On dbo.vInventories To Public;
Go 



-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create View dbo.vProductsByCategories
As 
Select Top 100000
 	c.CategoryName, p.ProductName, p.UnitPrice 
From dbo.vCategories 
Inner Join dbo.vProducts
 On vCategories.CategoryID = vProducts.CategoryID
Order By c.CategoryName, p.ProductName;
Go


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Step 1: view name: vInventoriesByproductsByDates
	-- we need 3 columns;
		-- 1. ProductName - from vProducts
		-- 2. InventoryDate - from vInventories
		-- 3. Count - from vInventories

-- Step 2: Use an Inner Join since every Inventory row should be for products, so both view have ProductID
	-- Code: vInventories.ProductID = vProducts.ProductID

-- Step 3: Add Top 100000 to make it legal because it will not allow to use a plain ORDER BY in a view
-- Step 4: write the complete code 

Create View dbo.vInventoriesByProductsByDates
With SchemaBinding
As
Select Top 100000
	p.ProductName, 
	i.InventoryDate, 
	i.[Count]
From dbo.vProducts As p 
Inner Join dbo.vInventories As i 
	On p.ProductID = p.ProductID
Order by 
	p.ProductName, 
	i.InventoryDate,
	i.[Count];
Go


Test View

Select * From dbo.vInventoriesByProductsByDates


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Step 1: Required view name: vInventoriesByEmployeesByDates
-- We need 2 columns:
	-- 1. InventoryDate - from vInventories
	-- 2. EmployeeName - from vEmployees, but need to combined as Firstname and Lastname together
-- Since there's no EmployeeName column in the table, so we have to create it as:
-- EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName

-- Step 2: Both view have EmployeeID so, we use this column to connect them by using INNER JOIN
-- vInventories.EmployeeID = vEmployees.EmployeeID

-- Step 3: Inventories table has multiple products counted on the same date, we will fix the duplicate problem with DISTINCT because we need to remove the duplicated combination of Date and EmployeeName, only show it once. 
-- Also, add Top 100000 to use ORDER BY in a view.

-- Step 4: Wite a complete code as

Create View dbo.vInventoriesByEmployeesByDates
With SchemaBinding
As 
Select Distinct Top 100000
	i.InventoryDate,
	e.EmployeeFirstName + ' ' + e.EmployeeLastName As EmployeeName
From dbo.vInventories As i 
Inner Join dbo.vEmployees As e 
	On i.EmployeeID = e.EmployeeID
Order By 
	i.InventoryDate;
Go 

-- Step 5: Test View

Select * From dbo.vInventoriesByEmployeesByDates
Go



-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Step 1: Required View name = vInventoriesByProductsByCategories
-- we need 4 columns:
	-- 1. CategoryName from vCategories
	-- 2. ProductName from vProducts
	-- 3. InventoryDate from vInventories
	-- 4. Count from vInventories

-- Step 2: We cannot join vCategories directly to vInventories, so we have to go through vProducts as a the bridge to connect them. We will 2 INNER JOIN to connect these table
	-- vInventories.ProductID = vProducts.ProductID
	-- AND
	-- vProducts.CategoryID = vCategories.CategoryID

-- Step 3: Use SCHEMABINDING as requirement and SELECT TOP 100000 + ORDER BY to use in a view

-- Step 4: Write the code one by one, start with;
	-- Inventories:
	-- From dbo.vInventories As i

	-- Add Products:
	-- INNER JOIN dbo.vCategories As c
		-- ON c.CategoryID = p.CategoryID
	
	-- Add Categories:
	-- INNER JOIN dbo.vCateogories As c
		-- On p.CategoryID = c.CategoryID
	
	-- Write a columns and order as
	-- SELECT TO 100000
		-- c.CategoryName,
		-- p.ProductNane,
		-- i.InventoryDate,
		-- i.[Count]

	-- ORDER BY
		-- c.CategoryName,
		-- p.ProductNane,
		-- i.InventoryDate,
		-- i.[Count];

-- Step 5: Connect them together and write the complete code

Create View dbo.vInventoriesByProductsByCategories
With SchemaBinding
As 
Select Top 100000
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.[Count]
From dbo.vCategories As c 
Inner Join dbo.vProducts As p 
	On c.CategoryID = p.CategoryID
Inner Join dbo.vInventories As i 
	On p.ProductID = i.ProductID
Order by 
	c.CategoryName, 
	p.ProductName, 
	i.InventoryDate, 
	i.[Count];
Go 


-- Step 6: Test View

Select * From dbo.vInventoriesByProductsByCategories
Go



-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Step 1: View name = vInventoriesByProductsByCategoriesByEmployees
-- We need 5 columns:
	-- CategoryName - from vCategories
	-- ProductName - from vProducts
	-- InventoryDate - from vInventories
	-- Count - from vInventories
	-- EmployeeName - from vEmployees (create from EmployeeFirstName + ' ' + EmployeeLastName)

-- Step 2: we need 3 join operations to connect 4 tables; use three inner join statements.
	-- vInventories connects to vProducts on ProductID
	-- vProducts connects to vCategories on CategoryID
	-- vInventories connects to vEmployees on EmployeeID
	
-- Step 3: Use SCHEMABINDING as requirement and SELECT TOP 100000 + ORDER BY to use in a view

-- Step 4: Write the code one by one, start with Inventories which is the center (everything joins to it);
	-- Inventoies:
		-- From dbo.vInventories As i

	-- Add Products
		-- INNER JOIN dbo.vProducts As p
			-- ON i.ProductID = p.ProductID

	-- Add Catogories through Products
		-- INNER JOIN dbo.vCategories As c 
			-- ON p.CategoryID = c.Category

	-- Add Employees through Inventories
		-- INNER JOIN dbo.vEmployees As e 
			-- ON i.EmployeeID = e.EmployeeID

	-- Write and connect the columns and orders
		-- SELECT 100000
			-- c.CategoryName,
			-- p.ProductName,
			-- i.InventoryDate,
			-- i.[Count],
			-- e.EmployeeFirstName + ' ' + e.EmployeeLastName As EmployeeName

		-- ORDER BY
			-- i.inventoryDate,
			-- CategoryName,
			-- ProductName,
			-- EmployeeName;

-- Step 5: Write the complete code

Create View dbo.vInventoriesByProductsByCategoriesByEmployees
With SchemaBinding
As 
Select Top 10000
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.Count,
	e.EmployeeFirstName + ' ' + e.EmployeeLastName As EmployeeName
From dbo.vCategories As c 
Inner Join dbo.vProducts As p 
	On c.CategoryID = p.CategoryID
Inner Join dbo.vInventories As i 
	On p.ProductID = i.ProductID
Inner Join dbo.vEmployees As e 
	On i.EmployeeID = e.EmployeeID
Order By 
	i.InventoryDate, 
	c.CategoryName, 
	p.ProductName, 
	e.EmployeeName;
Go

-- Step 6: Test View

Select * From dbo.vInventoriesByProductsByCategoriesByEmployees



-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Step 1: Regarding the Qestion 7, we had a View table already, but we need only 2 products.

-- Step 2: We need products "Chai" and "Chang", so we write the code as;

	-- WHERE p.ProductName IN ('Chai', 'Chang')

	-- We don't use WHERE ProductName = 'Chai' AND 'Chang' because the product cannot be both at the same time, so that it would return 0 row.

-- Step 3: Use SCHEMABINDING as requirement and SELECT TOP 100000 + ORDER BY to use in a view

-- Step 4: Write the complete code

Create View dbo.vInventoriesForChaiAndChangByEmployees
With SchemaBinding
As
Select Top 1000
	c.CategoryName,
	P.ProductName,
	i.InventoryDate,
	i.[Count],
	e.EmployeeFirstName + ' ' + e.EmployeeLastName As EmployeeName
From
	dbo.vCategories As c
Inner Join dbo.vProducts As p 
	On c.CategoryID = P.CategoryID
Inner Join dbo.vInventories As i 
	On p.ProductID = i.ProductID
Inner Join dbo.vEmployees As e 
	On i.EmployeeID = e.EmployeeID
Where 
	p.ProductName In ('Chai', 'Chang')
Order by	
	i.inventoryDate,
	c.CategoryName,
	p.ProductName,
	e.EmployeeName;
Go 

-- Step 5: Test View

Select * From dbo.vInventoriesForChaiAndChangByEmployees



-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Step1: View name: vEmployeesByManager
-- We need 2 columns which are come from the same view as vEmployees
	1. ManagerName
	2. EmployeeName

-- Step 2: we give the same view for two different alias as
	e = Employee
	m = Manager

	-- From dbo.vEmployees As e 
	-- Inner Join dbo.vEmployees As m 
		-- On e.ManagerID = m.EmployeeID

-- Step 3: There is no EmployeeName column, so we create it as;
	-- e.EmployeeFirstName + ' ' + e.EmployeeLastName As EmployeeName
	-- m.EmployeeFirstName + ' ' + m.EmployeeLastName As ManagerName


-- Step 4: Write complete code

Create View dbo.vEmployeesByManager
With SchemaBinding
As 
Select Top 10000
	e.EmployeeFirstName + ' ' + e.EmployeeLastName As EmployeeName,
	m.EmployeeFirstName + ' ' + m.EmployeeLastName As ManagerName
From dbo.vEmployees As e 
Inner Join dbo.vEmployees As m
	On e.ManagerID = m.EmployeeID
Order By
	m.EmployeeFirstName + ' ' + m.EmployeeLastName,
	e.EmployeeFirstName + ' ' + e.EmployeeLastName;
Go

Test View

Select * From dbo.vEmployeesByManager
Go	


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- All data from all 4 basic views and Manager Name, combine it ogether into one view.
-- vCategories 
	CategoryID, CategoryName

-- vProducts
	ProductID, ProductName, CategoryID, UnitPrice

-- vInventories
	InventoryID, InventoryDate, EmployeeID, ProductID, [Count]

-- vEmployees
	EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID

-- Manager (reference to vEmployees)
	ManagerName


Create View dbo.vInventoriesByProductsByCategoriesByEmployees
With SchemaBinding
As
Select Top 10000
	c.CategoryID,
	c.CategoryName,
	p.ProductID,
	p.ProductName,
	P.UnitPrice,
	i.InventoryID,
	i.InventoryDate,
	i.[Count],
	e.EmployeeID,
	e.EmployeeFirstName + ' ' + e.EmployeeLastName As Employee
	m.EmployeeFirstName + ' ' + m.EmployeeLastName As Manager
From dbo.vCategories As c 
Inner Join dbo.vProducts As p 
	On c.CategoryID = p.CategoryID
Inner Join dbo.vInventories As i 
	On p.ProductID = i.ProductID
Inner Join dbo.vEmployees As e 
	On i.EmployeeID = e.EmployeeID
Inner Join dbo.vEmployees As m 
	On e.ManagerID = m.EmployeeID
Order By
	c.CategoryName,
	p.ProductName,
	i.InventoryID,
	e.EmployeeName;
Go


Test View

Select * From dbo.vInventoriesByProductsByCategoriesByEmployees
Go


/***************************************************************************************/

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/
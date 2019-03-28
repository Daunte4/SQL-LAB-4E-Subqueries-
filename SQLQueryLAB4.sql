use Northwind

--1. Show product name and supplier ID 
-- for all products supplied by exotic Liquids
-- Grandma Kelly's Homestead, and Tokyo Traders

select P.ProductName, P.SupplierID
from Products as P
join Suppliers as S
on P.SupplierID = S.SupplierID
where S.CompanyName in ('Exotic Liquids', 'Grandma Kelly''s Homestead', 'Tokyo Traders');


--2. shows all products by name that are in the Seafood category

Select P.ProductName
from Products as P
where P.CategoryID in (Select CategoryID 
                       from Categories 
					   where CategoryName = 'seafood');



--3. shows all companies by name that sell products in CategoryID 8.

Select *
from Suppliers as S
where S.SupplierID in ( Select P.SupplierID 
                        from Products as P 
						where P.CategoryID = 8);


--4.  shows all companies by name that sell products in the Seafood category.
Select *
from Suppliers as S
where S.SupplierID in ( Select P.SupplierID 
                        from Products as P 
						where P.CategoryID = (Select CategoryID 
                                              from Categories 
					                          where CategoryName = 'seafood'));



--5. lists the ten most expensive products.

Select O.ProductName
from (Select top (10) P.ProductName
from Products as P
order by P.UnitPrice desc) as O
order by O.ProductName;


--6. shows the date of the last order by all employee.

Select  E.FirstName, E.LastName, max (O.OrderDate)
from Employees as E
Join Orders as O
on E.EmployeeID = O.EmployeeID
group by E.FirstName, E.LastName;


GO;

USE TSQLV4;

--1

Select O.OrderID, O.OrderDate, O.CustID, O.EmpID
from Sales.Orders as O
where O.OrderDate = ( Select max(OO.OrderDate) from Sales.Orders as OO);

 --2. Return all Orders placed by Customers who placed the highest number
 -- of Orders. More than one customer may have the same number of orders.

 Select top (1) with ties O.CustID 
 from Sales.Orders as O
 group by O.CustID
 order by count(OrderID) desc;

 
 Select O.CustID, O.OrderID, O.OrderDate, O.EmpID
 from Sales.Orders as O
 where O.CustID in (Select top (1) with ties O.CustID 
                    from Sales.Orders as O
                    group by O.CustID);

--3. Return Employees who did not place Orders on or After May 1, 2016 

Select O.EmpID, max (O.OrderDate)
from Sales.Orders as O
group by O.EmpID
having max(O.OrderDate) > '2016-5-1';

Select E.EmpID, E.Firstname, E.Lastname
from HR.Employees as E
where E.EmpID not in ( Select O.EmpID, (O.OrderDate)
from Sales.Orders as O
group by O.EmpID
having (O.OrderDate) > '2016-5-1');

--4 Return countries where there are customers, but not employees

Select Distinct C.Country
from Sales.Customers as C
where C.Country not in ( Select E.Country from HR .Employees as E);

--5. Return for each Customer all orders placed on the customers last day of activity

Select CustID, OrderID, OrderDate, EmpID
from Sales.Orders as O
where O.OrderDate = ( Select max(OrderDate)
                      from Sales.Orders as OO
					  where OO.CustID = O.CustID)
					  order by CustID;


--6. Return Customers who placed orders in 2015 but not 2016

Select *  from Sales.Orders as O 
where year(O.OrderDate) = 2015
and O.CustID not in (Select * from Sales.Orders as O 
                     where year (O.OrderDate) = 2016);  

--7 Return Customers who ordered products 12

Select OD.OrderID
from Sales.OrderDetails as OD 
where OD.ProductID = 12;

Select * 
from Sales.Orders as O
where O.OrderID in (Select OD.OrderID
                    from Sales.OrderDetails as OD
					 where OD.ProductID = 12);

Select CustID, CompanyName
from Sales.Customers
where CustID in (Select O.CustID
                 from Sales.Orders as O
                  where O.OrderID in (Select OD.OrderID
                                      from Sales.OrderDetails as OD
					                  where OD.ProductID = 12));

--8. Calculates a Running average for each Customer and Month quantity


Select CO.CustID, CO.OrderMonth,
(Select sum(C.Qty)
from Sales.CustOrders  as C
where C.CustID = .CustID
and C.OrderMonth <= CO.OrderMonth) as runqty
from Sales.CustOrders as CO
order by CustID, OrderMonth;

-- 9. Explain the difference between IN and Exist Example

Select O.CustID,
(Select CompanyName
 from Sales.Customers
 where CustID = O.CustID) as name
                          from Sales.Orders as O
                          where O.OrderID in (Select OD.OrderID
                          from Sales.OrderDetails as OD
                          where OD.ProductID = 12);




Select CustID, ( Select CompanyName from Sales.Customers where CustID = O.CustID) as name
from Sales.Customers as O
where exists (Select OD.OrderID
                    from Sales.OrderDetails as OD
					where OD.ProductID = 12
					and OD.OrderID = OD.OrderID);



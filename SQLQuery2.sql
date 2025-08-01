--Steps for implementing a function
--Step 1: Creating a table, inserting values
--Step 2: implementing building SCALAR Function
create database EmployeeDB;
use EmployeeDB;
create Table Department(DeptID int primary key,DeptName varchar(50));
use EmployeeDB;
create Table Employee(EmpId int primary key,
EmpName varchar(100), Salary decimal(10,2), DeptId int,
ManagerId int,DateOfJoining date);

Insert into Department values(1,'HR'),(2,'Finance'),(3,'IT');

Insert into Employee values(101,'Raj',70000,3,null,'2024-01-15'),
(102,'Rajiv',35000,2,101,'2025-01-15'),
(103,'Rajesh',40000,3,101,'2021-01-15'),
(104,'Rajni',50000,3,102,'2022-01-15'),
(105,'Rani',70000,1,null,'2020-01-15');
Insert into Employee values(106,'Kishor',80000,null,null,'2018-01-15');
select *from Department;
select *from Employee;

--implementing  built-in scalar function
Select EmpName,Len(EmpName) AS NameLength from Employee;

Select EmpName, round(Salary,-3) As RoundedSalary From Employee;
--positive value rounds  to decimal place (Round(123.456,2) -> 123.46)
--negative Vlaue rounds to power of 10 o the left( Round(12345,-2)-> 12300)
select GETDATE() AS CurrentDate;

--Aggregate Funtions
Select Count(*) As TotalEmployees FRom Employee;
select round(avg(Salary),-2) As AverageSalary from Employee;
Select max(Salary) as MaxSalary From Employee;

--Joins
--Inner Joins:retuns only matching rows from both table
Select e.EmpName,d.DeptName
from Employee e INNER JOIN Department d 
ON e.DeptId=D.DeptId;

--Left Joins:returns all rows from the left table and matched rows from the right table
select e.EmpName,d.DeptName
From Employee e Left Join Department d
on e.DeptId=d.DeptId;

--Right Joins:returns all rows from the right table and matched rows from the left
select e.EmpName,d.DeptName 
from Employee e right join Department d
on e.DeptId=d.DeptId;

--Full Outer Join: returns all rows where all rows where there is a match in one of the table
select e.EmpName,d.DeptName 
from Employee e Full Outer join Department d
on e.DeptId=d.DeptId;

--self Join: a table is joined with itself, of the using aliases
--here we are returning Emp->Manager mapping 
select e1.EmpName AS Employee, e2.EmpName as Manager
From Employee e1
left join Employee e2 on e1.ManagerId=e2.EmpId;

--cross join: returns the cartsian product of two table(all possible combination)
select EmpName,DeptName from Employee cross join Department;

--set operators :are used to combine the results of two or more SELECT querie
--union: Combines results from two queries.Removes duplicates by default.Columns must have the same number and data type.
select DeptId from Department
union
select DeptId from Employee;

--union All: Same as UNION, but keeps duplicates.
select DeptId from Department
union all
select DeptId from Employee;

--Intersect: Returns only the rows that exist in both queries
select DeptId from Department
Intersect
select DeptId from Employee;

-- MINUS( not directly suported in SQL SERVER use Except)
--Returns rows from the first query that do not exist in the second.
select DeptId from Department
Except
select DeptId from Employee;

create procedure DisplayDepartment
as
Begin
select * from Department;
end;

execute DisplayDepartment;

--let create a stored procedure for getting employee details
create procedure GetEmployeeDeatails
@EmpID int, @EmpName varchar(100) output
as
begin
select @EmpName=EmpName from Employee where EmpID=@EmpID;
end;

declare @Name varchar(100);
execute GetEmployeeDeatails 103,@EmpName=@Name output;
print @Name;

--- update employee details

ALTER PROCEDURE UpdateEmployeeDetail
    @EmpID INT, 
    @NewSalary DECIMAL(10,2)
AS
BEGIN

    UPDATE Employee
    SET Salary = @NewSalary
    WHERE EmpID = @EmpID;

    -- Return only updated record
    SELECT * 
    FROM Employee
    WHERE EmpID = @EmpID;
END;
EXEC UpdateEmployeeDetails 
    @EmpID = 101, 
    @NewSalary = 75000.00;

--transaction
BEGIN TRY
	BEGIN Transaction;
	update Employee set Salary=Salary+5000 where DeptId=1;
	commit
END TRY
BEGIN CATCH
	rollback;
	print Error_MESSAGE();
END CATCH

Select *from Employee Where DeptId=1;

--scalar function
CREATE FUNCTION GetYearOfJoining(@EmpId INT)
returns INT
as
BEGIN
	declare @Year Int;
	select @Year=Year(DateOfJoining) from Employee where EmpId=@EmpId;
	return @Year;
END

--calling a function 
SELECT EmpName, dbo.GetYearOfJoining(EmpID) As JoiningYear FROM Employee;

--called function inside Procedure
create procedure PrintEmployeeJoiningYear
@EmpId int
as
begin
declare @Year int;
set @Year = dbo.GetYearOfJoining(@EmpId); 
print 'Joined' + cast (@Year as varchar);
end

execute PrintEmployeeJoiningYear 101;


/* Creating tow tables (Departments, Employees) with relationship and performing JOINS to fetch the data*/

/* create tables */
CREATE TABLE Departments (
    departmentid INT PRIMARY KEY IDENTITY(1,1),      /* identity (seed, increment) */
    departmentname NVARCHAR(50) NOT NULL
);

CREATE TABLE Employees (
    empid INT PRIMARY KEY IDENTITY(1,1),
    firstname NVARCHAR(50) NOT NULL,
    lastname NVARCHAR(50) NOT NULL,
    departmentid INT FOREIGN KEY REFERENCES Departments(DepartmentID)
);

/* insert data */
INSERT INTO Departments (DepartmentName) VALUES 
('HR'),
('Delivery'),
('BD'),
('Marketing'),
('Management');

INSERT INTO Employees VALUES 
('Bhudevi', 'Dobbala', 2),
('Sana', 'Syed', 1),
('Shivani', 'Katakam', 3),
('Sravanthi', 'Mendu', 4),
('Bhudevi', 'D');

/*INNER JOIN - fetch employees having valid department*/
SELECT e.empId, e.firstname, e.lastname, d.departmentname
FROM Employees e
INNER JOIN Departments d ON e.departmentid = d.departmentid;

/*LEFT JOIN - fetch all the employees even without having department*/
SELECT e.empId, e.firstname, e.lastname, d.departmentname
FROM Employees e
LEFT JOIN Departments d ON e.departmentid = d.departmentid;

/*RIGHT JOIN - fetch all departments, including those without employees*/
SELECT e.empId, e.firstname, e.lastname, d.departmentname
FROM Employees e
RIGHT JOIN Departments d ON e.departmentid = d.departmentid;

/* FULL OUTER JOIN - fetch all the employees and departmnets, matching them where possible */
SELECT e.empId, e.firstname, e.lastname, d.departmentname
FROM Employees e
FULL OUTER JOIN Departments d ON e.departmentid = d.departmentid;

/*CROSS JOIN - fetch all the combinations od employees and departments*/
SELECT e.FirstName, e.LastName, d.DepartmentName
FROM Employees e
CROSS JOIN Departments d;

/* create stored procedures*/
CREATE PROCEDURE AddEmployee
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @DepartmentID INT
AS
BEGIN
    INSERT INTO Employees (firstname, lastname, departmentid)
    VALUES (@FirstName, @LastName, @DepartmentID);

    PRINT 'Employee added successfully!';
END;

/* execute stored procedure*/
EXEC AddEmployee @FirstName = 'Bhudevi', @LastName = 'Devi', @DepartmentID = 4;

/*create function*/
CREATE FUNCTION GetEmployeeFullName(@EmpID INT)
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @FullName NVARCHAR(100);

    SELECT @FullName = firstname + ' ' + lastname
    FROM Employees
    WHERE empid = @EmpID;

    RETURN @FullName;
END;

/*execute function*/
SELECT dbo.GetEmployeeFullName(1) AS FullName;

/*create a table to log department changes*/
CREATE TABLE DepartmentChangeLog (
    logID INT PRIMARY KEY IDENTITY(1,1),
    empID INT NOT NULL,
    oldDepartmentID INT,
    newDepartmentID INT,
    changeDate DATETIME DEFAULT GETDATE()
);

/*create trigger*/
CREATE TRIGGER LogDepartmentChange
ON Employees
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE DepartmentID <> (SELECT DepartmentID FROM deleted))
    BEGIN
        INSERT INTO DepartmentChangeLog (EmpID, OldDepartmentID, NewDepartmentID)
        SELECT d.EmpID, d.DepartmentID AS OldDepartmentID, i.DepartmentID AS NewDepartmentID
        FROM deleted d
        INNER JOIN inserted i ON d.EmpID = i.EmpID;
    END;
END;

/*record will be inserted into department  logs table when ever department is updated in employees table*/
update employees set departmentid=4 where empid=1

/*creating a view to display all the employee details*/
CREATE VIEW EmployeeDetails AS
SELECT 
    e.EmpID,
    e.FirstName,
    e.LastName,
    d.DepartmentName,
    e.DepartmentID
FROM 
    Employees e
LEFT JOIN 
    Departments d ON e.DepartmentID = d.DepartmentID;

/*executing the view*/
SELECT * FROM EmployeeDetails;

/*updating the view to change the fields in the view*/
ALTER VIEW EmployeeDetails AS
SELECT 
    e.EmpID,
    e.FirstName,
    e.LastName,
    d.DepartmentName
FROM 
    Employees e
INNER JOIN 
    Departments d ON e.DepartmentID = d.DepartmentID;

/*update base table data through view*/
UPDATE EmployeeDetails
SET FirstName = 'Devi'
WHERE EmpID = 1;

/*drop the view*/
DROP VIEW EmployeeDetails;

/*create clustered index*/
CREATE CLUSTERED INDEX IX_Employees_DepartmentID 
ON Employees(DepartmentID);

/*create non clustered index*/
CREATE NONCLUSTERED INDEX IX_Employees_LastName 
ON Employees(LastName);

/*indexed view*/
CREATE VIEW EmployeeSummary WITH SCHEMABINDING AS
SELECT 
    e.EmpID,
    e.FirstName,
    e.LastName,
    e.DepartmentID
FROM 
    dbo.Employees e;

/*creating clustered index on the view*/
CREATE UNIQUE CLUSTERED INDEX IX_EmployeeSummary ON EmployeeSummary(EmpID);

CREATE TABLE EmployeesDetails (
    EmployeeID INT PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    ManagerID INT NULL,
    Department NVARCHAR(50) NOT NULL
);

INSERT INTO EmployeesDetails (EmployeeID, Name, ManagerID, Department)
VALUES
    (1, 'Bhudevi', NULL, 'HR'),
    (2, 'Devi', 1, 'IT'),
    (3, 'Sana', 2, 'IT'),
    (4, 'Shivani', 2, 'IT'),
    (5, 'Sravanthi', 1, 'HR'),
    (6, 'Madhuri', 5, 'HR');

/*create CTE*/
WITH IT_Employees AS (
    SELECT EmployeeID, Name, Department
    FROM EmployeesDetails
    WHERE Department = 'IT'
)
SELECT *
FROM IT_Employees;

/* create recursive CTE*/
WITH EmployeeHierarchy (EmployeeID, Name, ManagerID, Level)
AS (
    SELECT EmployeeID, Name, ManagerID, 1 AS Level
    FROM EmployeesDetails
    WHERE ManagerID IS NULL

    UNION ALL

    -- Recursive query: Employees reporting to current level employees
    SELECT e.EmployeeID, e.Name, e.ManagerID, eh.Level + 1
    FROM EmployeesDetails e
    INNER JOIN EmployeeHierarchy eh
    ON e.ManagerID = eh.EmployeeID
)
SELECT *
FROM EmployeeHierarchy;

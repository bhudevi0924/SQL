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

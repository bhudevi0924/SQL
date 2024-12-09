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

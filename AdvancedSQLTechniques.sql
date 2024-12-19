-- creating local temporary table
CREATE TABLE #TempTable (
    ID INT PRIMARY KEY,
    Name NVARCHAR(50),
    Age INT
);

INSERT INTO #TempTable (ID, Name, Age)
VALUES (1, 'Bhudevi', 22), (2, 'Devi', 23);

SELECT * FROM #TempTable;

DROP TABLE #TempTable; -- Explicitly drop when done

--creating global temp table
CREATE TABLE ##GlobalTempTable (
    ID INT PRIMARY KEY,
    Name NVARCHAR(50)
);

INSERT INTO ##GlobalTempTable (ID, Name)
VALUES (1, 'Bhudevi'), (2, 'Devi');

SELECT * FROM ##GlobalTempTable;

-- WINDOW FUNCTIONS
ALTER TABLE Employees ADD salary bigint;

--ranking fns (ranking employees based on salary)
SELECT 
    empid, 
    firstname,
    lastname, 
    salary,
    RANK() OVER (ORDER BY Salary DESC) AS Rank,
    DENSE_RANK() OVER (ORDER BY Salary DESC) AS DenseRank,
    ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNumber
FROM Employees;
--aggregate fns (calculate sum and avg of salary)
SELECT 
    empid, 
    firstname, 
	lastname,
    Salary,
    SUM(Salary) OVER (PARTITION BY DepartmentID ORDER BY Salary) AS RunningTotal,
    AVG(Salary) OVER (PARTITION BY DepartmentID) AS AverageSalary
FROM Employees;
-- value fns
SELECT 
    empid, 
    firstname,
	lastname,
    salary,
    LAG(salary) OVER (ORDER BY salary) AS PreviousSalary,
    LEAD(salary) OVER (ORDER BY salary) AS NextSalary,
    FIRST_VALUE(salary) OVER (ORDER BY salary) AS LowestSalary,
    LAST_VALUE(salary) OVER (ORDER BY salary ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS HighestSalary
FROM Employees;
-- row/range clause
SELECT 
    empid, 
    firstname,
	lastname,
    salary,
    AVG(salary) OVER (
        ORDER BY empid 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS MovingAverage
FROM Employees;

--SUBQUERIES
--single value(scalar) subquery
SELECT empid, firstname,lastname, salary
FROM Employees
WHERE Salary > (SELECT AVG(Salary) FROM Employees);

--multi value subquery
SELECT empid, firstname,lastname
FROM Employees
WHERE DepartmentID IN (SELECT DepartmentID FROM Departments WHERE salary > 25000);

--correlated subquery
SELECT empid, firstname,lastname, DepartmentID, Salary
FROM Employees e
WHERE Salary > (
    SELECT AVG(Salary) 
    FROM Employees 
    WHERE DepartmentID = e.DepartmentID
);

--nested subquery
SELECT empid, firstname,lastname, DepartmentID
FROM Employees
WHERE DepartmentID = (
    SELECT TOP 1 DepartmentID
    FROM (
        SELECT DepartmentID, COUNT(*) AS EmployeeCount
        FROM Employees
        GROUP BY DepartmentID
    ) AS DepartmentCounts
    ORDER BY EmployeeCount DESC
);

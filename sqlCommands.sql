CREATE DATABASE PracticeDB  /*create a database*/
DROP DATABASE PracticeDB    /*drop the database*/

/*Create a full backup of an existing SQL database */
BACKUP DATABASE PracticeDB
TO DISK = 'F:\backupFile.sql'

/*Backup with "differential" -> backups only the parts of the database that have changed since last full database backup.*/
BACKUP DATABASE PracticeDB
TO DISK = 'F:\backupFile.sql'
WITH DIFFERENTIAL;

/*create a table*/
CREATE TABLE Employees (
	empid int,
	empname varchar(50),
	mobilenumber varchar(10),
	city varchar(50)
);

/*create  a table using existing table*/
CREATE TABLE EmployeeCity AS
SELECT empid, city
FROM Employees;                        /*This will create a new table with columns definition same as in Employees table and get the vlaues from old table.*/

DROP TABLE EmployeeCity /*drop the table*/
TRUNCATE TABLE EmployeeCity /*delete only table data */

/*ALTER commands*/
ALTER TABLE Employees ADD email varchar(255); /* adds a new column to the table */
ALTER TABLE Employees DROP COLUMN email;      /* deletes column in the table */
ALTER TABLE Employees RENAME COLUMN mobilenumber to empmobileno; /* renames mobile number column */
ALTER TABLE Employees ALTER COLUMN empid varchar; /* changes datatype of the column*/

INSERT INTO Employees values(174, 'Bhudevi Dobbala', '9515604545', 'Hyderabad'); /* insert data into table */
INSERT INTO Employees (empid, empname) values(174, 'Bhudevi Dobbala');  /* insert data to specific columns */
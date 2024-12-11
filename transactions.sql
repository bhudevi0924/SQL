create table transactions(
id int,
accountname varchar(50),
balance bigint
)

insert into transactions values(1,'Bhudevi',1000),(2,'Devi',1000);

/*create a transaction to transfer money from one account to another*/
BEGIN TRY
	BEGIN TRANSACTION
		UPDATE transactions SET balance = balance-100 WHERE id=1
		UPDATE transactions SET balance = balance+100 WHERE id=2
	COMMIT TRANSACTION
	PRINT 'Transaction Completed!'
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	PRINT 'Transaction Rolled back'
END CATCH

create table products(
id int,
productname varchar(100),
itemsperstock int
)

insert into products values(1,'Samsung s23',10)

/*DIRTY READ*/

Begin Tran
update products set itemsperstock = 9 where id=1
--Bill the customer
waitfor Delay '00:00:15'
Rollback Transaction

/*Execute this in paraller query tab and this will wait unti the above transatcion is done. 
The result of this query will have itemsperstock as 10*/
select * from products where id=1

/*after settingisolation level as read uncommitted
 the select query will be run immediately without waiting for the above transaction to complete.
 The result of itemsperstock will be 9 here*/
set tran isolation level read uncommitted
select * from products where id=1 
--(OR)
select * from products (NOLOCK) where id=1 -- this works same as setting isolation level to read uncommitted

/*LOST UPDATE*/
-- Transaction 1
Begin tran
Declare @ItemsPerStock int
select @ItemsPerStock = itemsperstock from products where id=1

waitfor delay '00:00:10'
set @ItemsPerStock = @ItemsPerStock-1

update products
set itemsperstock = @ItemsPerStock where id=1
Print @ItemsPerStock
Commit Transaction

-- Transaction 2
Begin tran
Declare @ItemsPerStock int
select @ItemsPerStock = itemsperstock from products where id=1

waitfor delay '00:00:1'
set @ItemsPerStock = @ItemsPerStock-2
update products
set itemsperstock = @ItemsPerStock where id=1

Print @ItemsPerStock
Commit Transaction
/*over all the itemsperstock after two transations will be set as 9 in the products table instead of 7
as those two transactions access and update the same data*/

/*after running this and running the above 2 transactions, the count will be 7
as the 2nd tranction will be locked by 1st trasaction. Shows error as
Transaction (Process ID 66) was deadlocked on lock resources with another process and has been chosen as the deadlock victim. Rerun the transaction.
*/
set tran isolation level repeatable read 

/*NON REPEATABLE READ*/
--tran 1
Begin tran
select itemsperstock from products where id=1 --query 1

waitfor delay '00:00:10'

select itemsperstock from products where id=1 -- query 2
commit transaction

-- tran 2
update products set itemsperstock=5 where id=1
/*the output of query 1 and 2 in tran 1 will be 10 and 5 respectively if we run tran 2 inbetween the progress of the tran 1
To over come this problem, set isolation level to repeatable read or higher*/

create table emp(
id int,
empname varchar(50)
)

insert into emp values(1,'Bhudevi'),(3,'Devi')

/*PHONTOM READ*/
--tran 1
Begin transaction
select * from emp where id between 1 and 3 --query 1

waitfor delay '00:00:10'

select * from emp where id between 1 and 3 --query 2

-- tran 2
insert into emp values(2,'Bhudevi Dobbala')
/*the output of query 1 and 2 in tan 1 will be 2rows and 3 rows respectively if we run tran 2 while tran 1 is in progress.
To avoid that set isolation level to snapshot or serializable. It will block tran 2 until tran 1 is done.*/
set tran isolation level serializable
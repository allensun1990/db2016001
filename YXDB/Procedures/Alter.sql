use IntFactory

alter table customer add FirstName varchar(10)  null



update Customer
set FirstName=dbo.fun_getFirstPY(left(name,1))

alter table Customer add ContactName nvarchar(100) default ''

Update Customer set ContactName=c.name from Contact c where Customer.CustomerID=c.CustomerID
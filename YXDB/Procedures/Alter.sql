
--处理客户需求单和订单数
alter table Customer add DemandCount int default 0
alter table Customer add DYCount int default 0
alter table Customer add DHCount int default 0

update Orders set OrderStatus=1 where OrderStatus=0 and Status=4

update Customer set DemandCount=0,DYCount=0,DHCount=0

update C set DemandCount=o.Quantity from Customer c join
(select CustomerID,COUNT(AutoID) Quantity from Orders where OrderStatus=0 group by CustomerID) o on c.CustomerID=o.CustomerID

update C set DYCount=o.Quantity from Customer c join
(select CustomerID,COUNT(AutoID) Quantity from Orders where OrderStatus between 1 and 2 and OrderType=1 group by CustomerID) o on c.CustomerID=o.CustomerID

update C set DHCount=o.Quantity from Customer c join
(select CustomerID,COUNT(AutoID) Quantity from Orders where OrderStatus between 1 and 2 and OrderType=2 group by CustomerID) o on c.CustomerID=o.CustomerID

alter table OrderDetail add OrderQuantity int default 0
alter table OrderDetail add PlanQuantity decimal(18,4) default 0
Go
Update d set OrderQuantity=o.PlanQuantity,PlanQuantity=o.PlanQuantity*d.Quantity,TotalMoney=(o.PlanQuantity*d.Quantity+d.PurchaseQuantity)*d.Price
from OrderDetail d join Orders o on d.OrderID=o.OrderID
GO
update o set Price=d.TotalMoney from Orders o join
(select OrderID,SUM(TotalMoney) TotalMoney from OrderDetail group by OrderID) d on o.OrderID=d.OrderID
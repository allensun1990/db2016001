
return

--删除无效菜单和权限
delete from Menu where MenuCode in ('103029001','103029003','103030301','103030303','103030401','103030403')


--同步工厂人数和到期时间
update C set EndTime=a.EndTime,UserQuantity=a.UserQuantity from agents a join Clients c on a.ClientID=c.ClientID

--购物车单位名称冗余
alter table ShoppingCart add UnitName nvarchar(20)
GO
update s  set UnitName=u.UnitName from ShoppingCart s join ProductUnit u on s.UnitID=u.UnitID  

--Orders 表 PlanPrice 改为 decimal 类型
alter table Orders alter column PlanPrice decimal(18,4)
GO

--处理批次信息
update StorageDetail set BatchCode=''
GO
select ProductDetailID,ProductID,WareID,DepotID,ClientID,SUM(StockIn) StockIn,sum(StockOut) StockOut into #tempstock from ProductStock 
group by ProductDetailID,ProductID,WareID,DepotID,ClientID
GO
truncate table ProductStock
GO
insert into ProductStock(ProductDetailID,ProductID,WareID,DepotID,ClientID,StockIn,StockOut)
select ProductDetailID,ProductID,WareID,DepotID,ClientID,StockIn,StockOut from #tempstock
Go
Drop table #tempstock

--注册来源
alter table Clients add RegisterType int default 0
GO
update Clients set RegisterType=1
Update Clients set RegisterType=3 where AliMemberID<>'' and  AliMemberID is not null

--用户名
insert into UserAccounts(AccountName,AccountType,ProjectID,UserID,ClientID)
select LoginName,1,'',UserID,ClientID from Users where LoginName is not null and LoginName<>''

--手机账号
insert into UserAccounts(AccountName,AccountType,ProjectID,UserID,ClientID)
select BindMobilePhone,2,'',UserID,ClientID from Users where BindMobilePhone is not null and BindMobilePhone<>''

--阿里账号
insert into UserAccounts(AccountName,AccountType,ProjectID,UserID,ClientID)
select AliMemberID,3,'',UserID,ClientID from Users where AliMemberID is not null and AliMemberID<>''

--微信账号 
insert into UserAccounts(AccountName,AccountType,ProjectID,UserID,ClientID)
select WeiXinID,4,'',UserID,ClientID from Users where WeiXinID is not null and WeiXinID<>''

--处理流程和品类 CategoryID 需要更改
alter table OrderProcess add CategoryID nvarchar(64)
GO
update OrderProcess set CategoryID='4902b471-7f9a-42a2-b892-14caabe14ec2' where CategoryType=1 and Status<>9
update OrderProcess set CategoryID='54d1c8bd-bb7c-45d8-a9c1-8c8b6974c221' where CategoryType=2 and Status<>9
GO
truncate table OrderCategory
GO
insert into OrderCategory (CategoryID,ClientID,Layers,PID) 
select CategoryID,ClientID,1,'' from OrderProcess where CategoryID is not null and CategoryID<>'' group by CategoryID,ClientID 
GO
update o set BigCategoryID=p.CategoryID from Orders o join OrderProcess p on o.ProcessID=p.ProcessID


--处理待大货为需求单
Update Orders set OrderStatus=0,Status=0 where Status=4
GO
update Customer set DYCount=0,DHCount=0,DemandCount=0
GO
update C set DemandCount=o.Quantity from Customer c join
(select CustomerID,COUNT(AutoID) Quantity from Orders where OrderStatus=0 group by CustomerID) o on c.CustomerID=o.CustomerID

update C set DYCount=o.Quantity from Customer c join
(select CustomerID,COUNT(AutoID) Quantity from Orders where OrderStatus>0 and OrderStatus<>9 and OrderType=1 group by CustomerID) o on c.CustomerID=o.CustomerID

update C set DHCount=o.Quantity from Customer c join
(select CustomerID,COUNT(AutoID) Quantity from Orders where OrderStatus>0 and OrderStatus<>9 and OrderType=2 group by CustomerID) o on c.CustomerID=o.CustomerID




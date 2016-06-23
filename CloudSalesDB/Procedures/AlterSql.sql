
--统计表
alter table M_Report_AgentAction_Day add ActionType int not null default(1)
GO
--城市描述
alter table City  Add [Description] nvarchar(1000) default ''
GO
update City set [Description]=Province+' '+City+' '+Counties

--处理产品表
alter table Products add HasDetails int default 0
--ProdiverID 改 ProviderID，SmallUnitID 改 UnitID
GO
Update Products set HasDetails=0

update Products set HasDetails=1 where CategoryID in(
select CategoryID from CategoryAttr where Type=2 and Status<>9 group by CategoryID
)

--处理产品明细
alter table ProductDetail add Remark nvarchar(400) default ''
alter table ProductDetail add IsDefault int default 0
GO
update ProductDetail set IsDefault=0,Remark=SaleAttrValue
update ProductDetail set IsDefault=1 where SaleAttr=''

INSERT INTO ProductDetail(ProductDetailID,[ProductID],DetailsCode ,[SaleAttr],[AttrValue],[SaleAttrValue],[Price],[BigPrice],[Status],
					Weight,ImgS,[ShapeCode] ,[Description],[CreateUserID],[CreateTime] ,[UpdateTime],[OperateIP] ,[ClientID],IsDefault)
select NEWID(),ProductID,ProductCode,'','','',Price,Price,1,
					Weight,ProductImage,'','',CreateUserID,getdate(),getdate(),'',ClientID,1 from Products
					where ProductID not in(select ProductID from ProductDetail where IsDefault=1)

--(重复执行)
Update p set Remark=REPLACE(Remark,AttrID,AttrName) from ProductDetail p join ProductAttr a on CHARINDEX(a.AttrID, p.Remark)>0
Update p set Remark=REPLACE(Remark,ValueID,ValueName) from ProductDetail p join AttrValue a on CHARINDEX(a.ValueID, p.Remark)>0

update ProductDetail set Remark='['+Remark+']'
update ProductDetail set Remark=REPLACE(Remark,':','：')
update ProductDetail set Remark=REPLACE(Remark,',','] [')


--处理机会表
alter table Opportunity add TypeID nvarchar(64) default ''
alter table Opportunity add OrderCode nvarchar(50) default ''

alter table OpportunityProduct add CreateUserID nvarchar(64)
alter table OpportunityProduct add CreateTime datetime default getdate()
alter table OpportunityProduct add ImgS nvarchar(500) default ''

--订单表
alter table Orders add OpportunityID nvarchar(64) default ''
alter table Orders add OpportunityCode nvarchar(50) default ''

insert into Opportunity(OpportunityID,OpportunityCode,Status,TypeID,StageID,TotalMoney,CityCode,Address,PostalCode,PersonName,MobileTele,Remark,CustomerID,OwnerID,CreateTime,OrderTime,OrderID,CreateUserID,AgentID,ClientID)
select NEWID(),OrderCode,1,TypeID,StageID,TotalMoney,CityCode,Address,PostalCode,PersonName,MobileTele,Remark,CustomerID,OwnerID,CreateTime,OrderTime,OrderID,CreateUserID,AgentID,ClientID from Orders

delete from Orders where Status=0

update opp set Status=2,OrderCode=o.OrderCode from Opportunity opp join Orders o on opp.OrderID=o.OrderID
update o set OpportunityID=opp.OpportunityID,OpportunityCode=opp.OpportunityCode from Opportunity opp join Orders o on opp.OrderID=o.OrderID
update Opportunity set OrderID='',TotalMoney=0 where Status=1

--机会意向产品
insert into OpportunityProduct(OpportunityID,ProductDetailID,ProductID,UnitID,IsBigUnit,Quantity,Price,TotalMoney,Remark,ClientID)
select  OpportunityID,d.ProductDetailID,d.ProductID,d.UnitID,d.IsBigUnit,d.Quantity,d.Price,d.TotalMoney,d.Remark,o.ClientID from Opportunity o join OrderDetail d on o.OrderID=d.OrderID


--机会阶段排序
Update OpportunityStage set Sort=1 where Mark=1

update o set Sort=2 from OpportunityStage o join
(select min(Probability) Probability,ClientID from OpportunityStage
where Status=1 and Sort=0  group by ClientID ) op on o.ClientID=op.ClientID and o.Probability=op.Probability

update o set Sort=3 from OpportunityStage o join
(select min(Probability) Probability,ClientID from OpportunityStage
where Status=1 and Sort=0  group by ClientID ) op on o.ClientID=op.ClientID and o.Probability=op.Probability

update o set Sort=4 from OpportunityStage o join
(select min(Probability) Probability,ClientID from OpportunityStage
where Status=1 and Sort=0  group by ClientID ) op on o.ClientID=op.ClientID and o.Probability=op.Probability

--客户阶段状态
alter table Customer add StageStatus int default 1
alter table Customer add OpportunityID nvarchar(64)
alter table Customer add OpportunityTime datetime
alter table Customer add OrderID nvarchar(64)
alter table Customer add  OpportunityCount int default 0
alter table Customer add  OrderCount int default 0
update Customer set StageStatus=1,OpportunityCount=0,OrderCount=0
update Customer set StageStatus=2 where CustomerID in (select CustomerID from Opportunity)
update Customer set StageStatus=3 where CustomerID in (select CustomerID from Orders where Status>=2)

update c set OpportunityID=op.OpportunityID,OpportunityTime=op.CreateTime from Customer c join 
(select CustomerID,min(AutoID) AutoID from Opportunity where Status<>9 group by CustomerID ) o on c.CustomerID=o.CustomerID
join Opportunity op on o.AutoID=op.AutoID

update c set OrderID=op.OrderID,OrderTime=op.OrderTime from Customer c join 
(select CustomerID,min(AutoID) AutoID from Orders where Status >=2 and Status<>9 group by CustomerID ) o on c.CustomerID=o.CustomerID
join Orders op on o.AutoID=op.AutoID


update c set OpportunityCount=o.Quantity from Customer c join 
(select CustomerID,count(AutoID) Quantity from Opportunity where Status<>9 group by CustomerID ) o on c.CustomerID=o.CustomerID

update c set OrderCount=o.Quantity from Customer c join 
(select CustomerID,count(AutoID) Quantity from Orders where Status<>9 and Status>=2 group by CustomerID ) o on c.CustomerID=o.CustomerID


--购物车
alter table ShoppingCart add ProductName nvarchar(100) default ''
alter table ShoppingCart add ProductCode nvarchar(100) default ''
alter table ShoppingCart add DetailsCode nvarchar(100) default ''
alter table ShoppingCart add ProductImage nvarchar(200) default ''
alter table ShoppingCart add ImgS nvarchar(500) default ''
alter table ShoppingCart add ProviderID nvarchar(64) default ''
alter table ShoppingCart add ProviderName nvarchar(100) default ''

update s set ProductName=p.ProductName,ProductCode=p.ProductCode,DetailsCode=d.DetailsCode,ProductImage=p.ProductImage,ImgS=d.ImgS,Remark=d.Remark,UnitID=p.UnitID 
from ShoppingCart s join Products p on s.ProductID=p.ProductID 
join ProductDetail d on s.ProductDetailID=d.ProductDetailID

--订单明细
alter table OrderDetail add ProductName nvarchar(100) default ''
alter table OrderDetail add ProductCode nvarchar(100) default ''
alter table OrderDetail add DetailsCode nvarchar(100) default ''
alter table OrderDetail add ProductImage nvarchar(200) default ''
alter table OrderDetail add ImgS nvarchar(500) default ''
alter table OrderDetail add ProviderID nvarchar(64) default ''
alter table OrderDetail add ProviderName nvarchar(100) default ''
alter table OrderDetail add CreateUserID nvarchar(64)
alter table OrderDetail add CreateTime datetime default getdate()

update s set ProductName=p.ProductName,ProductCode=p.ProductCode,DetailsCode=d.DetailsCode,ProductImage=p.ProductImage,ImgS=d.ImgS,Remark=d.Remark,UnitID=p.UnitID 
from OrderDetail s join Products p on s.ProductID=p.ProductID 
join ProductDetail d on s.ProductDetailID=d.ProductDetailID

--代理商采购单明细
alter table AgentsOrderDetail add ProductName nvarchar(100) default ''
alter table AgentsOrderDetail add ProductCode nvarchar(100) default ''
alter table AgentsOrderDetail add DetailsCode nvarchar(100) default ''
alter table AgentsOrderDetail add ProductImage nvarchar(200) default ''
alter table AgentsOrderDetail add ImgS nvarchar(500) default ''
alter table AgentsOrderDetail add ProviderID nvarchar(64) default ''
alter table AgentsOrderDetail add ProviderName nvarchar(100) default ''

update s set ProductName=p.ProductName,ProductCode=p.ProductCode,DetailsCode=d.DetailsCode,ProductImage=p.ProductImage,Remark=d.Remark,UnitID=p.UnitID 
from AgentsOrderDetail s join Products p on s.ProductID=p.ProductID 
join ProductDetail d on s.ProductDetailID=d.ProductDetailID


--单据表明细
alter table StorageDetail add Complete int default 0
alter table StorageDetail add ProductName nvarchar(100) default ''
alter table StorageDetail add ProductCode nvarchar(100) default ''
alter table StorageDetail add DetailsCode nvarchar(100) default ''
alter table StorageDetail add ProductImage nvarchar(200) default ''
alter table StorageDetail add ProviderID nvarchar(64) default ''
alter table StorageDetail add ProviderName nvarchar(100) default ''

update StorageDetail set Complete=Quantity*Status

update s set ProductName=p.ProductName,ProductCode=p.ProductCode,DetailsCode=d.DetailsCode,ProductImage=p.ProductImage,Remark=d.Remark,UnitID=p.UnitID 
from StorageDetail s join Products p on s.ProductID=p.ProductID 
join ProductDetail d on s.ProductDetailID=d.ProductDetailID


--产品流水表
alter table ProductStream add Remark nvarchar(4000) default ''
alter table ProductStream add ProductName nvarchar(100) default ''
alter table ProductStream add ProductCode nvarchar(100) default ''
alter table ProductStream add DetailsCode nvarchar(100) default ''
alter table ProductStream add ProductImage nvarchar(200) default ''
alter table ProductStream add ProviderID nvarchar(64) default ''
alter table ProductStream add ProviderName nvarchar(100) default ''

update s set ProductName=p.ProductName,ProductCode=p.ProductCode,DetailsCode=d.DetailsCode,ProductImage=p.ProductImage,Remark=d.Remark 
from ProductStream s join Products p on s.ProductID=p.ProductID 
join ProductDetail d on s.ProductDetailID=d.ProductDetailID

alter table AgentsStream add Remark nvarchar(4000) default ''
alter table AgentsStream add ProductName nvarchar(100) default ''
alter table AgentsStream add ProductCode nvarchar(100) default ''
alter table AgentsStream add DetailsCode nvarchar(100) default ''
alter table AgentsStream add ProductImage nvarchar(200) default ''
alter table AgentsStream add ProviderID nvarchar(64) default ''
alter table AgentsStream add ProviderName nvarchar(100) default ''

update s set ProductName=p.ProductName,ProductCode=p.ProductCode,DetailsCode=d.DetailsCode,ProductImage=p.ProductImage,Remark=d.Remark 
from AgentsStream s join Products p on s.ProductID=p.ProductID 
join ProductDetail d on s.ProductDetailID=d.ProductDetailID

-- 处理订单
alter table Orders add OutStatus int default 0
update Orders set OutStatus=0 where SendStatus=0
update Orders set OutStatus=1 where SendStatus>0

alter table AgentsOrders add OutStatus int default 0
update AgentsOrders set OutStatus=0 
update AgentsOrders set OutStatus=1 where SendStatus>0

--处理部分入库单据
insert into StorageDocPart(DocID,DocCode,DocType,Status,TotalMoney,CityCode,Address,Remark,WareID,CreateUserID,CreateTime,OperateIP,ClientID,OriginalID,OriginalCode)
		select NEWID(),DocCode,1,2,TotalMoney,CityCode,Address,'',WareID,CreateUserID,GETDATE(),'',ClientID,DocID,DocCode from StorageDoc where DocType=1 and Status between 1 and 2

insert into StoragePartDetail(DocID,ProductDetailID,ProductID,UnitID,IsBigUnit,Quantity,Price,TotalMoney,WareID,DepotID,BatchCode,Status,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage )
			select s.DocID,ProductDetailID,ProductID,UnitID,0,Quantity,Price,Price*Quantity,s.WareID,DepotID,BatchCode,0,d.Remark,s.ClientID,ProductName,ProductCode,DetailsCode,ProductImage 
			from StorageDocPart s join StorageDetail d on s.OriginalID=d.DocID where d.Status=1

update s set TotalMoney=n.TotalMoney from StorageDocPart s join
(select DocID,SUM(TotalMoney) TotalMoney from StoragePartDetail group by DocID) n on s.DocID=n.DocID


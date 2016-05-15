﻿
alter table M_Report_AgentAction_Day add ActionType int not null default(1)

--ProdiverID 改 ProviderID

--城市描述
alter table City  Add [Description] nvarchar(1000) default ''
update City set [Description]=Province+' '+City+' '+Counties

--客户阶段状态
alter table Customer add StageStatus int default 1
update Customer set StageStatus=1
update Customer set StageStatus=2 where CustomerID in (select CustomerID from Orders)
update Customer set StageStatus=3 where CustomerID in (select CustomerID from Orders where Status>=2)

--产品明细
alter table ProductDetail add Remark nvarchar(400) default ''

--机会表
alter table Opportunity add TypeID nvarchar(64) default ''
alter table Opportunity add OrderCode nvarchar(50) default ''

alter table OpportunityProduct add CreateUserID nvarchar(64)
alter table OpportunityProduct add CreateTime datetime default getdate()
alter table OpportunityProduct add ImgS nvarchar(500) default ''

--订单表
alter table Orders add OpportunityID nvarchar(64) default ''
alter table Orders add OpportunityCode nvarchar(50) default ''

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

--代理商采购单明细
alter table AgentsOrderDetail add ProductName nvarchar(100) default ''
alter table AgentsOrderDetail add ProductCode nvarchar(100) default ''
alter table AgentsOrderDetail add DetailsCode nvarchar(100) default ''
alter table AgentsOrderDetail add ProductImage nvarchar(200) default ''
alter table AgentsOrderDetail add ProviderID nvarchar(64) default ''
alter table AgentsOrderDetail add ProviderName nvarchar(100) default ''

--单据表明细
alter table StorageDetail add ProductName nvarchar(100) default ''
alter table StorageDetail add ProductCode nvarchar(100) default ''
alter table StorageDetail add DetailsCode nvarchar(100) default ''
alter table StorageDetail add ProductImage nvarchar(200) default ''
alter table StorageDetail add ProviderID nvarchar(64) default ''
alter table StorageDetail add ProviderName nvarchar(100) default ''

--处理老数据机会
insert into Opportunity(OpportunityID,OpportunityCode,Status,TypeID,StageID,TotalMoney,CityCode,Address,PostalCode,PersonName,MobileTele,Remark,CustomerID,OwnerID,CreateTime,OrderTime,OrderID,CreateUserID,AgentID,ClientID)
select NEWID(),OrderCode,1,TypeID,StageID,TotalMoney,CityCode,Address,PostalCode,PersonName,MobileTele,Remark,CustomerID,OwnerID,CreateTime,OrderTime,OrderID,CreateUserID,AgentID,ClientID from Orders

delete from Orders where Status=0

update opp set Status=2,OrderCode=o.OrderCode from Opportunity opp join Orders o on opp.OrderID=o.OrderID
update o set OpportunityID=opp.OpportunityID,OpportunityCode=opp.OpportunityCode from Opportunity opp join Orders o on opp.OrderID=o.OrderID

update Opportunity set OrderID='',TotalMoney=0 where Status=1

--机会意向产品
insert into OpportunityProduct(OpportunityID,ProductDetailID,ProductID,UnitID,IsBigUnit,Quantity,Price,TotalMoney,Remark,ClientID)
select  OpportunityID,d.ProductDetailID,d.ProductID,d.UnitID,d.IsBigUnit,d.Quantity,d.Price,d.TotalMoney,d.Remark,o.ClientID from Opportunity o join OrderDetail d on o.OrderID=d.OrderID




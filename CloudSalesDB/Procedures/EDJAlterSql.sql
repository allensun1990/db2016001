

DROP  Procedure  P_InsertProductExcel
DROP  Procedure  P_AddShoppingCartBatchIn

--处理产品是否存在子产品
update Products set HasDetails=0
Update Products set HasDetails=1 where ProductID in(
select ProductID from ProductDetail where Status<>9 group by ProductID having COUNT(0)>1
)

--处理材料供应商
update p set ProviderID=pr.ProviderID from Products p join 
(select ProviderID,ClientID from Providers where AutoID in (
select MIN(AutoID) AutoID from Providers where Status<>9 group by ClientID
)) pr on p.ClientID=pr.ClientID

alter table Agents add RegisterType int default 0

Update Agents set RegisterType=3 where MDProjectID is not null and MDProjectID<>''

Update Agents set RegisterType=2 where RegisterType is null

--员工账号表
create table UserAccounts
(
AutoID int identity(1,1) primary key,
AccountName nvarchar(200),
ProjectID nvarchar(64),
AccountType int default 0,
UserID nvarchar(64),
AgentID nvarchar(64),
ClientID nvarchar(64)
)

update Users set LoginName='',BindMobilePhone='',MDUserID=''  where status=9

--用户名
insert into UserAccounts(AccountName,AccountType,ProjectID,UserID,AgentID,ClientID)
select LoginName,1,'',UserID,AgentID,ClientID from Users where LoginName is not null and LoginName<>''

--手机
insert into UserAccounts(AccountName,AccountType,ProjectID,UserID,AgentID,ClientID)
select BindMobilePhone,2,'',UserID,AgentID,ClientID from Users where BindMobilePhone is not null and BindMobilePhone<>''

--明道
insert into UserAccounts(AccountName,AccountType,ProjectID,UserID,AgentID,ClientID)
select MDUserID,3,MDProjectID,UserID,AgentID,ClientID from Users where MDUserID is not null and MDUserID<>''

--系统配置
drop table Dictionary
drop table ClientCustomer

create table ClientSetting
(
AutoID int identity(1,1) primary key,
KeyType int,
NValue nvarchar(200) default '',
DValue decimal(18,4) default 0,
IValue int default 0,
Description nvarchar(500) default '',
ClientID nvarchar(64)
)

--积分来源
insert into ClientSetting(KeyType,NValue,DValue,IValue,Description,ClientID)
select 1,'',0,2,'',ClientID from Clients

--积分比例
insert into ClientSetting(KeyType,NValue,DValue,IValue,Description,ClientID)
select 2,'',1,0,'',ClientID from Clients

alter table Log_Operate add AgentID nvarchar(64)
alter table Log_Operate add ClientID nvarchar(64)

--
alter table Agents add IsIntFactory int default 0
Go 
Update Agents set IsIntFactory=0
Go

--处理批次信息
Update ShoppingCart set BatchCode=''
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

--增加单位名称
alter table ShoppingCart add UnitName nvarchar(50) default ''
GO
update s set UnitName=u.UnitName from ShoppingCart s join ProductUnit u on s.UnitID=u.UnitID

alter table OrderDetail add UnitName nvarchar(50) default ''
GO
update s set UnitName=u.UnitName from OrderDetail s join ProductUnit u on s.UnitID=u.UnitID

alter table OpportunityProduct add UnitName nvarchar(50) default ''
GO
update s set UnitName=u.UnitName from OpportunityProduct s join ProductUnit u on s.UnitID=u.UnitID

alter table StorageDetail add UnitName nvarchar(50) default ''
GO
update s set UnitName=u.UnitName from StorageDetail s join ProductUnit u on s.UnitID=u.UnitID


alter table AgentsOrderDetail add UnitName nvarchar(50) default ''
GO
update s set UnitName=u.UnitName from AgentsOrderDetail s join ProductUnit u on s.UnitID=u.UnitID






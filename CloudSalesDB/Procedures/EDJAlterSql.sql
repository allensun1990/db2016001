
--关联智能工厂
alter table Clients add RegisterType int
Go
Update c set RegisterType=a.RegisterType  from Clients c join Agents a on c.AgentID=a.AgentID
GO
alter table Agents add CMClientID nvarchar(64)
GO
alter table Agents drop constraint DF__Agents__IsIntFac__1C3DEE80
GO
alter table Agents drop column IsIntFactory

--微信账号类型改为5
Update UserAccounts set AccountType=5 where AccountType=4

--供应商类型
alter table Providers add ProviderType int default 0
GO
Update Providers set ProviderType=0

--增加订单来源
alter table Orders add SourceType int default 1
GO
Update Orders set SourceType=1

--客户增加下级客户ID
alter table Customer add ChildClientID nvarchar(64) 

-- 处理产品规格信息 重复执行
update p set AttrValue=REPLACE(AttrValue,ValueID,ValueName) from ProductDetail p 
join AttrValue a on p.AttrValue like '%'+a.ValueID+'%' and p.ClientID=a.ClientID

update p set SaleAttrValue=REPLACE(SaleAttrValue,ValueID,ValueName) from ProductDetail p 
join AttrValue a on p.SaleAttrValue like '%'+a.ValueID+'%' and p.ClientID=a.ClientID


--单据表
 alter table storageDoc add SourceType int default(1)
 go
 update storageDoc set SourceType=1

 alter table StoragePartDetail add Complete int default(0)
 go
 alter table StoragePartDetail add CompleteMoney decimal(18,4) default(0)
 go
 update StoragePartDetail set Complete=Quantity,CompleteMoney=TotalMoney
  


--关联智能工厂
alter table Clients add RegisterType int
alter table Clients add CMClientID nvarchar(64)
alter table Clients add IsMall int default 0
Go
Update c set RegisterType=a.RegisterType  from Clients c join Agents a on c.AgentID=a.AgentID
GO
alter table Agents add CMClientID nvarchar(64)
alter table Agents add IsMall int default 0
GO
Update Agents set IsMall=0
Update Agents set IsMall=1 where CMClientID is not null and CMClientID<>''
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
alter table Orders add OriginalID nvarchar(64)
alter table Orders add OriginalCode nvarchar(64)
GO
Update Orders set SourceType=1

--客户增加下级客户ID
alter table Customer add ChildClientID nvarchar(64) 

--处理客户来源
insert into CustomSource(SourceID,SourceCode,SourceName,IsSystem,IsChoose,Status,CreateUserID,ClientID)
					select NEWID(),'Source-Self','自助注册',1,0,1,CreateUserID,ClientID from Clients

--处理分类
alter table Category add SaleAttrStr nvarchar(4000)
alter table Category add AttrListStr nvarchar(4000)
GO
Update Category set SaleAttrStr=SaleAttr,AttrListStr=AttrList

--重复执行
update p set SaleAttrStr=REPLACE(SaleAttrStr,AttrID,AttrName) from Category p 
join ProductAttr a on SaleAttrStr like '%'+a.AttrID+'%' and p.ClientID=a.ClientID

update p set AttrListStr=REPLACE(AttrListStr,AttrID,AttrName) from Category p 
join ProductAttr a on AttrListStr like '%'+a.AttrID+'%' and p.ClientID=a.ClientID

--处理分类规格排序
alter table  CategoryAttr add Sort int default 1
GO
Update CategoryAttr set Sort=1

--产品冗余单位
alter table Products add UnitName nvarchar(20) 
alter table Products add SaleAttrStr nvarchar(4000)
alter table Products add AttrValueStr nvarchar(4000)
GO
update p set UnitName=u.UnitName from Products p join ProductUnit u on p.UnitID=u.UnitID
GO
Update Products set SaleAttrStr=SaleAttr,AttrValueStr=AttrValueList

--产品属性和规格重复执行
update p set SaleAttrStr=REPLACE(SaleAttrStr,AttrID,AttrName) from Products p 
join ProductAttr a on p.SaleAttrStr like '%'+a.AttrID+'%' and p.ClientID=a.ClientID

update p set AttrValueStr=REPLACE(AttrValueStr,AttrID,AttrName) from Products p 
join ProductAttr a on p.AttrValueStr like '%'+a.AttrID+'%' and p.ClientID=a.ClientID

update p set AttrValueStr=REPLACE(AttrValueStr,ValueID,ValueName) from Products p 
join AttrValue a on p.AttrValueStr like '%'+a.ValueID+'%' and p.ClientID=a.ClientID


-- 处理产品规格信息 重复执行
update p set SaleAttr=REPLACE(SaleAttr,AttrID,AttrName) from ProductDetail p 
join ProductAttr a on p.SaleAttr like '%'+a.AttrID+'%' and p.ClientID=a.ClientID

update p set AttrValue=REPLACE(AttrValue,ValueID,ValueName) from ProductDetail p 
join AttrValue a on p.AttrValue like '%'+a.ValueID+'%' and p.ClientID=a.ClientID

update p set SaleAttrValue=REPLACE(SaleAttrValue,AttrID,AttrName) from ProductDetail p 
join ProductAttr a on p.SaleAttrValue like '%'+a.AttrID+'%' and p.ClientID=a.ClientID

update p set SaleAttrValue=REPLACE(SaleAttrValue,ValueID,ValueName) from ProductDetail p 
join AttrValue a on p.SaleAttrValue like '%'+a.ValueID+'%' and p.ClientID=a.ClientID

--处理产品来源
alter table Products add SourceType int default 0
GO
Update Products set SourceType=0
Update Products set SourceType=1 where ProviderID in (select ProviderID from Providers where ProviderType=1)
Update Products set SourceType=2 where ProviderID in (select ProviderID from Providers where ProviderType=2)

--单据表
 alter table storageDoc add SourceType int default(0)
 go
 Update StorageDoc set SourceType=0

 alter table StoragePartDetail add Complete int default(0)
 go
 alter table StoragePartDetail add CompleteMoney decimal(18,4) default(0)
 go
 update StoragePartDetail set Complete=Quantity,CompleteMoney=TotalMoney
  
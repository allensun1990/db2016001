﻿
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

--单据表
 alter table storageDoc add SourceType int default(1)
 go
 update storageDoc set SourceType=1

 alter table StoragePartDetail add Complete int default(0)
 go
 alter table StoragePartDetail add CompleteMoney decimal(18,4) default(0)
 go
 update StoragePartDetail set Complete=Quantity,CompleteMoney=TotalMoney
  
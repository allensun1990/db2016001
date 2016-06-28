

use IntFactory

alter table PlateMaking add OriginalID varchar(64) null
alter table PlateMaking add OriginalPlateID varchar(64) null


insert into PlateMaking(PlateID,OrderID,Title,Remark,Icon,Status,AgentID,CreateTime,CreateUserID,Type,OriginalID,OriginalPlateID)
select NEWID() as PlateID,o.OrderID,p.Title,p.Remark,p.Icon,p.Status,p.AgentID,p.CreateTime,p.CreateUserID,p.Type,p.OrderID,p.PlateID from PlateMaking as p left join orders as o on p.OrderID=o.OriginalID
where o.Status<>9 and p.Status<>9



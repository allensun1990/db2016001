
alter table Customer add ContactName nvarchar(100) default ''

Update Customer set ContactName=c.name from Contact c where Customer.CustomerID=c.CustomerID and c.Type=1

--处理公司行业
select c.AgentID,c.ClientID,c.IndustryID,i.Name,NEWID() NEWIID into #tempIndustry from Customer c join Industry i on c.IndustryID=i.IndustryID 
group by c.ClientID,c.IndustryID,i.Name,c.AgentID
GO
insert into ClientsIndustry(ClientIndustryID,Name,Description,Status,CreateTime,CreateUserID,AgentID,ClientID)
select NEWIID,Name,'',1,GETDATE(),'',AgentID,ClientID from #tempIndustry
GO
update c set IndustryID=t.NEWIID from Customer c join  #tempIndustry t on c.ClientID=t.ClientID and c.IndustryID=t.IndustryID
GO
insert into ClientsIndustry(ClientIndustryID,Name,Description,Status,CreateTime,CreateUserID,AgentID,ClientID)
select NEWID(),i.Name,'',1,GETDATE(),i.CreateUserID,a.AgentID,a.ClientID 
from Agents a 
join Industry i on i.AutoID in(4,5,6,11,12,17,18,19,20,22)  
where not exists(select AutoID from ClientsIndustry where ClientID=a.ClientID and Name=i.Name)
GO
update c set CreateUserID=u.UserID from ClientsIndustry c join Users u on c.ClientID=u.ClientID and u.IsDefault=1 and u.Status<>9
GO
update Customer set IndustryID=''
where IndustryID not in (select ClientIndustryID from ClientsIndustry)

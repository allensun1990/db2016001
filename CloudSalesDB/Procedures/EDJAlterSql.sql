
--ActivityReply ActivityID 改为 GUID  Msg 改为Content

alter table Customer add ContactName nvarchar(100) default ''

Update Customer set ContactName=c.name from Contact c where Customer.CustomerID=c.CustomerID and c.Type=1

--已采购金额数据处理
update s set RealMoney=p.TotalMoney from StorageDoc s
join (select OriginalID,SUM(TotalMoney) TotalMoney from StorageDocPart group by OriginalID) p on s.DocID=p.OriginalID

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




--二当家和智能工厂打通
alter table Providers add CMClientID nvarchar(64)
alter table Providers add CMClientCode nvarchar(50)

create table ClientCustomer
(
AutoID int identity(1,1) primary key,
AgentID nvarchar(64),
ClientID nvarchar(64),
CMCustomerID nvarchar(64),
Status int default 1,
CMClientID nvarchar(64),
CMClientCode nvarchar(50)
)

alter table Products add CMGoodsID nvarchar(64)
alter table Products add CMGoodsCode nvarchar(100)
alter table Products add AliGoodsCode nvarchar(100)
GO
alter table Clients add ClientCode nvarchar(50)
GO
--处理客户端编码
declare @ID int=1,@CID int=1,@MaxID int,@ClientID nvarchar(64),@Code nvarchar(10)
select @MaxID=MAX(AutoID) from Clients
while(@ID<=@MaxID) 
begin
	if exists(Select AutoID from Clients where AutoID=@ID)
	begin
		select @ClientID=ClientID from Clients where AutoID=@ID
		set @CID=1
		set @Code=''
		while(@CID<9)
		begin
			if ceiling(rand()*3)=1 
			begin
			--随机字母（大写）
				select @Code=@Code+char(65+ceiling(rand()*25))
			end
			else
				begin
				--随机数字 1至9的随机数字(整数)
				select @Code=@Code+cast(ceiling(rand()*9) as varchar(1))
			end
			 
			set @CID=@CID+1
		end
		if not exists(select AutoID from Clients where ClientCode=@Code)
		begin
			Update Clients set ClientCode=@Code where ClientID=@ClientID
			set @ID=@ID+1
		end
	end
	else
	begin
		set @ID=@ID+1
	end
end

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














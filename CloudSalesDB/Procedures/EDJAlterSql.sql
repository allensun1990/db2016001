
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














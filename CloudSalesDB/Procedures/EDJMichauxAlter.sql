create table ClientMemberLevel(
[AutoID] [int] IDENTITY(1,1) NOT NULL,
[LevelID] [nvarchar](50) NOT NULL,
[Name] [nvarchar](50) NULL,
[IntegFeeMore] decimal(18,2) default(0.00),
[DiscountFee] decimal(18,2) default(1.00),
[Status] [int] default(1),
[CreateUserID] [nvarchar](64) NULL,
[CreateTime] [datetime] NULL,
[AgentID] [nvarchar](64) NULL,
[ClientID] [nvarchar](64) Not NULL,
[Origin] int,
[ImgUrl] [nvarchar](248) Not NULL,
)
go

create table IntegerFeeChange
(
AutoID int identity(1,1),
ChangeType  int not null,
ChangeFee decimal(18,4),
OldChangeFee decimal(18,4),
CreateTime datetime default(getdate()),
CreateUserID varchar(50),
CustomerID varchar(50) not null,
AgentID varchar(50) not null,
ClientID varchar(50) not null,
Reamrk varchar(500) 
)
go

alter table Customer Add IntegerFee decimal(18,4) default(0.00)
go
alter table Customer Add TotalIntegerFee decimal(18,4) default(0.00)
go
alter table Customer add MemberLevelID varchar(50) 
go
alter table  M_Report_AgentAction_Day add UserNum int default 1
go
alter table  M_Report_AgentAction_Day add Vitality decimal(18,4) default 0.0000
 go
update Customer set IntegerFee=0.00,TotalIntegerFee=0.000 
go

/*配置已存在的客户的客户等级*/

create table #memberLevel (Name varchar(50),integFeeMore decimal(18,2),DiscountFee decimal(18,2) ,origin int )
insert into #memberLevel values('普通会员',0,1.00,1)
insert into #memberLevel values('青铜会员',1000,0.98,2)
insert into #memberLevel values('白银会员',5000,0.96,3)
insert into #memberLevel values('黄金会员',9000,0.92,4)
 
 insert into clientMemberLevel 
 select newid(),b.Name,b.integFeeMore,b.DiscountFee,1,'',GETDATE(),a.AgentID,a.ClientID,b.origin,'' from  Clients a join #memberLevel b on 1=1 where status<>9
 
 drop table #memberLevel

 /*刷新人数和活跃度*/
  update M_Report_AgentAction_Day set UserNum=UserCount,Vitality=
cast( 
	round(
		(CustomerCount+OrdersCOunt+ ActivityCount+ProductCount+UsersCount+AgentCount+OpportunityCount+PurchaseCount+WarehousingCount+ProductCount)
		/ cast(UserNum as decimal(18,4)
	 ),4) as  decimal(18,4)
 )  
 from 
 (
	select isnull(Count(ClientID),0) as UserCount ,Users.ClientID from Users where Status=1  group by Users.ClientID
) a 
join  M_Report_AgentAction_Day   on a.ClientID=M_Report_AgentAction_Day.ClientID
  
  /*新增存储过程*/
P_InsertClientMemberLevel
P_UpdateClientMemberLevel
P_DeleteClientMemberLevel

P_RefreshMemberLevelID
P_InsertIntergeFeeChange
P_IntergeFeeChangePageList
P_UpdateCustomerIntergeFee

P_GetProductListForExport
M_Get_Report_AgentActionDayPageList
R_GetClientsGrowDate
R_GetClientsAgentLogin_Day
R_GetOrderDetailReeport 
R_StockInOutReport
P_BindOtherAccount
P_GetUserByOtherAccount


/*修改*/
R_GetClientsActiveReprot
M_Get_Report_AgentActionDayReport
P_GetCustomers
P_InsertProductDetail
M_InsertClient
E_ImportCustomer
P_CreateCustomer
M_DeleteRole
Rpt_AgentAction_Day
M_GetClientOrders 
P_GetUserToLogin


  ---下次版本更新-修改
  P_ConfirmAgentOrderSend
  P_AuditReturnIn
  P_ConfirmAgentOrderOut

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


alter table Customer Add IntegerFee decimal(18,2) default(0.00)

alter table Customer add MemberLevelID varchar(50) 

update Customer set IntegerFee=0.00


/*新增存储过程*/
P_InsertClientMemberLevel
P_UpdateClientMemberLevel
P_DeleteClientMemberLevel
P_RefreshMemberLevelID
P_GetProductListForExport
M_Get_Report_AgentActionDayPageList
/*修改*/

P_GetCustomers
P_InsertProductDetail
M_InsertClient
E_ImportCustomer
P_CreateCustomer
M_DeleteRole

/*配置已存在的客户的客户等级*/

create table #memberLevel (Name varchar(50),integFeeMore decimal(18,2),DiscountFee decimal(18,2) ,origin int )
insert into #memberLevel values('普通会员',0,1.00,1)
insert into #memberLevel values('青铜会员',1000,0.98,2)
insert into #memberLevel values('白银会员',5000,0.96,3)
insert into #memberLevel values('黄金会员',9000,0.92,4)
 
 insert into clientMemberLevel 
 select newid(),b.Name,b.integFeeMore,b.DiscountFee,1,'',GETDATE(),a.AgentID,a.ClientID,b.origin,'' from  Clients a join #memberLevel b on 1=1 where status<>9
 
 drop table #memberLevel

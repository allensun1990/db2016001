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


/*�����洢����*/
P_InsertClientMemberLevel
P_UpdateClientMemberLevel
P_DeleteClientMemberLevel
P_RefreshMemberLevelID
P_GetProductListForExport
M_Get_Report_AgentActionDayPageList
/*�޸�*/

P_GetCustomers
P_InsertProductDetail
M_InsertClient
E_ImportCustomer
P_CreateCustomer
M_DeleteRole

/*�����Ѵ��ڵĿͻ��Ŀͻ��ȼ�*/

create table #memberLevel (Name varchar(50),integFeeMore decimal(18,2),DiscountFee decimal(18,2) ,origin int )
insert into #memberLevel values('��ͨ��Ա',0,1.00,1)
insert into #memberLevel values('��ͭ��Ա',1000,0.98,2)
insert into #memberLevel values('������Ա',5000,0.96,3)
insert into #memberLevel values('�ƽ��Ա',9000,0.92,4)
 
 insert into clientMemberLevel 
 select newid(),b.Name,b.integFeeMore,b.DiscountFee,1,'',GETDATE(),a.AgentID,a.ClientID,b.origin,'' from  Clients a join #memberLevel b on 1=1 where status<>9
 
 drop table #memberLevel

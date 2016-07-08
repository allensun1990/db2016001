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

Alter table clients  add ChangeRate decimal(18,2) default(1.00)

alter table Customer add MemberLevelID varchar(50) 

update clients set ChangeRate=1.00


/*新增存储过程*/
P_InsertClientMemberLevel
P_UpdateClientMemberLevel
P_DeleteClientMemberLevel

/*修改*/
P_GetCustomers
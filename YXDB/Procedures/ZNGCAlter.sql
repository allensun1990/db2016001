

P_GetOrderByID
P_AddOrderMembers
P_AddCustomerMembers
P_GetCustomerByID

create table OrderMember
(
AutoID int identity(1,1) primary key,
OrderID nvarchar(64),
MemberID nvarchar(64),
Status int default 1,
CreateUserID nvarchar(64),
CreateTime datetime default getdate(),
ClientID nvarchar(64)
)

create table CustomerMember
(
AutoID int identity(1,1) primary key,
CustomerID nvarchar(64),
MemberID nvarchar(64),
Status int default 1,
CreateUserID nvarchar(64),
CreateTime datetime default getdate(),
ClientID nvarchar(64)
)




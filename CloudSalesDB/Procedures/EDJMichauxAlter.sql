﻿/*
M_PayOrderAndAuthorizeClient
M_UpdateClientOrderAccountStatus
M_AddClientOrderAccount
M_GetClientOrders 
M_AddClientOrder 
M_UpdateRolePermission
P_UpdateUserRole
M_DeleteRole
M_GetM_UserToLogin
*/
alter table FeedBack add Content varchar(1000)
alter table ClientOrder Add CheckUserID varchar(50)
alter table ClientOrder Add CheckTime DateTime
alter table ClientOrder Add PayFee decimal(18,4) default(0.0000)
Alter table ClientOrder add PayStatus int default(0)
alter table ClientOrder Add SourceType int default(0)
alter table ClientOrder add ReFundFee decimal(18,4) default(0.0000)
alter table M_Users add RoleID nvarchar(64)

update ClientOrder set 
PayFee=case Status when 1 then RealAmount else 0.0000 end , 
payStatus= case Status when 1 then 1 else 0 end,
CheckUserID=case Status when 1 then CreateUserID else Null end,
CheckTime=case Status when 1 then CreateTime else Null end,
SourceType=0,
ReFundFee=0.0000

/**ClientOrderAccount（订单账单表）*/
Create table ClientOrderAccount
(
[AutoID] int IDENTITY(1,1) NOT NULL,
[OrderID] [nvarchar](64) NOT NULL,
[PayType] [int] NOT NULL,
[Type] [int] NOT NULL,
[RealAmount] [decimal](18, 4) NOT NULL,
[Status] [int] NOT NULL,
[ClientID] [nvarchar](64) NOT NULL,
[CreateTime] [datetime] NOT NULL,
[CreateUserID] [nvarchar](64) NOT NULL,
[CheckTime] [datetime] NULL,
[CheckUserID] [nvarchar](64) NULL,
[AlipayNo]   [nvarchar](64) NULL,
[Remark]   [nvarchar](500) NULL
)
go
ALTER TABLE [dbo].[ClientOrderAccount] ADD  CONSTRAINT [DF_ClientOrderAccount_CreateTime]  DEFAULT (getdate()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ClientOrderAccount] ADD  CONSTRAINT [DF_ClientOrderAccount_Status]  DEFAULT (0) FOR [Status]
GO


 
 /**后台角色*/

CREATE TABLE [dbo].[M_Role](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[RoleID] [nvarchar](64) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[ParentID] [nvarchar](64) NULL,
	[Status] [int] NULL,
	[Description] [nvarchar](4000) NULL,
	[IsDefault] [bit] NOT NULL,
	[CreateTime] [datetime] NULL,
	[CreateUserID] [nvarchar](64) NULL,
 CONSTRAINT [PK__M_Role__8AFACE3A6D0D32F4] PRIMARY KEY CLUSTERED 
(
	[RoleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[M_Role] ADD  CONSTRAINT [DF__M_Role__Status__6EF57B66]  DEFAULT ((0)) FOR [Status]
GO

ALTER TABLE [dbo].[M_Role] ADD  CONSTRAINT [DF__M_Role__Descript__6FE99F9F]  DEFAULT ('') FOR [Description]
GO

ALTER TABLE [dbo].[M_Role] ADD  CONSTRAINT [DF_M_Role_IsDefault]  DEFAULT ((0)) FOR [IsDefault]
GO

ALTER TABLE [dbo].[M_Role] ADD  CONSTRAINT [DF__M_Role__CreateTi__70DDC3D8]  DEFAULT (getdate()) FOR [CreateTime]
GO


 /**后台权限*/
CREATE TABLE [dbo].[M_RolePermission](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[RoleID] [nvarchar](64) NULL,
	[MenuCode] [nvarchar](20) NULL,
	[CreateTime] [datetime] NULL,
	[CreateUserID] [nvarchar](64) NULL,
 CONSTRAINT [PK__M_RolePe__6B2329651ED998B2] PRIMARY KEY CLUSTERED 
(
	[AutoID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[M_RolePermission] ADD  CONSTRAINT [DF__M_RolePer__Creat__1B9317B3]  DEFAULT (getdate()) FOR [CreateTime]
GO
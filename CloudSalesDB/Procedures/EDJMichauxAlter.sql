/*
M_UpdateClientOrderAccountStatus
M_AddClientOrderAccount
M_GetClientOrders
*/
alter table FeedBack add Content varchar(1000)

alter table ClientOrder Add CheckUserID varchar(50)
alter table ClientOrder Add CheckTime DateTime
alter table ClientOrder Add PayFee decimal(18,4) default(0.0000)
Alter table ClientOrder add PayStatus int default(0)
alter table ClientOrder Add SourceType int default(0)
alter table ClientOrder add ReFundFee decimal(18,4) default(0.0000)



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



insert into Menu
select '108020900','标签设置',Area,Controller,'LabelSet',IcoPath,IcoHover,Type,IsHide,PCode,8,Layer,IsMenu,IsLimit,Remark from Menu
where AutoID=183

alter table orders add YXOrderID nvarchar(64) null

USE [IntFactory]
GO

/****** Object:  Table [dbo].[OrderPriceRange]    Script Date: 07/13/2016 15:50:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[OrderPriceRange](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[RangeID] [nvarchar](64) NOT NULL,
	[OrderID] [nvarchar](64) NULL,
	[MinQuantity] [int] NOT NULL,
	[Price] [decimal](18, 3) NOT NULL,
	[Status] [int] NOT NULL,
	[ClientID] [nvarchar](64) NOT NULL,
	[AgentID] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL,
	[CreateUserID] [nvarchar](64) NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[OrderPriceRange] ADD  CONSTRAINT [DF_OrderPriceRange_MinQuantity]  DEFAULT ((1)) FOR [MinQuantity]
GO

ALTER TABLE [dbo].[OrderPriceRange] ADD  CONSTRAINT [DF_OrderPriceRange_Status]  DEFAULT ((1)) FOR [Status]
GO

ALTER TABLE [dbo].[OrderPriceRange] ADD  CONSTRAINT [DF_OrderPriceRange_CreateTime]  DEFAULT (getdate()) FOR [CreateTime]
GO

alter table users add WeiXinID nvarchar(200) null











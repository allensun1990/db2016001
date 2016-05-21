USE [IntFactory_dev]
GO

/****** Object:  Table [dbo].[TaskMember]    Script Date: 05/18/2016 13:36:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TaskMember](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[MemberID] [nvarchar](64) NOT NULL,
	[TaskID] [nvarchar](64) NOT NULL,
	[Status] [int] NOT NULL,
	[PermissionType] [int] NOT NULL,
	[AgentID] [nvarchar](64) NOT NULL,
	[CreateUserID] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL
	)
GO


insert into TaskMember(MemberID,TaskID,Status,PermissionType,AgentID,CreateUserID,CreateTime)
select u.UserID,TaskID,1,1,o.AgentID,o.OwnerID,GETDATE() from OrderTask o join Users u on o.Members like '%'+u.UserID+'%'
where Members<>''

CREATE TABLE [dbo].[PlateMaking](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[PlateID] [nvarchar](64) NOT NULL,
	[OrderID] [nvarchar](64) NOT NULL,
	[TaskID] [nvarchar](64) NOT NULL,
	[Title] [nvarchar](200) NOT NULL,
	[Remark] [nvarchar](200) NULL,
	[Icon] [nvarchar](200) NULL,
	[Status] [int] NOT NULL,
	[CreateTime] [datetime] NULL,
	[AgentID] [nvarchar](64) NULL,
	[CreateUserID] [nvarchar](64) NULL,
 CONSTRAINT [PK_PlateMaking] PRIMARY KEY CLUSTERED 
(
	[PlateID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[PlateMaking] ADD  CONSTRAINT [DF_PlateMaking_Status]  DEFAULT ((1)) FOR [Status]
GO

alter table OrderGoods add TaskID varchar(64)  null








alter table PlateMaking alter  column Remark varchar(500)

insert into Menu
values('206000000','帮助中心','','HelpCenter','Contents',
'','',2,0,
'100000000',6,1,1,1,'')

insert into Menu
values('206010000','分类管理','','HelpCenter','Types',
'','',2,0,
'206000000',1,2,1,1,'')

insert into Menu
values('206010100','添加分类','','HelpCenter','AddType',
'','',2,0,
'206010000',1,3,1,1,'')

insert into Menu
values('206010200','分类列表','','HelpCenter','Types',
'','',2,0,
'206010000',2,3,1,1,'')


insert into Menu
values('206020000','内容管理','','HelpCenter','Contents',
'','',2,0,
'206000000',2,2,1,1,'')

insert into Menu
values('206020100','添加内容','','HelpCenter','AddContent',
'','',2,0,
'206020000',1,3,1,1,'')

insert into Menu
values('206020200','内容列表','','HelpCenter','Contents',
'','',2,0,
'206020000',2,3,1,1,'')

CREATE TABLE [dbo].[M_HelpType](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[TypeID] [nvarchar](64) NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Icon] [nvarchar](200) NULL,
	[Remark] [nvarchar](400) NULL,
	[Sort] [int] NULL,
	[Status] [int] NOT NULL,
	[ModuleType] [int] NOT NULL,
	[CreateUserID] [nvarchar](64) NULL,
	[CreateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_M_HelpType] PRIMARY KEY CLUSTERED 
(
	[TypeID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[M_HelpType] ADD  CONSTRAINT [DF_M_HelpType_Sort]  DEFAULT ((0)) FOR [Sort]
GO

ALTER TABLE [dbo].[M_HelpType] ADD  CONSTRAINT [DF_M_HelpType_Status]  DEFAULT ((1)) FOR [Status]
GO

ALTER TABLE [dbo].[M_HelpType] ADD  CONSTRAINT [DF_M_HelpType_ModuleType]  DEFAULT ((1)) FOR [ModuleType]
GO

ALTER TABLE [dbo].[M_HelpType] ADD  CONSTRAINT [DF_M_HelpType_CreateTime]  DEFAULT (getdate()) FOR [CreateTime]
GO

CREATE TABLE [dbo].[M_HelpContent](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[ContentID] [nvarchar](64) NOT NULL,
	[TypeID] [nvarchar](64) NOT NULL,
	[Title] [nvarchar](200) NOT NULL,
	[MainImg] [nvarchar](200) NULL,
	[Detail] [text] NOT NULL,
	[KeyWords] [nvarchar](200) NULL,
	[Sort] [int] NULL,
	[Status] [int] NULL,
	[ClickNumber] [int] NOT NULL,
	[CreateUserID] [nvarchar](64) NULL,
	[CreateTime] [datetime] NULL,
	[UpdateTime] [datetime] NULL,
 CONSTRAINT [PK_M_HelpContent] PRIMARY KEY CLUSTERED 
(
	[ContentID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[M_HelpContent] ADD  CONSTRAINT [DF_M_HelpContent_Sort]  DEFAULT ((0)) FOR [Sort]
GO

ALTER TABLE [dbo].[M_HelpContent] ADD  CONSTRAINT [DF_M_HelpContent_Status]  DEFAULT ((1)) FOR [Status]
GO

ALTER TABLE [dbo].[M_HelpContent] ADD  CONSTRAINT [DF_M_HelpContent_ClickNumber]  DEFAULT ((0)) FOR [ClickNumber]
GO

ALTER TABLE [dbo].[M_HelpContent] ADD  CONSTRAINT [DF_M_HelpContent_CreateTime]  DEFAULT (getdate()) FOR [CreateTime]
GO

ALTER TABLE [dbo].[M_HelpContent] ADD  CONSTRAINT [DF_M_HelpContent_UpdateTime]  DEFAULT (getdate()) FOR [UpdateTime]
GO


alter table orders add IsPublic int default(0)








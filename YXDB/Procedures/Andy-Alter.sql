
--新增任务成员表
CREATE TABLE [dbo].[TaskMember](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[MemberID] [nvarchar](64) NOT NULL,
	[TaskID] [nvarchar](64) NOT NULL,
	[Status] [int] NOT NULL,
	[PermissionType] [int] NOT NULL,
	[AgentID] [nvarchar](64) NOT NULL,
	[CreateUserID] [nvarchar](64) NOT NULL,
	[CreateTime] [datetime] NOT NULL
) ON [PRIMARY]

GO

--将任务表中的成员导入到任务成员表中
insert into TaskMember(MemberID,TaskID,Status,PermissionType,AgentID,CreateUserID,CreateTime)
select u.UserID,TaskID,1,1,o.AgentID,o.OwnerID,GETDATE() from OrderTask o join Users u on o.Members like '%'+u.UserID+'%'
where Members<>''

--创建制版工艺说明表
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

--大货明细表新增字段：TaskID
alter table GoodsDoc add TaskID varchar(64)  null

--任务操作权限不放在角色权限中控制
update Menu set IsLimit=0,IsHide=1
where MenuCode in
(
'109010101','109010102','109010103','109010104','109010105','109010106','109010107'
)







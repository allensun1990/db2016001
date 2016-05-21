

--流程阶段
alter table orderprocess add CategoryType int default 1
update orderprocess set CategoryType=1

update OrderStage set Mark=11 where Mark=1
update OrderStage set Mark=12 where Mark=2
update OrderStage set Mark=21 where Mark=3

update OrderTask set Mark=11 where Mark=1
update OrderTask set Mark=12 where Mark=2
update OrderTask set Mark=21 where Mark=3

--材料耗损率
alter table OrderDetail add LossRate decimal(18,4) default 0
update OrderDetail set LossRate=Loss/Quantity

--引导步骤
alter table Clients add GuideStep int default 1
update Clients set GuideStep=0

--货位放开
update Menu set IsHide=0 where MenuCode='108020600'
update Menu set IsHide=1 where PCode='108020600'

alter table DepotSeat add Sort int default 1
GO
update DepotSeat set Sort=1

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

alter table GoodsDoc add TaskID varchar(64)  null





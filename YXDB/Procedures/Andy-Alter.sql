

use IntFactory

alter table PlateMaking add OriginalID varchar(64) null
alter table PlateMaking add OriginalPlateID varchar(64) null


insert into PlateMaking(PlateID,OrderID,Title,Remark,Icon,Status,AgentID,CreateTime,CreateUserID,Type,OriginalID,OriginalPlateID)
select NEWID() as PlateID,o.OrderID,p.Title,p.Remark,p.Icon,p.Status,p.AgentID,p.CreateTime,p.CreateUserID,p.Type,p.OrderID,p.PlateID from PlateMaking as p left join orders as o on p.OrderID=o.OriginalID
where o.Status<>9 and p.Status<>9


USE [IntFactory]
GO

/****** Object:  Table [dbo].[CustomerColor]    Script Date: 06/29/2016 13:25:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CustomerColor](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[ColorID] [int] NOT NULL,
	[ColorName] [nvarchar](50) NULL,
	[ColorValue] [nvarchar](20) NULL,
	[Status] [int] NULL,
	[CreateUserID] [nvarchar](64) NULL,
	[CreateTime] [datetime] NULL,
	[UpdateTime] [datetime] NULL,
	[UpdateUserID] [nvarchar](64) NULL,
	[AgentID] [nvarchar](64) NULL,
	[ClientID] [nvarchar](64) NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[CustomerColor] ADD  DEFAULT ((0)) FOR [Status]
GO

create table #color(ColorValue varchar(50) ,ColorName varchar(50),ColorID int)
insert  into #color values('#ff7c7c','标签1',1) 
insert  into #color values('#3bb3ff','标签2',2)
insert  into #color values('#9f74ff','标签3',3)  
insert  into #color values('#ffc85d','标签4',4) 
insert  into #color values('#fff65f','标签5',5) 

insert into CustomerColor select b.ColorID,b.ColorName, b.ColorValue,0,'',GETDATE(),null,null,a.AgentID,a.ClientID from Clients a join #color b  on  1=1

drop table #color






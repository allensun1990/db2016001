

use IntFactory


insert into Menu
values('102019035','打样报价','','Orders','FentOrderReport','','',1,0,'102010500',1035,4,0,1,'')


CREATE TABLE [dbo].[TaskReplyAttachmentRelation](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[TaskID] [nvarchar](64) NOT NULL,
	[ReplyID] [nvarchar](64) NULL,
	[AttachmentID] [nvarchar](64) NOT NULL,
	[Status] [int] NOT NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[TaskReplyAttachmentRelation] ADD  CONSTRAINT [DF_TaskReplyAttachmentRelation_Status]  DEFAULT ((1)) FOR [Status]
GO


CREATE TABLE [dbo].[CustomerReplyAttachmentRelation](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [nvarchar](64) NOT NULL,
	[ReplyID] [nvarchar](64) NOT NULL,
	[AttachmentID] [nvarchar](64) NOT NULL,
	[Status] [int] NOT NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[CustomerReplyAttachmentRelation] ADD  CONSTRAINT [DF_CustomerReplyAttachmentRelation_Status]  DEFAULT ((1)) FOR [Status]
GO

CREATE TABLE [dbo].[Attachment](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[AttachmentID] [nvarchar](64) NOT NULL,
	[Type] [int] NOT NULL,
	[ServerUrl] [nvarchar](200) NULL,
	[FilePath] [nvarchar](200) NOT NULL,
	[FileName] [nvarchar](200) NOT NULL,
	[OriginalName] [nvarchar](200) NOT NULL,
	[ThumbnailName] [nvarchar](200) NULL,
	[Size] [bigint] NOT NULL,
	[CreateUserID] [nvarchar](64) NULL,
	[CreateTime] [datetime] NOT NULL,
	[UpdateTime] [datetime] NULL,
	[ClientID] [nvarchar](64) NOT NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Attachment] ADD  CONSTRAINT [DF_TaskReplyAttachment_Type]  DEFAULT ((1)) FOR [Type]
GO

ALTER TABLE [dbo].[Attachment] ADD  CONSTRAINT [DF_Attachment_Size]  DEFAULT ((0)) FOR [Size]
GO

ALTER TABLE [dbo].[Attachment] ADD  CONSTRAINT [DF_TaskReplyAttachment_CreateTime]  DEFAULT (getdate()) FOR [CreateTime]
GO

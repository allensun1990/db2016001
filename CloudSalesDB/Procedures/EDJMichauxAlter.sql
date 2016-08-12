  
  CREATE TABLE [dbo].[Attachment](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[AttachmentID] [nvarchar](64) NOT NULL,
	[Type] [int] NOT NULL  DEFAULT (1),
	[ServerUrl] [nvarchar](200) NULL,
	[FilePath] [nvarchar](200) NOT NULL,
	[FileName] [nvarchar](200) NOT NULL,
	[OriginalName] [nvarchar](200) NOT NULL,
	[ThumbnailName] [nvarchar](200) NULL,
	[Size] [bigint] NOT NULL  DEFAULT (0),
	[CreateUserID] [nvarchar](64) NULL,
	[CreateTime] [datetime] NOT NULL DEFAULT (getdate()),
	[UpdateTime] [datetime] NULL,
	[ReplyID] [nvarchar](64) NOT NULL,
	[AgentID] [nvarchar](64) NOT NULL,
	[ClientID] [nvarchar](64) NOT NULL
)  

GO
  
  P_GetPagerData
  P_ConfirmAgentOrderSend
  P_AuditReturnIn
  P_ConfirmAgentOrderOut

  /*ÐÂÔö*/
  P_GetReplysByType
  P_AddReplyAttachment
 

 
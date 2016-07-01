<<<<<<< HEAD
﻿
=======
﻿R_GetCustomerStageRPT 
E_ImportCustomer
E_ImportContact

USE [CloudSales1.0_dev]
GO 
CREATE TABLE [dbo].[ClientsIndustry](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[ClientIndustryID] [varchar](50) NOT NULL,
	[Name] [varchar](50) NULL,
	[Description] [text] NULL,
	[Status] [int] NOT NULL,
	[CreateTime] [datetime] NULL,
	[CreateUserID] [varchar](50) NULL,
	[AgentID] [varchar](50) NULL,
	[ClientID] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ClientsIndustry] PRIMARY KEY CLUSTERED 
(
	[ClientIndustryID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING ON
GO

ALTER TABLE [dbo].[ClientsIndustry] ADD  CONSTRAINT [DF_ClientsIndustry_CreateTime]  DEFAULT (getdate()) FOR [CreateTime]
GO
ALTER TABLE [dbo].[ClientsIndustry] ADD  CONSTRAINT [DF_ClientsIndustry_Status]  DEFAULT (1) FOR [Status]
GO
>>>>>>> cca9775b4fe272106befaa1754082d51d0affecd

USE [IntFactory]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_DeleteClient')
BEGIN
	DROP  Procedure  M_DeleteClient
END
/****** Object:  StoredProcedure [dbo].[M_UpdateClient]    Script Date: 05/09/2016 14:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************
过程名称： M_DeleteClient
功能描述： 删除客户端	
程序作者： allen
编写日期： 2016/6/6
************************************************************/
Create PROCEDURE [dbo].[M_DeleteClient]
@ClientID nvarchar(64)
AS

if exists(select AutoID from Clients where Status=1 and EndTime < getdate())
begin
	Update Clients set Status=9 where ClientID=@ClientID

	delete from AliOrderDownloadPlan where ClientID=@ClientID
	
	Update Users set Status=9 where ClientID=@ClientID

	delete from UserAccounts where ClientID=@ClientID
end

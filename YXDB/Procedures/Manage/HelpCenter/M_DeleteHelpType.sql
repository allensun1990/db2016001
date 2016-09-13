USE [IntFactory]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_DeleteHelpType')
BEGIN
	DROP  Procedure  M_DeleteHelpType
END
/****** Object:  StoredProcedure [dbo].[M_UpdateClient]    Script Date: 05/09/2016 14:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************
过程名称： M_DeleteHelpType
功能描述： 删除帮助中心分类	
程序作者： allen
编写日期： 2016/6/6
************************************************************/

CREATE PROCEDURE [dbo].[M_DeleteHelpType]
	@TypeID nvarchar(64),
	@Result int output --0：失败，1：成功，2 分类下还有数据
AS
	if exists(select * from M_HelpContent where Status<>9 and TypeID=@TypeID)
	begin
		set @Result=2
		return
	end

	update M_HelpType set Status=9 where TypeID=@TypeID
		
GO


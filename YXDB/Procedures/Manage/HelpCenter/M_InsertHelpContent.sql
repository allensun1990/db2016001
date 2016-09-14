USE [IntFactory]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_InsertHelpContent')
BEGIN
	DROP  Procedure  M_InsertHelpContent
END
/****** Object:  StoredProcedure [dbo].[M_UpdateClient]    Script Date: 05/09/2016 14:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************
过程名称： M_InsertHelpContent
功能描述： 添加帮助中心内容	
程序作者： allen
编写日期： 2016/6/6
************************************************************/

CREATE PROCEDURE [dbo].[M_InsertHelpContent]
	@ContentID nvarchar(64),
	@TypeID nvarchar(64),
	@Sort nvarchar(64),
	@Title nvarchar(64),
	@MainImg nvarchar(200)='',
	@KeyWords nvarchar(64),
	@UserID nvarchar(64),
	@Detail text,
	@Result int output --0：失败，1：成功，2 分类名称已存在
AS
	if exists(select 1 from M_HelpContent where Status<>9 and Title=@Title)
	begin
		set @Result=2
		return
	end

	insert into M_HelpContent(ContentID,TypeID,Sort,Title,KeyWords,CreateUserID,Detail,MainImg) 
	values(@ContentID,@TypeID,@Sort,@Title,@KeyWords,@UserID,@Detail,@MainImg)	

	set @Result=1
GO


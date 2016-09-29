USE [IntFactory]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_UpdateHelpContent')
BEGIN
	DROP  Procedure  M_UpdateHelpContent
END
/****** Object:  StoredProcedure [dbo].[M_UpdateHelpContent]    Script Date: 05/09/2016 14:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************
过程名称： M_UpdateHelpContent
功能描述： 编辑帮助中心内容	
程序作者： allen
编写日期： 2016/6/6
************************************************************/

CREATE PROCEDURE [dbo].[M_UpdateHelpContent]
	@ContentID nvarchar(64),
	@TypeID nvarchar(64),
	@Sort nvarchar(64),
	@Title nvarchar(64),
	@MainImg nvarchar(200)='',
	@KeyWords nvarchar(64),
	@Detail text,
	@Result int output --1 成功
AS
	declare @oldSort int

	select @oldSort=Sort from M_HelpContent where ContentID=@ContentID
	
	if(@oldSort<@Sort)
	begin
		update M_HelpContent set Sort-=1 where TypeID=@TypeID and ContentID in(select ContentID from M_HelpContent where @oldSort<=Sort and Sort<=@Sort and TypeID=@TypeID) 
	end

	if(@oldSort>@Sort)
	begin
		update M_HelpContent set Sort+=1 where TypeID=@TypeID and ContentID in(select ContentID from M_HelpContent where @oldSort>=Sort and Sort>=@Sort and TypeID=@TypeID)
	end
	
	Update M_HelpContent set Title=@Title,Sort=@Sort,KeyWords=@KeyWords,MainImg=@MainImg,Detail=@Detail,TypeID=@TypeID,UpdateTime=getdate() where contentID=@ContentID

	set @Result=1
GO


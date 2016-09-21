USE [IntFactory]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_UpdateHelpType')
BEGIN
	DROP  Procedure  M_UpdateHelpType
END
/****** Object:  StoredProcedure [dbo].[M_UpdateHelpType]    Script Date: 05/09/2016 14:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************
过程名称： M_UpdateHelpType
功能描述： 编辑帮助中心分类	
程序作者： allen
编写日期： 2016/6/6
************************************************************/

CREATE PROCEDURE [dbo].[M_UpdateHelpType]
	@TypeID nvarchar(64),
	@Name nvarchar(64),
	@Remark nvarchar(400),
	@ModuleType int,
	@Img nvarchar(200)='',	
	@Sort int,
	@Result int output--1 成功
AS
	declare @oldSort int

	select @oldSort=Sort from M_HelpType where TypeID=@TypeID
	
	if(@oldSort<@Sort)
	begin
		update M_HelpType set Sort-=1 where ModuleType=@ModuleType and TypeID in(select TypeID from M_HelpType where @oldSort<=Sort and Sort<=@Sort and ModuleType=@ModuleType) 
	end

	if(@oldSort>@Sort)
	begin
		update M_HelpType set Sort+=1 where ModuleType=@ModuleType and TypeID in(select TypeID from M_HelpType where @oldSort>=Sort and Sort>=@Sort and ModuleType=@ModuleType)
	end

	Update M_HelpType set Name=@Name,Remark=@Remark,Icon=@Img,ModuleType=@ModuleType,Sort=@Sort where TypeID=@TypeID	



	set @Result=1
GO







USE [IntFactory]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_GetHelpContents')
BEGIN
	DROP  Procedure  M_GetHelpContents
END
/****** Object:  StoredProcedure [dbo].[M_UpdateClient]    Script Date: 05/09/2016 14:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************
过程名称： M_GetHelpContents
功能描述： 获取帮助中心内容列表	
程序作者： allen
编写日期： 2016/6/6
************************************************************/

CREATE PROCEDURE [dbo].[M_GetHelpContents]
	@pageSize int,
	@pageIndex int,	
	@ModuleType int,
	@typeID nvarchar(100),
	@keyWords nvarchar(100),
	@beginTime nvarchar(100),
	@endTime nvarchar(100),
	@orderBy nvarchar(100),
	@totalCount int output ,
	@pageCount int output
AS
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@key nvarchar(100),
	@condition nvarchar(4000),	
	@isAsc int
	
	select @tableName ='M_HelpContent as c left join M_Helptype as t on c.typeid=t.typeid',
	@columns='c.*,t.name as typename,t.moduletype ',
	@key='c.ContentID',
	@condition='c.Status<>9',
	@isAsc=0
	
	if(@typeID<>'')
	begin
		set @condition +=' and c.TypeID = '''+@typeID+''''
	end
	else
	begin
		if(@ModuleType<>'')
		begin
			set @condition +=' and c.TypeID in (select TypeID from M_HelpType where ModuleType='+
		str(@ModuleType,2)+' and Status<>9) '
		end
	end

	if(@BeginTime<>'')
	begin
		set @condition +=' and c.CreateTime >= '''+@BeginTime+' 0:00:00'''
	end

	if(@EndTime<>'')
	begin
		set @condition +=' and c.CreateTime <=  '''+@EndTime+' 23:59:59'''
	end

	if(@keyWords <> '')
	begin
		set @condition +=' and (c.KeyWords like ''%'+@keyWords+'%'' )'
	end

	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,@orderBy,@pageSize,@pageIndex,@total out,@page out,@isAsc 
	select @totalCount=@total,@pageCount =@page

GO


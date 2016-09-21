USE [IntFactory]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_GetHelpTypes')
BEGIN
	DROP  Procedure  M_GetHelpTypes
END
/****** Object:  StoredProcedure [dbo].[M_UpdateClient]    Script Date: 05/09/2016 14:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************
过程名称： M_GetHelpTypes
功能描述： 获取帮助中心分类列表	
程序作者： allen
编写日期： 2016/6/6
************************************************************/

CREATE PROCEDURE [dbo].[M_GetHelpTypes]
	@pageSize int,
	@pageIndex int,
	@types int=-1,
	@keyWords nvarchar(100),
	@beginTime nvarchar(100),
	@endTime nvarchar(100),
	@orderBy nvarchar(100),
	@totalCount int output ,
	@pageCount int output
AS
	declare @tableName nvarchar(4000),
	@key nvarchar(100),
	@columns nvarchar(4000),
	@condition nvarchar(4000),	
	@orderColumn nvarchar(4000),	
	@isAsc int

	select @tableName='M_HelpType as c',
	@key='TypeID',
	@columns='* ',
	@condition='Status<>9',	
	@orderColumn=',c.Sort asc',
	@isAsc=0

	if(@types<>-1)
	begin
		set @condition +=' and c.ModuleType = '+convert(nvarchar(2), @types)
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
		set @condition +=' and (c.Name like ''%'+@keyWords+'%'')'
	end

	if(@orderBy<>'')
	begin
		set @orderBy+=''+@orderColumn+''
	end

	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,@orderBy,@pageSize,@pageIndex,@total out,@page out,@isAsc 
	select @totalCount=@total,@pageCount =@page

GO
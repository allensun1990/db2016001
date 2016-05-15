﻿Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetWareHouses')
BEGIN
	DROP  Procedure  P_GetWareHouses
END

GO
/***********************************************************
过程名称： P_GetWareHouses
功能描述： 获取仓库列表
参数说明：	 
编写日期： 2015/7/21
程序作者： Allen
调试记录： exec P_GetWareHouses 
************************************************************/
CREATE PROCEDURE [dbo].[P_GetWareHouses]
	@keyWords nvarchar(4000),
	@pageSize int,
	@pageIndex int,
	@totalCount int output ,
	@pageCount int output,
	@ClientID nvarchar(64)
AS
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@key nvarchar(100),
	@orderColumn nvarchar(4000),
	@isAsc int

	select @tableName='WareHouse',@columns='*',@key='AutoID',@orderColumn='CreateTime desc',@isAsc=0
	set @condition=' ClientID='''+@ClientID+''' and Status<>9 '
	if(@keyWords <> '')
	begin
		set @condition +=' and (Name like ''%'+@keyWords+'%'' or  WareCode like ''%'+@keyWords+'%'' or  ShortName like ''%'+@keyWords+'%'') '
	end

	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,@orderColumn,@pageSize,@pageIndex,@total out,@page out,@isAsc 
	select @totalCount=@total,@pageCount =@page
 


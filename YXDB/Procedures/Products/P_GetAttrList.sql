Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetAttrList')
BEGIN
	DROP  Procedure  P_GetAttrList
END

GO
/***********************************************************
过程名称： P_GetAttrList
功能描述： 获取属性列表
参数说明：	 
编写日期： 2015/5/19
程序作者： Allen
调试记录： exec P_GetAttrList 
************************************************************/
CREATE PROCEDURE [dbo].[P_GetAttrList]
	@keyWords nvarchar(4000),
	@pageSize int,
	@pageIndex int,
	@totalCount int output ,
	@pageCount int output,
	@CategoryID nvarchar(64)=''
AS
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@key nvarchar(100),
	@orderColumn nvarchar(4000),
	@isAsc int

	select @tableName=' ProductAttr ',@columns=' AttrID,AttrName,Description ',@key='AutoID',@orderColumn='',@isAsc=0
	set @condition=' CategoryID='''+@CategoryID+''' and Status<>9 '
	if(@keyWords <> '')
	begin
		set @condition +=' and AttrName like ''%'+@keyWords+'%'' or  Description like ''%'+@keyWords+'%'''
	end

	declare @total int,@page int

	exec P_GetPagerData @tableName,@columns,@condition,@key,@orderColumn,@pageSize,@pageIndex,@total out,@page out,@isAsc

	select @totalCount=@total,@pageCount =@page
 


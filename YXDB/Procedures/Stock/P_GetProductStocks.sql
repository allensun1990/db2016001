Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetProductStocks')
BEGIN
	DROP  Procedure  P_GetProductStocks
END

GO
/***********************************************************
过程名称： P_GetProductStocks
功能描述： 获取产品列表
参数说明：	 
编写日期： 2015/6/29
程序作者： Allen
调试记录  declare @totalCount int ,@pageCount int 
		  exec P_GetProductStocks 
		  @keyWords='',
		  @pageSize=20,
		  @pageIndex=1,
		  @totalCount =@totalCount,
		  @pageCount =@pageCount,
		  @ClientID='d583bf9e-1243-44fe-ac5c-6fbc118aae36'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetProductStocks]
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
	@key nvarchar(100)

	select @tableName='Products P join Category C on P.CategoryID=C.CategoryID',@columns='P.*,C.CategoryName ',@key='P.AutoID'
	set @condition=' P.ClientID='''+@ClientID+''' and P.Status<>9 '
	if(@keyWords <> '')
	begin
		set @condition +=' and (ProductName like ''%'+@keyWords+'%'' or  ProductCode like ''%'+@keyWords+'%'' or  GeneralName like ''%'+@keyWords+'%'') '
	end

	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,'P.CreateTime',@pageSize,@pageIndex,@total out,@page out,0 
	select @totalCount=@total,@pageCount =@page
 


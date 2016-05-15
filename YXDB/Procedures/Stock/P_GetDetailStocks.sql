Use IntFactory_dev
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetDetailStocks')
BEGIN
	DROP  Procedure  P_GetDetailStocks
END

GO
/***********************************************************
过程名称： P_GetDetailStocks
功能描述： 获取产品列表
参数说明：	 
编写日期： 2015/6/29
程序作者： Allen
调试记录  declare @totalCount int ,@pageCount int 
		  exec P_GetDetailStocks 
		  @keyWords='',
		  @pageSize=20,
		  @pageIndex=1,
		  @totalCount =@totalCount,
		  @pageCount =@pageCount,
		  @ClientID='d583bf9e-1243-44fe-ac5c-6fbc118aae36'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetDetailStocks]
	@WareID nvarchar(64)='',
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

	select @tableName='ProductStock s 
					join Products p on s.ProductID=p.ProductID 
					join ProductDetail d on s.ProductDetailID=d.ProductDetailID',
	@columns='s.ProductDetailID,s.ProductID,p.ProductCode,d.DetailsCode,p.ProductName,d.SaleAttrValue,s.BatchCode,s.StockIn,s.StockOut,s.LogicOut,d.Description ',@key='s.AutoID'
	set @condition=' s.ClientID='''+@ClientID+''' and P.Status<>9 '

	if(@WareID<>'')
	begin
		set @condition+=' and s.WareID='''+@WareID+''''
	end

	if(@keyWords <> '')
	begin
		set @condition +=' and (p.ProductName like ''%'+@keyWords+'%'' or  p.ProductCode like ''%'+@keyWords+'%'' or  d.DetailsCode like ''%'+@keyWords+'%'') '
	end

	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,'',@pageSize,@pageIndex,@total out,@page out,0 
	select @totalCount=@total,@pageCount =@page
 


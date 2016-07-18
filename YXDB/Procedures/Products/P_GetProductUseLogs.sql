Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetProductUseLogs')
BEGIN
	DROP  Procedure  P_GetProductUseLogs
END

GO
/***********************************************************
过程名称： P_GetProductUseLogs
功能描述： 获取产品使用记录
参数说明：	 
编写日期： 2015/12/11
程序作者： Allen
调试记录  exec P_GetProductUseLogs 
		  @keyWords='New',
		  @ClientID='eda082bc-b848-4de8-8776-70235424fc06'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetProductUseLogs]
	@ProductID nvarchar(64),
	@pageSize int,
	@pageIndex int,
	@totalCount int output ,
	@pageCount int output
AS

	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@key nvarchar(100)


select @tableName='OrderDetail d join Orders o on o.OrderID=d.OrderID ',
@columns='o.PersonName,o.CityCode,o.Address,o.OrderCode,d.Remark,o.CreateTime,(d.Quantity+d.Loss)*o.PlanQuantity Quantity',@key='d.AutoID'
set @condition=' d.ProductID='''+@ProductID+''''

declare @total int,@page int
exec P_GetPagerData @tableName,@columns,@condition,@key,'',@pageSize,@pageIndex,@total out,@page out,1 
select @totalCount=@total,@pageCount =@page 


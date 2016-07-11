Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetOrdersByYXCode')
BEGIN
	DROP  Procedure  P_GetOrdersByYXCode
END

GO
/***********************************************************
过程名称： P_GetOrdersByYXCode
功能描述： 获取订单列表根据二当家客户端编码
参数说明：	 
编写日期： 2016/7/11
程序作者： MU
调试记录： 
declare @TotalCount int=0
declare @PageCount int=0
exec P_GetOrdersByYXCode @YXCode='6dd96291-f34e-440e-94c7-1a37c388eb46',@ClientID='12a65128-0fec-4544-927f-a2e6c8148511',
@TotalCount=@TotalCount out,@PageCount=@PageCount out
************************************************************/
CREATE PROCEDURE [dbo].P_GetOrdersByYXCode
@YXCode nvarchar(64),
@ClientID nvarchar(64)='',
@PageSize int=20,
@PageIndex int=1,
@TotalCount int output,
@PageCount int output
as
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@orderColumn nvarchar(100),
	@key nvarchar(100)

	declare @total int,@page int

	set @tableName='Orders'
	set @columns='*'
	set @key='OrderID'
	set @orderColumn='createtime desc'
	set @condition=' OrderType=1 and OrderStatus=2 '

	set @condition+=' and  CustomerID in ( select CustomerID from customer where YXClientCode='''+@YXCode+''' )'
	if(@ClientID<>'')
		set @condition+=' and ClientID='''+@ClientID+''''

	exec P_GetPagerData @tableName,@columns,@condition,@key,@orderColumn,@PageSize,@PageIndex,@total out,@page out,0 

	select @totalCount=@total,@pageCount =@page

		 






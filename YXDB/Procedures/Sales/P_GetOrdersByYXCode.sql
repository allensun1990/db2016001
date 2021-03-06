﻿Use IntFactory
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
修改信息： Michaux 2016-08-31 clientid in 查询
调试记录： 
declare @TotalCount int=0
declare @PageCount int=0
exec P_GetOrdersByYXCode @YXCode='6dd96291-f34e-440e-94c7-1a37c388eb46',@ClientID='12a65128-0fec-4544-927f-a2e6c8148511',
@TotalCount=@TotalCount out,@PageCount=@PageCount out
************************************************************/
CREATE PROCEDURE [dbo].P_GetOrdersByYXCode
@YXCode nvarchar(64)='',
@ClientID nvarchar(1000)='',
@keyWords nvarchar(500)='',
@CategoryID nvarchar(64)='',
@OrderBy nvarchar(64)='',
@BeginPrice nvarchar(64)='',
@EndPrice nvarchar(64)='',
@PageSize int=20,
@PageIndex int=1,
@TotalCount int output,
@PageCount int output
as
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@orderColumn nvarchar(100),
	@key nvarchar(100),
	@Sql nvarchar(4000)

	set @tableName='Goods'
	set @columns='GoodsID,Price,CreateTime,SaleCount'
	set @key='GoodsID'
	set @orderColumn='Goods.createtime desc'
	if(@OrderBy<>'')
		set @orderColumn=@OrderBy
	
	set @condition=' Status=1 and IsPublic=2 '
	
	if(@ClientID<>'-1')
		set @condition+='  and ClientID in ('''''+@ClientID+''''')'
		
	if(@keyWords<>'') 
		set @condition+='  and (GoodsCode like ''''%'+@keyWords+'%'''' or  GoodsName like ''''%'+@keyWords+'%'''') '

	if(@CategoryID<>'') 
		set @condition+='  and CategoryID in (select CategoryID  from Category where Status<>9 and PIDList like ''''%'+@CategoryID+'%'''' ) '
	if(@BeginPrice<>'') 
		set @condition+='  and Price>='''''+@BeginPrice+''''' '
	if(@EndPrice<>'') 
		set @condition+='  and Price< '''''+@EndPrice+''''' ' 

	set @Sql='declare @total int,@page int'
	set @Sql+=' declare @tmp table(AutoID int,GoodsID nvarchar(64),Price decimal(18,4),CreateTime datetime,SaleCount int) '
	
	set @Sql+=' insert into @tmp exec P_GetPagerData '''+@tableName+''','''+@columns+''','''+@condition+''','''+@key+''','''+@orderColumn+''','+str( @PageSize,2)+','+str(@PageIndex,4)+',@total out,@page out,0 '
	
	set @Sql+='select  orders.* from @tmp as goods join orders on goods.GoodsID=orders.goodsid
	where orders.orderstatus=2 and orders.ordertype=1 order by '+@orderColumn
	
	set @Sql+='  select @TotalCount=@total,@PageCount =@page '

	exec SP_EXECUTESQL @Sql,N'@TotalCount int out,@PageCount int out',@totalcount out,@pagecount out


 





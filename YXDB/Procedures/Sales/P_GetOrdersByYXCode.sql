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
@PageSize int=20,
@PageIndex int=1,
@OrderByColumn nvarchar(100)='',
@IsAsc int =0,
@TotalCount int output,
@PageCount int output
as
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@orderColumn nvarchar(100),
	@key nvarchar(100)

	set @tableName='Goods'
	set @columns='GoodsID'
	set @key='GoodsID'
	set @orderColumn='createtime desc'
	set @condition=' Status=1 and IsPublic=2 '
	
	if(@OrderByColumn<>'')
	begin
		set @orderColumn=@OrderByColumn
		if(@IsAsc=1)
			set @orderColumn+='  asc'
		else
		 set @orderColumn+='  desc'
	end 
	if(@ClientID<>'')
		set @condition+='  and ClientID in ('''+@ClientID+''')'
	if(@keyWords<>'') 
		set @condition+='  and (GoodsCode like ''%'+@keyWords+'%'' or  GoodsName like ''%'+@keyWords+'%'') '

	declare @total int,@page int
	declare @tmp table(AutoID int,GoodsID nvarchar(64))
	insert into @tmp exec P_GetPagerData @tableName,@columns,@condition,@key,@orderColumn,@PageSize,@PageIndex,@total out,@page out,0 

	select @totalCount=@total,@pageCount =@page

	select * from orders where goodsid in (select goodsid from @tmp) and orderstatus=2 and ordertype=1

		 






Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_IntoFeeChangePageList')
BEGIN
	DROP  Procedure  P_IntoFeeChangePageList
END

GO
/***********************************************************
过程名称： P_IntoFeeChangePageList
功能描述： 获取客户列表
参数说明：	 
编写日期： 2016/08/01
程序作者： Michaux
调试记录： exec P_IntoFeeChangePageList 
************************************************************/
create proc P_IntoFeeChangePageList
@ChangFeeType int,
@CustomerID varchar(50),
@AgentID varchar(50),
@ClientID varchar(50),
@BeginTime varchar(50),
@EndTime varchar(50),
@PageIndex int,
@PageSize int,
@totalCount int output ,
@pageCount int output
as
declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@key nvarchar(100),
	@orderColumn nvarchar(4000),
	@isAsc int
	
	select @tableName='IntegerFeeChange  ',
	@key='AutoID',
	@columns=' * ',
	@isAsc=0
	set @condition=' ClientID='''+@ClientID+''' and CustomerID='''+@CustomerID+''' '
	if(@ChangFeeType<>-1)
	begin
		set @condition +=' and ChangeType = '+convert(nvarchar(2), @ChangFeeType)
	end
 
	if(@BeginTime<>'')
		set @condition +=' and cus.CreateTime >= '''+@BeginTime+' 0:00:00'''

	if(@EndTime<>'')
		set @condition +=' and cus.CreateTime <=  '''+@EndTime+' 23:59:59'''

	 
	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,'',@pageSize,@pageIndex,@total out,@page out,@isAsc 
	select @totalCount=@total,@pageCount =@page

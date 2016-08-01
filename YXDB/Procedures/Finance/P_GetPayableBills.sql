Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetPayableBills')
BEGIN
	DROP  Procedure  P_GetPayableBills
END

GO
/***********************************************************
过程名称： P_GetPayableBills
功能描述： 获取应付账款
参数说明：	 
编写日期： 2015/11/17
程序作者： Allen
调试记录： exec P_GetPayableBills 
************************************************************/
CREATE PROCEDURE [dbo].[P_GetPayableBills]
	@PayStatus int=-1,
	@InvoiceStatus int=-1,
	@Keywords nvarchar(4000),
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@pageSize int,
	@pageIndex int,
	@totalCount int output ,
	@pageCount int output,
	@UserID nvarchar(64)='',
	@ClientID nvarchar(64)
AS
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@key nvarchar(100),
	@orderColumn nvarchar(4000),
	@isAsc int

	select @tableName='StorageBilling ',
	@columns='*',
	@key='AutoID',
	@orderColumn='CreateTime desc',
	@isAsc=0

	set @condition='ClientID='''+@ClientID+''' and Status<>9 '

	create table #UserID(UserID nvarchar(64))


	if(@PayStatus<>-1)
	begin
		set @condition +=' and PayStatus = '+convert(nvarchar(2), @PayStatus)
	end

	if(@InvoiceStatus<>-1)
	begin
		set @condition +=' and InvoiceStatus = '+convert(nvarchar(2), @InvoiceStatus)
	end

	if(@BeginTime<>'')
		set @condition +=' and CreateTime >= '''+@BeginTime+' 0:00:00'''

	if(@EndTime<>'')
		set @condition +=' and CreateTime <=  '''+@EndTime+' 23:59:59'''

	if(@keyWords <> '')
	begin
		set @condition +=' and (BillingCode like ''%'+@keyWords+'%'' or DocCode like ''%'+@keyWords+'%'')'
	end

	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,@orderColumn,@pageSize,@pageIndex,@total out,@page out,@isAsc 
	select @totalCount=@total,@pageCount =@page
 


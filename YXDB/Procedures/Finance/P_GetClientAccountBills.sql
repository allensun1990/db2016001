Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetClientAccountBills')
BEGIN
	DROP  Procedure  P_GetClientAccountBills
END

GO
/***********************************************************
过程名称： P_GetClientAccountBills
功能描述： 获取公司账户明细
参数说明：	 
编写日期： 2015/11/20
程序作者： Allen
调试记录： exec P_GetClientAccountBills 
************************************************************/
CREATE PROCEDURE [dbo].[P_GetClientAccountBills]
	@Mark int=-1,
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

	select @tableName='ClientAccounts ',
	@columns='*',
	@key='AutoID',
	@orderColumn='CreateTime desc',
	@isAsc=0

	set @condition='ClientID='''+@ClientID+''''

	create table #UserID(UserID nvarchar(64))

	if(@Mark<>-1)
	begin
		set @condition +=' and Mark = '+convert(nvarchar(2), @Mark)
	end

	if(@BeginTime<>'')
		set @condition +=' and CreateTime >= '''+@BeginTime+' 0:00:00'''

	if(@EndTime<>'')
		set @condition +=' and CreateTime <=  '''+@EndTime+' 23:59:59'''

	if(@keyWords <> '')
	begin
		set @condition +=' and Remark like ''%'+@keyWords+'%'''
	end

	declare @total int,@page int
	exec P_GetPagerData @tableName,@columns,@condition,@key,@orderColumn,@pageSize,@pageIndex,@total out,@page out,@isAsc 
	select @totalCount=@total,@pageCount =@page
 


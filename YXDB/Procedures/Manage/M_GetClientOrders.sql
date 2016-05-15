USE [IntFactory_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_GetClientOrders')
BEGIN
	DROP  Procedure  M_GetClientOrders
END

GO
/****** Object:  StoredProcedure [dbo].[M_GetClientOrders]    Script Date: 05/04/2016 13:19:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/***********************************************************
过程名称： M_GetClientOrders
功能描述： 查询客户订单列表
参数说明：	 
编写日期： 2015/12/4
程序作者： MU
调试记录： exec M_GetClientOrders 
修 改 人:  Michaux
修改信息:  添加公司名称
************************************************************/
Create PROCEDURE [M_GetClientOrders]
@Status int=-1,
@Type int=-1,
@BeginDate nvarchar(100),
@EndDate nvarchar(100),
@AgentID nvarchar(64),
@ClientID nvarchar(64),
@pageSize int,
@pageIndex int,
@totalCount int output,
@pageCount int output
AS
	declare @tableName nvarchar(4000),
	@columns nvarchar(4000),
	@condition nvarchar(4000),
	@orderColumn nvarchar(100),
	@key nvarchar(100)
	
	set @tableName='ClientOrder a left join Clients b on a.ClientId=b.ClientId'
	set @columns='a.*,b.CompanyName '
	set @key='a.AutoID'
	set @orderColumn=' a.createtime desc '
	set @condition=' 1=1 '

	if(@AgentID<>'')
		set @condition+=' and a.AgentID='''+@AgentID+''''
	if(@ClientID<>'')
		set @condition+=' and a.clientID='''+@ClientID+''''

	if(@Status<>-1)
		set @condition=@condition+' and a.status='+str(@Status)
	if(@Type<>-1)
		set @condition=@condition+' and a.Type='+str(@Type)
	if(@BeginDate<>'')
		set @condition=@condition+' and a.createtime>='''+@BeginDate+''''
	if(@EndDate<>'')
	    set @condition+=' and a.createtime<='''+cast(dateadd(day, 1, @EndDate) as varchar)+''''

 
	declare @total int,@page int

	exec P_GetPagerData @tableName,@columns,@condition,@key,@orderColumn,@pageSize,@pageIndex,@total out,@page out,0

	set @totalCount=@total
	set @pageCount =@page








GO



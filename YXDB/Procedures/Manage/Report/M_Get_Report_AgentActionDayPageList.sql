USE [IntFactory_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_Get_Report_AgentActionDayPageList')
BEGIN
	DROP  Procedure  M_Get_Report_AgentActionDayPageList
END

GO
/****** Object:  StoredProcedure [dbo].[M_Get_Report_AgentActionDayPageList]    Script Date: 05/04/2016 14:38:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***********************************************************
过程名称： M_Get_Report_AgentActionDayPageList
功能描述： 查询客户订单列表
参数说明：	 
编写日期： 2016/5/4
程序作者： Michaux
调试记录：DECLARE	 @totalCount int, @pageCount int exec M_Get_Report_AgentActionDayPageList '','2016-04-04','2016-04-07',5,1,@totalCount OUTPUT, @pageCount OUTPUT
************************************************************/
CREATE PROCEDURE [M_Get_Report_AgentActionDayPageList]
@Keyword nvarchar(100)='',
@BeginDate nvarchar(100)='',
@EndDate nvarchar(100)='',
@OrderBy nvarchar(100)='',
@pageSize int,
@pageIndex int,
@totalCount int output,
@pageCount int output
AS
	DECLARE @tableName nvarchar(400),
	@columns nvarchar(1000),
	@condition nvarchar(400),
	@groupColumn nvarchar(100)
	 if(LEN(@OrderBy)=0)
	 begin 
		set @OrderBy='SUM(a.CustomerCount) desc '
	 end 
	set @tableName='M_Report_AgentAction_Day as a left join Clients as c on a.ClientID=c.ClientID'
	set @columns='a.ClientID,c.CompanyName,c.createtime,SUM(a.CustomerCount) as CustomerCount, SUM(a.OrdersCount) as OrdersCount,
	  SUM( a.ActivityCount) as ActivityCount, SUM( a.ProductCount) as ProductCount, SUM( a.UsersCount) as UsersCount, SUM( a.AgentCount) as AgentCount,
	  SUM( a.OpportunityCount) as OpportunityCount, SUM( a.PurchaseCount) as PurchaseCount, SUM( a.WarehousingCount) as WarehousingCount,
	  SUM( a.TaskCount) as TaskCount ,  SUM( a.DownOrderCount) as DownOrderCount ,SUM( a.ProductOrderCount) as ProductOrderCount '
	  /**求活跃度均值,剔除 均值太小不要了*/
	 if(len(@EndDate)>0)
	  begin
		set @columns=@columns+ ',SUM(a.Vitality)/DATEDIFF(day,'''+@BeginDate+''',dateadd(day, 1,'''+ @EndDate+''')) as Vitality '
	  end
	  else begin
		set @columns=@columns+ ',SUM(a.Vitality)/count(a.ClientID) as Vitality '
	  end
	  set @condition=' c.Status=1 '

	if(@Keyword<>'')
		set @condition+=' and c.CompanyName like''%'+@Keyword+'%'''
	if(@BeginDate<>'')
		set @condition+=' and a.ReportDate>='''+@BeginDate+''''
	if(@EndDate<>'')
		set @condition+=' and a.ReportDate<='''+CONVERT(varchar(100), dateadd(day, 1, @EndDate), 23)+''''

	set @condition+=' group by a.ClientID,c.CompanyName,c.createtime'

 
	declare @CommandSQL nvarchar(4000)
	set @CommandSQL= 'select @totalCount=count(0) from( select a.ClientID  from '+@tableName+' where '+@condition +') as c'
	exec sp_executesql @CommandSQL,N'@totalCount int output',@totalCount output
	set @pageCount=CEILING(@totalCount * 1.0/@pageSize)

	if(@pageIndex=0 or @pageIndex=1)
	begin 
		set @CommandSQL='select top '+str(@pageSize)+' '+@columns+' from '+@tableName+' where '+@condition+' order by '+@OrderBy
	end
	else
	begin
		if(@pageIndex>@pageCount)
		begin
			set @pageIndex=@pageCount
		end
		set @CommandSQL='select * from (select row_number() over( order by '+@OrderBy+' ) as rowid ,'+@columns+' from '+@tableName+' where '+@condition+' ) as dt where rowid between '+str((@pageIndex-1) * @pageSize + 1)+' and '+str(@pageIndex* @pageSize)
	end
	
	exec (@CommandSQL)



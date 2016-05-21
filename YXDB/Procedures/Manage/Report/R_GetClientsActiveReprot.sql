USE [IntFactory_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetClientsActiveReprot')
BEGIN
	DROP  Procedure  R_GetClientsActiveReprot
END

GO
/****** Object:  StoredProcedure [dbo].[R_GetClientsActiveReprot]    Script Date: 05/21/2016 14:38:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***********************************************************
过程名称： R_GetClientsActiveReprot
功能描述： 查询客户活跃度列表
参数说明：	 
编写日期： 2016/5/21
程序作者： Michaux
调试记录： exec R_GetClientsActiveReprot 1,'2016-04-04','2016-06-07',''
************************************************************/

Create Proc R_GetClientsActiveReprot
	@DateType int=1,
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@ClientID nvarchar(64)=''
as
begin
	declare @SqlText nvarchar(4000)
	declare @SqlWhere nvarchar(4000)	
	set @SqlWhere=' where ReportDate between '''+@BeginTime+''' and dateadd(day,1,'''+@EndTime+''')'
	if(LEN(@ClientID)>0) 	
	begin 
		set @SqlWhere=@SqlWhere+' and ClientID='''+@ClientID+''''
	 end
	--按天统计
	if(@DateType=1)
	begin	
		set @SqlText=@SqlText+'select sum(Vitality),convert(varchar(8),ReportDate,112) AS ReportDate  from M_Report_AgentAction_Day a left join Clients b on a.ClientID=b.ClientID '
		set @SqlText+=@SqlWhere+'  group by  convert(varchar(8),ReportDate,112)'		
		exec(@SqlText);
	end
	--按周统计
	else if(@DateType=2)
	begin
		set @SqlText=@SqlText+',datename(year,ReportDate)+datename(week,ReportDate) as ReportDate from M_Report_AgentAction_Day a left join Clients b on a.ClientID=b.ClientID '
		set @SqlText+=@SqlWhere+' group by   datename(year,ReportDate)+datename(week,ReportDate)'		
		exec(@SqlText);		
	end
	--按月统计
	else if(@DateType=3)
	begin	
		set @SqlText=@SqlText+', convert(varchar(6),ReportDate,112) as ReportDate  from M_Report_AgentAction_Day a left join Clients b on a.ClientID=b.ClientID '
		set @SqlText+=@SqlWhere+' group by   convert(varchar(6),ReportDate,112)'		
		exec(@SqlText);
	end 
end
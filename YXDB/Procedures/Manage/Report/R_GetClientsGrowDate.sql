
Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetClientsGrowDate')
BEGIN
	DROP  Procedure  R_GetClientsGrowDate
END

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***********************************************************
过程名称： R_GetClientsGrowDate
功能描述： 获取客户注册数量
参数说明：	 
编写日期： 2016/04/21
程序作者： Michaux
调试记录： exec R_GetClientsGrowDate 1,'2014-1-1','2017-1-1'
************************************************************/
Create PROCEDURE R_GetClientsGrowDate
	@DateType int=1,
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)=''
as
begin
	declare @SqlText nvarchar(4000)
	set @SqlText=''
	--按天统计
	if(@DateType=1)
	begin	
		set @SqlText+='select convert(varchar(8),CreateTime,112) as CreateTime,COUNT(1)as TotalNum from Clients '
		set @SqlText+=' where CreateTime between '''+@BeginTime+''' and dateadd(day,1,'''+@EndTime+''')  group by  convert(varchar(8),CreateTime,112)'		
		exec(@SqlText);
	end
	--按周统计
	else if(@DateType=2)
	begin
		set @SqlText+='select datename(year,CreateTime)+datename(week,CreateTime) as CreateTime,COUNT(1)as TotalNum from Clients '
		set @SqlText+=' where CreateTime between '''+@BeginTime+''' and dateadd(day,1,'''+@EndTime+''')  group by   datename(year,CreateTime)+datename(week,CreateTime)'		
		exec(@SqlText);		
	end
	--按月统计
	else if(@DateType=3)
	begin	
		set @SqlText+='select convert(varchar(6),CreateTime,112) as CreateTime,COUNT(1)as TotalNum from Clients '
		set @SqlText+=' where CreateTime between '''+@BeginTime+''' and dateadd(day,1,'''+@EndTime+''')  group by   convert(varchar(6),CreateTime,112)'		
		exec(@SqlText);
	end

end
GO
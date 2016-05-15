Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetCustomerSourceDate')
BEGIN
	DROP  Procedure  R_GetCustomerSourceDate
END

GO
/***********************************************************
过程名称： R_GetCustomerSourceDate
功能描述： 获取客户来源统计
参数说明：	 
编写日期： 2015/11/30
程序作者： Allen
调试记录： exec R_GetCustomerSourceDate 4,'2014-1-1','2016-1-1','8c9b5e24-2bb5-4d87-9a5a-b1aa4c5b81f8','eda082bc-b848-4de8-8776-70235424fc06'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetCustomerSourceDate]
	@DateType int=3,
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@UserID nvarchar(64)='',
	@TeamID nvarchar(64)='',
	@AgentID nvarchar(64),
	@ClientID nvarchar(64)
AS

	declare @SqlText nvarchar(4000)
	create table #TempData(SourceID nvarchar(64),CustomerCount int,[DateName] nvarchar(50))
	create table #UserID(UserID nvarchar(64))
	if(@DateType=3)
	begin

		set @SqlText ='select SourceID,count(AutoID) Value,convert(char(6),CreateTime,112) Name  from Customer '
		set @SqlText+=' where  ClientID='''+@ClientID+''' and CreateTime between '''+@BeginTime+''' and dateadd(day,1,'''+@EndTime+''')'

		if(@UserID<>'')
		begin
			set @SqlText +=' and OwnerID = '''+@UserID+''''
		end
		else if(@TeamID<>'')
		begin
			insert into #UserID select UserID from TeamUser where TeamID=@TeamID and status=1
			set @SqlText +=' and OwnerID in (select UserID from #UserID) '
		end
		else
		begin
			set @SqlText +=' and AgentID = '''+@AgentID+''''
		end

		set @SqlText+='group by SourceID,convert(char(6),CreateTime,112)';

		exec(@SqlText);

		WITH NameTable AS  
		(  
			SELECT convert(char(6),DATEADD(month,number,@BeginTime),112) [Name]
			FROM   
			  master..spt_values   
			WHERE   
			  type='P'   
			and   
			  DATEADD(month,number,@BeginTime)<=@EndTime 
		)  
		select * from NameTable
	end
	else if(@DateType=4)
	begin
		set @SqlText ='select SourceID,count(AutoID) Value,datename(year,CreateTime)+datename(week,CreateTime) Name  from Customer '
		set @SqlText+='where  ClientID='''+@ClientID+''' and CreateTime between '''+@BeginTime+''' and dateadd(day,1,'''+@EndTime+''')'

		if(@UserID<>'')
		begin
			set @SqlText +=' and OwnerID = '''+@UserID+''''
		end
		else if(@TeamID<>'')
		begin
			insert into #UserID select UserID from TeamUser where TeamID=@TeamID and status=1
			set @SqlText +=' and OwnerID in (select UserID from #UserID) '
		end
		else
		begin
			set @SqlText +=' and AgentID = '''+@AgentID+''''
		end

		set @SqlText+='group by SourceID,datename(year,CreateTime)+datename(week,CreateTime)';

		exec(@SqlText);

		WITH NameTable AS  
		(  
			SELECT datename(year,DATEADD(week,number,@BeginTime))+datename(week,DATEADD(week,number,@BeginTime)) [Name]
			FROM   
			  master..spt_values   
			WHERE   
			  type='P'   
			and   
			  DATEADD(week,number,@BeginTime)<=@EndTime 
		)  
		select * from NameTable
	end
	else if(@DateType=5)
	begin
		set @SqlText ='select SourceID,count(AutoID) Value,convert(char(8),CreateTime,112) Name  from Customer ' 
		set @SqlText +='where  ClientID='''+@ClientID+''' and CreateTime between '''+@BeginTime+''' and dateadd(day,1,'''+@EndTime+''')'

		if(@UserID<>'')
		begin
			set @SqlText +=' and OwnerID = '''+@UserID+''''
		end
		else if(@TeamID<>'')
		begin
			insert into #UserID select UserID from TeamUser where TeamID=@TeamID and status=1
			set @SqlText +=' and OwnerID in (select UserID from #UserID) '
		end
		else
		begin
			set @SqlText +=' and AgentID = '''+@AgentID+''''
		end

		set @SqlText +='group by SourceID,convert(char(8),CreateTime,112)';

		exec(@SqlText);

		WITH NameTable AS  
		(  
			SELECT convert(char(8),DATEADD(day,number,@BeginTime),112) [Name]
			FROM   
			  master..spt_values   
			WHERE   
			  type='P'   
			and   
			  DATEADD(day,number,@BeginTime)<=@EndTime 
		)  
		select * from NameTable
	end

 


Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetOpportunityStageRate')
BEGIN
	DROP  Procedure  R_GetOpportunityStageRate
END

GO  
/***********************************************************
过程名称： R_GetOpportunityStageRate
功能描述： 销售订单转化率
参数说明：	 
编写日期： 2015/12/1
程序作者： Allen
调试记录： exec R_GetOpportunityStageRate '','','8c9b5e24-2bb5-4d87-9a5a-b1aa4c5b81f8','eda082bc-b848-4de8-8776-70235424fc06'
************************************************************/
Create PROCEDURE [dbo].[R_GetOpportunityStageRate]
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@UserID nvarchar(64)='',
	@TeamID nvarchar(64)='',
	@AgentID nvarchar(64),
	@ClientID nvarchar(64)
AS

	declare @SqlText nvarchar(4000)

	create table #UserID(UserID nvarchar(64))

	set @SqlText='select StageID,count(1) as Value,Sum(TotalMoney) iValue,Count(0) CountValue from  Opportunity where ClientID='''+@ClientID+''' and Status < 3'

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


	if(@BeginTime<>'')
	begin
		set @SqlText +=' and CreateTime >= '''+@BeginTime+' 0:00:00'''
	end

	if(@EndTime<>'')
	begin
		set @SqlText +=' and CreateTime <=  '''+@EndTime+' 23:59:59'''
	end

	set @SqlText+='Group by StageID'

	exec(@SqlText)


 


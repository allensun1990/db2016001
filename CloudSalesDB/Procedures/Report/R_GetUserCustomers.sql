Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetUserCustomers')
BEGIN
	DROP  Procedure  R_GetUserCustomers
END

GO
/***********************************************************
过程名称： R_GetUserCustomers
功能描述： 销售客户统计
参数说明：	 
编写日期： 2015/12/2
程序作者： Allen
修改记录： Michaux 2016-06-13 StageID 变更为StageStatus
调试记录： exec R_GetUserCustomers '','','','','8c9b5e24-2bb5-4d87-9a5a-b1aa4c5b81f8','eda082bc-b848-4de8-8776-70235424fc06'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetUserCustomers]
	@UserID nvarchar(64)='',
	@TeamID nvarchar(64)='',
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@AgentID nvarchar(64),
	@ClientID nvarchar(64)
AS

	declare @SqlText nvarchar(4000)

	set @SqlText='select StageStatus,COUNT(0) Value,OwnerID from  Customer where ClientID='''+@ClientID+''' and Status<>9'

	if(@AgentID<>'')
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

	if(@UserID<>'')
	begin
		set @SqlText +=' and OwnerID = '''+@UserID+''''
	end
	else if(@TeamID<>'')
	begin
		create table #UserID(UserID nvarchar(64))
		insert into #UserID select UserID from TeamUser where TeamID=@TeamID and status=1
		set @SqlText +=' and OwnerID in (select UserID from #UserID) '
	end

	set @SqlText+='Group by StageStatus,OwnerID'

	exec(@SqlText)


 


Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetCustomerStageRate')
BEGIN
	DROP  Procedure  R_GetCustomerStageRate
END

GO
/***********************************************************
过程名称： R_GetCustomerStageRate
功能描述： 客户转化率
参数说明：	 
编写日期： 2015/12/1
程序作者： Allen
调试记录： exec R_GetCustomerStageRate '','','8c9b5e24-2bb5-4d87-9a5a-b1aa4c5b81f8','eda082bc-b848-4de8-8776-70235424fc06'
************************************************************/
CREATE PROCEDURE [dbo].[R_GetCustomerStageRate]
	@BeginTime nvarchar(50)='',
	@EndTime nvarchar(50)='',
	@AgentID nvarchar(64),
	@ClientID nvarchar(64)
AS

	declare @SqlText nvarchar(4000)

	set @SqlText='select StageID,COUNT(0) Value,Status from  Customer where ClientID='''+@ClientID+''' and Status<>9'

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

	set @SqlText+='Group by StageID,Status'

	exec(@SqlText)


 


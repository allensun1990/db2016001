Use IntFactory_dev
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetTasksByEndTime')
BEGIN
	DROP  Procedure  P_GetTasksByEndTime
END

GO
/***********************************************************
过程名称： P_GetTasksByEndTime
功能描述： 获取任务列表根据交货时间
参数说明：	 
编写日期： 2016/6/1
程序作者： MU
调试记录： exec P_GetTasksByEndTime 'd3c9af49-e47c-4773-b2af-1fd8ccae127d'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetTasksByEndTime]
	@StartEndTime nvarchar(100)='',
	@EndEndTime nvarchar(100)='',
	@UserID nvarchar(64)='',
	@FilterType int =-1,
	@ClientID nvarchar(64)
AS
	declare @sql nvarchar(1000)

	set @sql='select * from OrderTask where status<>8 and FinishStatus=1 and ClientID='''+@ClientID+''''

	if(@UserID<>'')
		set @sql+=' and OwnerID='''+@UserID+''''

	if(@StartEndTime<>'')
		set @sql+=' and EndTime>='''+@StartEndTime+''''

	if(@EndEndTime<>'')
		set @sql+=' and EndTime<='''+CONVERT(varchar(100), dateadd(day, 1, @EndEndTime), 23)+''''

	if(@FilterType<>-1)
	begin
		if(@FilterType=1)
			begin
				set @sql+=' and EndTime<GETDATE() and FinishStatus=1 '
			end
		else if(@FilterType=3 or @FilterType=2)
		begin
			set @sql+=' and EndTime>GETDATE() and FinishStatus=1 '

			if(@FilterType=2)
			begin
				set @sql+='and DateDiff(HH,GETDATE(),EndTime)*3< DateDiff(HH,AcceptTime,EndTime)'
			end
			else
			begin
				set @sql+='and DateDiff(HH,GETDATE(),EndTime)*3>= DateDiff(HH,AcceptTime,EndTime)'
			end
		end
		else if(@FilterType=4)
		begin
			set @sql+=' and FinishStatus=2 '
		end
	end
	exec(@sql)



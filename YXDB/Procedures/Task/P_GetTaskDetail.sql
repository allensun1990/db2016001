Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetTaskDetail')
BEGIN
	DROP  Procedure  P_GetTaskDetail
END

GO
/***********************************************************
过程名称： P_GetTaskDetail
功能描述： 获取任务详情
参数说明：	 
编写日期： 2016/5/18
程序作者： MU
调试记录： declare @Result exec P_GetTaskDetail @TaskID='0B9E8812-2F90-4C5F-B879-860E54D81C39',@OwnerID='',@Result=@Result output
************************************************************/
CREATE PROCEDURE [dbo].P_GetTaskDetail
@TaskID nvarchar(64)
as
select * from  OrderTask where TaskID=@TaskID
select * from  TaskMember where TaskID=@TaskID and status<>9
		 






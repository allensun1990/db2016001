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
调试记录：  exec P_GetTaskDetail 'ff10aa3a-bbbc-4363-bb36-d587cb99acf5'
************************************************************/
CREATE PROCEDURE [dbo].P_GetTaskDetail
@TaskID nvarchar(64)
as
Declare @OrderID nvarchar(64)
select @OrderID=OrderID from OrderTask where TaskID=@TaskID

select * from OrderTask where TaskID=@TaskID
select * from TaskMember where TaskID=@TaskID and status<>9
select * from Orders where OrderID= @OrderID

		 






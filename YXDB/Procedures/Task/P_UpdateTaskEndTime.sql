Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateTaskEndTime')
BEGIN
	DROP  Procedure  P_UpdateTaskEndTime
END

GO
/***********************************************************
过程名称： P_UpdateTaskEndTime
功能描述： 更新订单任务到期日期
参数说明：	 
编写日期： 2016/2/21
程序作者： MU
调试记录： exec P_UpdateTaskEndTime @TaskID='0B9E8812-2F90-4C5F-B879-860E54D81C39',@EndTime='2016-1-1'
************************************************************/
CREATE PROCEDURE [dbo].P_UpdateTaskEndTime
@TaskID nvarchar(64),
@UserID nvarchar(64),
@EndTime datetime,
@Result int output --0：失败，1：成功，2: 任务已接受,3:没有权限
as
declare @OwnerID nvarchar(64)
set @Result=0

select @OwnerID=OwnerID from OrderTask where TaskID=@TaskID

--任务不是负责人操作
if(@OwnerID<>@UserID)
begin
	set @Result=3
	return
end

--任务已接受
if(exists(select taskid from ordertask where TaskID=@TaskID and FinishStatus<>0))
begin
	set @Result=2
	return
end

update OrderTask set endTime=@EndTime,FinishStatus=1,AcceptTime=GETDATE() where TaskID=@TaskID
set @Result=1
		 






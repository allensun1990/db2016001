Use IntFactory_dev
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UnLockTask')
BEGIN
	DROP  Procedure  P_UnLockTask
END

GO
/***********************************************************
过程名称： P_UnLockTask
功能描述： 将订单任务解锁
参数说明：	 
编写日期： 2016/5/27
程序作者： MU
调试记录： declare @Result exec P_UnLockTask @TaskID='0B9E8812-2F90-4C5F-B879-860E54D81C39',@UserID='',@Result=@Result output
************************************************************/
CREATE PROCEDURE [dbo].P_UnLockTask
@TaskID nvarchar(64),
@UserID nvarchar(64),
@Result int output --0：失败，1：成功，2: 任务已被解锁,3:没有权限
as
	declare @OrderID nvarchar(64)
	declare @OwnerID nvarchar(64)
	declare @OrderOwnerID nvarchar(64)

	set @Result=0
	select @OrderID=OrderID,@OwnerID=OwnerID from OrderTask where TaskID=@TaskID and LockStatus=1 and status<>9
	--任务已被解锁
	if(@OwnerID is null)
	begin
		set @Result=2
		return
	end

	--select @OrderOwnerID=OwnerID from Orders where OrderID=@OrderID
	----没权限操作
	--if(@OrderOwnerID<>@UserID)
	--begin
	--	set @Result=3
	--	return
	--end

	--将任务锁定
	update OrderTask set LockStatus=2 where TaskID=@TaskID

	set @Result=1
		 






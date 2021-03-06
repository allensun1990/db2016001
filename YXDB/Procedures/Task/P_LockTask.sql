﻿Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_LockTask')
BEGIN
	DROP  Procedure  P_LockTask
END

GO
/***********************************************************
过程名称： P_LockTask
功能描述： 将订单任务锁定
参数说明：	 
编写日期： 2016/5/27
程序作者： MU
调试记录： declare @Result exec P_LockTask @TaskID='0B9E8812-2F90-4C5F-B879-860E54D81C39',@UserID='',@Result=@Result output
************************************************************/
CREATE PROCEDURE [dbo].P_LockTask
@TaskID nvarchar(64),
@UserID nvarchar(64),
@Result int output --0：失败，1：成功，2: 任务没有被解锁,3:没有权限
as
	declare @OwnerID nvarchar(64)
	set @Result=0

	select @OwnerID=OwnerID from OrderTask where TaskID=@TaskID and LockStatus=2 and status<>9
	--任务没有被解锁
	if(@OwnerID is null)
	begin
		set @Result=2
		return
	end

	--将任务锁定
	update OrderTask set LockStatus=1 where TaskID=@TaskID

	set @Result=1
		 






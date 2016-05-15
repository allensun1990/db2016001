Use IntFactory_dev
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateTaskOwner')
BEGIN
	DROP  Procedure  P_UpdateTaskOwner
END

GO
/***********************************************************
过程名称： P_UpdateTaskOwner
功能描述： 更改任务负责人
参数说明：	 
编写日期： 2016/3/11
程序作者： MU
调试记录： declare @Result exec P_UpdateTaskOwner @TaskID='0B9E8812-2F90-4C5F-B879-860E54D81C39',@OwnerID='',@Result=@Result output
************************************************************/
CREATE PROCEDURE [dbo].P_UpdateTaskOwner
@TaskID nvarchar(64),
@OwnerID nvarchar(64),
@Result int output --0：失败，1：成功，2: 完成状态为未接受
as

 -- if(exists (select taskid from ordertask where taskid=@TaskID and finishstatus>0) )
	--begin
	--	set @Result=2
	--	return
	--end

	update ordertask set OwnerID=@OwnerID where taskid=@TaskID

	set  @Result=1
		 






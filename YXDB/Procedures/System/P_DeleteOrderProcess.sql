Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteOrderProcess')
BEGIN
	DROP  Procedure  P_DeleteOrderProcess
END

GO
/***********************************************************
过程名称： P_DeleteOrderProcess
功能描述： 删除流程
参数说明：	 
编写日期： 2016/6/17
程序作者： Allen
调试记录： exec P_DeleteOrderProcess 
************************************************************/
CREATE PROCEDURE [dbo].P_DeleteOrderProcess
@ProcessID nvarchar(64),
@ClientID nvarchar(64)='',
@Result int output
AS

begin tran

if exists(select AutoID from Orders where ProcessID=@ProcessID and Status<>9)
begin
	set @Result=2
	rollback tran
	return
end

declare @Err int=0

Update OrderProcess set Status=9 where ProcessID=@ProcessID

delete from [OrderStage] where ProcessID=@ProcessID

set @Err+=@@error
set @Result=1

if(@Err>0)
begin
	set @Result=0
	rollback tran
end 
else
begin
	commit tran
end
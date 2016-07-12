Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteProvider')
BEGIN
	DROP  Procedure  P_DeleteProvider
END

GO
/***********************************************************
过程名称： P_DeleteProvider
功能描述： 删除供应商
参数说明：	 
编写日期： 2016/6/1
程序作者： Allen
调试记录： exec P_DeleteProvider 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteProvider]
@ProviderID nvarchar(64),
@ClientID nvarchar(64),
@Result int output --0：失败，1：成功，10002 存在关联数据 10003 至少保留一个供应商
AS

begin tran

set @Result=0

declare @Err int=0

if not exists(select AutoID from Providers where ClientID=@ClientID and Status<>9 and ProviderID<>@ProviderID)
begin
	set @Result=10003
	rollback tran
	return
end

--存在关联数据
if exists(select AutoID from Products where ClientID=@ClientID and Status<>9 and ProviderID=@ProviderID)
begin
	set @Result=10002
	rollback tran
	return
end

if exists(select AutoID from StorageDoc where ClientID=@ClientID and Status<>9 and ProviderID=@ProviderID)
begin
	set @Result=10002
	rollback tran
	return
end

set @Err+=@@error

Update Providers set Status=9  where ProviderID=@ProviderID

if(@Err>0)
begin
	set @Result=0
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end
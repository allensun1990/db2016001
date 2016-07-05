Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteDepotSeat')
BEGIN
	DROP  Procedure  P_DeleteDepotSeat
END

GO
/***********************************************************
过程名称： P_DeleteDepotSeat
功能描述： 删除货位
参数说明：	 
编写日期： 2016/7/5
程序作者： Allen
调试记录： exec P_DeleteDepotSeat 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteDepotSeat]
@DepotID nvarchar(64),
@UserID nvarchar(64),
@ClientID nvarchar(64),
@Result int output --0：失败，1：成功，2 存在业务
AS

begin tran

set @Result=0

declare @Err int=0

--货位存在业务
if exists(select AutoID from StorageDetail where ClientID=@ClientID and DepotID=@DepotID and Status<>9)
begin
	set @Result=2
	rollback tran
	return
end

if exists(select AutoID from StoragePartDetail where DepotID=@DepotID and Status<>9)
begin
	set @Result=2
	rollback tran
	return
end

set @Err+=@@error

Update DepotSeat set Status=9 where DepotID=@DepotID

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
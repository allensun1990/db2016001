Use IntFactory_dev
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
编写日期： 2015/10/21
程序作者： Allen
调试记录： exec P_DeleteDepotSeat 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteDepotSeat]
@DepotID nvarchar(64),
@ClientID nvarchar(64)
AS

begin tran


declare @Err int=0

--存在流水
if exists(select AutoID from ProductStock where DepotID=@DepotID)
begin
	rollback tran
	return
end

set @Err+=@@error

Update DepotSeat set Status=9 where DepotID=@DepotID and ClientID=@ClientID 


if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end
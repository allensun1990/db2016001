﻿Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteCart')
BEGIN
	DROP  Procedure  P_DeleteCart
END

GO
/***********************************************************
过程名称： P_DeleteCart
功能描述： 删除购物车产品
参数说明：	 
编写日期： 2015/12/6
程序作者： Allen
调试记录： exec P_DeleteCart 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteCart]
@AutoID int,
@GUID nvarchar(64)=''
AS
begin tran

declare @Err int=0,@TotalMoney decimal(18,4)=0,@OrderType int

if exists(select AutoID from ShoppingCart where AutoID=@AutoID)
begin
	select @OrderType=OrderType,@GUID=[GUID] from ShoppingCart where AutoID=@AutoID

	delete from ShoppingCart  where AutoID=@AutoID and [GUID]=@GUID
end

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end
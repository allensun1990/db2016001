Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateCartQuantity')
BEGIN
	DROP  Procedure  P_UpdateCartQuantity
END

GO
/***********************************************************
过程名称： P_UpdateCartQuantity
功能描述： 修改购物车数量
参数说明：	 
编写日期： 2015/12/6
程序作者： Allen
调试记录： exec P_UpdateCartQuantity 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateCartQuantity]
@AutoID int,
@Quantity decimal(18,4)=1,
@GUID nvarchar(64)=''
AS
begin tran

declare @Err int=0,@TotalMoney decimal(18,4)=0,@OrderType int

if exists(select AutoID from ShoppingCart where AutoID=@AutoID)
begin
	select @OrderType=OrderType,@GUID=[GUID] from ShoppingCart where AutoID=@AutoID

	update ShoppingCart set Quantity=@Quantity where AutoID=@AutoID and [GUID]=@GUID
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
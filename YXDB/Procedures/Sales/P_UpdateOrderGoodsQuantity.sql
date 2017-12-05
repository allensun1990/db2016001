Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderGoodsQuantity')
BEGIN
	DROP  Procedure  P_UpdateOrderGoodsQuantity
END

GO
/***********************************************************
过程名称： P_UpdateOrderGoodsQuantity
功能描述： 编辑大货单明细
参数说明：	 
编写日期： 2017/11/16
程序作者： Allen
调试记录： exec P_UpdateOrderGoodsQuantity 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderGoodsQuantity]
@OrderID nvarchar(64),
@AutoID int,
@Quantity decimal(18,4)
AS


declare @GoodsID nvarchar(64),@Status int,@GoodsDetailID nvarchar(64),@Price decimal(18,4),@OriginalPrice decimal(18,4),@OriginalID nvarchar(64),
@DetailID nvarchar(64),@TotalQuantity decimal(18,4),@TotalMoney decimal(18,4),@OrderClientID nvarchar(64),@OrderType int

select @GoodsID=isnull(GoodsID,''),@Status=OrderStatus,@Price=FinalPrice,@OriginalPrice=OriginalPrice,@OrderClientID=ClientID,@OrderType=OrderType,
		@OriginalID=OriginalID
from Orders where OrderID=@OrderID

if(@Status > 2)
begin
	return
end

Update OrderGoods set Quantity=@Quantity,TotalMoney=Price*@Quantity where AutoID=@AutoID and OrderID=@OrderID

select @TotalQuantity=sum(Quantity) from OrderGoods where OrderID=@OrderID

Update Orders set PlanQuantity=@TotalQuantity where OrderID=@OrderID






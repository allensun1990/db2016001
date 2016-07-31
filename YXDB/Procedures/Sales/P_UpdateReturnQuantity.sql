Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateReturnQuantity')
BEGIN
	DROP  Procedure  P_UpdateReturnQuantity
END

GO
/***********************************************************
过程名称： P_UpdateReturnQuantity
功能描述： 更换订单产品退货数量
参数说明：	 
编写日期： 2015/11/25
程序作者： Allen
调试记录： exec P_UpdateReturnQuantity 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateReturnQuantity]
	@OrderID nvarchar(64),
	@AutoID int ,
	@Quantity int=0 ,
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int,@ReturnStatus int

select @Status=Status,@ReturnStatus=ReturnStatus from Orders where OrderID=@OrderID  and ClientID=@ClientID

if(@Status<>2 or @ReturnStatus=1)
begin
	rollback tran
	return
end

update OrderGoods set ApplyQuantity=@Quantity where OrderID=@OrderID and AutoID=@AutoID and Quantity-ReturnQuantity>=@Quantity

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 


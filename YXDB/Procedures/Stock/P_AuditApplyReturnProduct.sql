Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AuditApplyReturnProduct')
BEGIN
	DROP  Procedure  P_AuditApplyReturnProduct
END

GO
/***********************************************************
过程名称： P_AuditApplyReturnProduct
功能描述： 审核退货申请
参数说明：	 
编写日期： 2015/11/25
程序作者： Allen
调试记录： exec P_AuditApplyReturnProduct 
************************************************************/
CREATE PROCEDURE [dbo].[P_AuditApplyReturnProduct]
@OrderID nvarchar(64),
@WareID nvarchar(64),
@DocCode nvarchar(50)='',
@UserID nvarchar(64),
@ClientID nvarchar(64),
@Result int output,
@ErrInfo nvarchar(500) output
AS

begin tran

declare @Err int=0,@OrderStatus int,@OrderSendStatus int,@OldOrderID nvarchar(64),@ReturnStatus int,@TotalMoney decimal(18,4)=0,
		@OrderCode nvarchar(50),@DocID nvarchar(64),@DepotID nvarchar(64)

select @OrderStatus=Status,@OrderSendStatus=SendStatus,@OldOrderID=OriginalID,@ReturnStatus=ReturnStatus,@OrderCode=OrderCode  
from Orders where OrderID=@OrderID

if(@ReturnStatus<>1)
begin
	set @Result=2 
	set @ErrInfo='退货申请已处理，不能重复操作！'
	rollback tran
	return
end

set @DocID=NEWID()

--代理商订单信息
declare @AutoID int=1,@ProductID nvarchar(64),@ProductDetailID nvarchar(64),@Quantity int,@Price decimal(18,4),@UnitID nvarchar(64),@Remark nvarchar(500)



set @Err+=@@Error

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
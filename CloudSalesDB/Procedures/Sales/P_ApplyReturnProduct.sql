Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_ApplyReturnProduct')
BEGIN
	DROP  Procedure  P_ApplyReturnProduct
END

GO
/***********************************************************
过程名称： P_ApplyReturnProduct
功能描述： 退货申请
参数说明：	 
编写日期： 2015/11/25
程序作者： Allen
调试记录： exec P_ApplyReturnProduct 
************************************************************/
CREATE PROCEDURE [dbo].[P_ApplyReturnProduct]
	@OrderID nvarchar(64),
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)='',
	@Result int output
AS
	
begin tran

set @Result=0

--订单信息
declare @Err int=0,@Status int,@OrderAgentID nvarchar(64),@OrderCode nvarchar(50),@TotalMoney decimal(18,4),@ReturnStatus nvarchar(64)
select @Status=Status,@OrderAgentID=AgentID,@OrderCode=OrderCode,@TotalMoney=TotalMoney,@ReturnStatus=ReturnStatus from Orders where OrderID=@OrderID and ClientID=@ClientID

if(@Status<>2 or @ReturnStatus=1)
begin
	rollback tran
	return
end

--代理商信息
declare @IsDefault int
select @IsDefault=IsDefault from Agents where AgentID=@OrderAgentID


--代理商订单信息
declare @AutoID int=1,@ProductID nvarchar(64),@ProductDetailID nvarchar(64),@Quantity int,@AgentOrderID nvarchar(64)

select @AgentOrderID=OrderID from AgentsOrders where OriginalID=@OrderID


--汇总产品明细库存
select identity(int,1,1) as AutoID,ProductID,ProductDetailID,SUM(Quantity) Quantity into #TempProducts from(
select ProductID,ProductDetailID,case IsBigUnit when 0 then ApplyQuantity else ApplyQuantity*BigSmallMultiple end Quantity
from OrderDetail  where OrderID=@OrderID and ApplyQuantity>0) r
group by ProductID,ProductDetailID

set @Err+=@@error

--默认代理商
if(@IsDefault=1)
begin
	while exists(select AutoID from #TempProducts where AutoID=@AutoID)
	begin
		--订单明细和产品信息
		select @ProductID=ProductID,@ProductDetailID=ProductDetailID,@Quantity=Quantity from #TempProducts where AutoID=@AutoID

		set @Err+=@@error

		--代理商采购明细
		update AgentsOrderDetail set ApplyQuantity=@Quantity where OrderID=@AgentOrderID and ProductDetailID=@ProductDetailID

		set @Err+=@@error

		set @AutoID=@AutoID+1
	end
end
else --其他代理商待续
begin
	if(1=2)
	begin
		set @Result=3
		rollback tran
		return
	end
end


--订单状态					
Update Orders set ReturnStatus=1 where OrderID=@OrderID
set @Err+=@@error

Update AgentsOrders set ReturnStatus=1 where OrderID=@AgentOrderID
set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end

 


 


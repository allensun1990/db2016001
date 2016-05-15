Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_ConfirmAgentOrderOut')
BEGIN
	DROP  Procedure  P_ConfirmAgentOrderOut
END

GO
/***********************************************************
过程名称： P_ConfirmAgentOrderOut
功能描述： 出库审核
参数说明：	 
编写日期： 2015/11/23
程序作者： Allen
调试记录： exec P_ConfirmAgentOrderOut 
************************************************************/
CREATE PROCEDURE [dbo].[P_ConfirmAgentOrderOut]
@OrderID nvarchar(64),
@WareID nvarchar(64),
@IsSend int=0,
@ExpressID nvarchar(64)='',
@ExpressCode nvarchar(100)='',
@DocCode nvarchar(50),
@UserID nvarchar(64),
@AgentID nvarchar(64)='',
@ClientID nvarchar(64),
@Result int output,
@ErrInfo nvarchar(500) output
AS

begin tran

declare @OrderStatus int,@OrderSendStatus int,@OldOrderID nvarchar(64),@ReturnStatus int,@OrderCode nvarchar(64)

declare @Err int=0,@ProductID nvarchar(64),@ProductDetailID nvarchar(64),@Quantity int,@Remark nvarchar(500),@Price decimal(18,4),@UnitID nvarchar(64),
		@DocID nvarchar(64),@BatchCode nvarchar(50),@BatchQuantity int,@DepotID nvarchar(64),@AutoID int=1,@BatchAutoID int=1

select @OrderStatus=Status,@OrderSendStatus=SendStatus,@OldOrderID=OriginalID,@ReturnStatus=ReturnStatus,@OrderCode=OrderCode  from AgentsOrders where OrderID=@OrderID

if(@OrderSendStatus>0 and @OrderStatus=2)
begin
	set @Result=2 --订单已出库
	set @ErrInfo='订单已出库!'
	rollback tran
	return
end
if(@ReturnStatus>0 or @OrderStatus=3)
begin
	set @Result=3 --订单已退单
	set @ErrInfo='订单已退单!'
	rollback tran
	return
end

set @DocID=NEWID() 

select identity(int,1,1) as AutoID,ProductID,ProductDetailID, Quantity,Price ,Remark,UnitID into #TempProducts 
from AgentsOrderDetail where OrderID=@OrderID

create table #BatchStock(AutoID int identity(1,1),DepotID nvarchar(64),BatchCode nvarchar(50),Quantity int)
--遍历产品
while exists(select AutoID from #TempProducts where AutoID=@AutoID)
begin
	select @ProductID=ProductID,@ProductDetailID=ProductDetailID,@Quantity=Quantity,@Price=price,@UnitID=UnitID,@Remark=Remark from #TempProducts where AutoID=@AutoID

	--修改产品出库数
	update Products set SaleCount=SaleCount+@Quantity where ProductID=@ProductID

	--修改产品明细出库数
	update ProductDetail set SaleCount=SaleCount+@Quantity where ProductDetailID=@ProductDetailID

	truncate table #BatchStock

	insert into #BatchStock(DepotID,BatchCode,Quantity) 
	select DepotID,BatchCode,StockIn-StockOut from ProductStock 
	where WareID=@WareID and ProductID=@ProductID and ProductDetailID=@ProductDetailID and StockIn-StockOut>0 order by BatchCode

	set @BatchAutoID=1
	--遍历批次库存
	while exists(select AutoID from #BatchStock where AutoID=@BatchAutoID)
	begin
		select @DepotID=DepotID,@BatchCode=BatchCode,@BatchQuantity=Quantity from #BatchStock where AutoID=@BatchAutoID

		if(@BatchQuantity>=@Quantity)
		begin
			insert into StorageDetail(DocID,ProductDetailID,ProductID,UnitID,IsBigUnit,Quantity,Price,TotalMoney,WareID,DepotID,BatchCode,Status,Remark,ClientID)
			values( @DocID,@ProductDetailID,@ProductID,@UnitID,0,@Quantity,@Price,@Quantity*@Price,@WareID,@DepotID,@BatchCode,1,@Remark,@ClientID )

			update ProductStock set StockOut=StockOut+@Quantity where DepotID=@DepotID and BatchCode=@BatchCode and ProductID=@ProductID and ProductDetailID=@ProductDetailID

			--处理产品流水
			insert into ProductStream(ProductDetailID,ProductID,DocID,DocCode,BatchCode,DocDate,DocType,Mark,Quantity,WareID,DepotID,CreateUserID,ClientID)
					values(@ProductDetailID,@ProductID,@DocID,@DocCode,@BatchCode,CONVERT(varchar(100), GETDATE(), 112),2,1,@Quantity,@WareID,@DepotID,@UserID,@ClientID)
			
			set @Quantity=0
			break;

		end
		else
		begin
			insert into StorageDetail(DocID,ProductDetailID,ProductID,UnitID,IsBigUnit,Quantity,Price,TotalMoney,WareID,DepotID,BatchCode,Status,Remark,ClientID)
			values( @DocID,@ProductDetailID,@ProductID,@UnitID,0,@BatchQuantity,@Price,@BatchQuantity*@Price,@WareID,@DepotID,@BatchCode,1,@Remark,@ClientID )

			update ProductStock set StockOut=StockOut+@BatchQuantity where DepotID=@DepotID and BatchCode=@BatchCode and ProductID=@ProductID and ProductDetailID=@ProductDetailID

			--处理产品流水
			insert into ProductStream(ProductDetailID,ProductID,DocID,DocCode,BatchCode,DocDate,DocType,Mark,Quantity,WareID,DepotID,CreateUserID,ClientID)
					values(@ProductDetailID,@ProductID,@DocID,@DocCode,@BatchCode,CONVERT(varchar(100), GETDATE(), 112),2,1,@BatchQuantity,@WareID,@DepotID,@UserID,@ClientID)
			
			set @Quantity=@Quantity-@BatchQuantity
			
		end

		set @BatchAutoID=@BatchAutoID+1
	end

	if(@Quantity>0)
	begin
		set @Result=4 --库存不足
		select  @ErrInfo=ProductName+' '+@Remark+'库存差：'+convert(nvarchar,@Quantity) from Products where ProductID=@ProductID
		rollback tran
		return
	end

	set  @AutoID=@AutoID+1
end


declare @SendStatus int=2

if(@IsSend=0)
begin
	set @SendStatus=1
	set @ExpressID=''
	set @ExpressCode=''
end

insert into StorageDoc(DocID,DocCode,DocType,Status,TotalMoney,CityCode,Address,PostalCode,Remark,OriginalID,OriginalCode ,WareID,ExpressID,ExpressCode,CreateUserID,CreateTime,OperateIP,ClientID)
select @DocID,@DocCode,2,2,TotalMoney,CityCode,Address,PostalCode,Remark,@OrderID,@OrderCode,@WareID,@ExpressID,@ExpressCode,@UserID,GETDATE(),'',@ClientID from AgentsOrders where OrderID=@OrderID

Update AgentsOrders set SendStatus=@SendStatus,ExpressID=@ExpressID,ExpressCode=@ExpressCode,DocID=@DocID,DocCode=@DocCode where OrderID=@OrderID

update Orders set SendStatus=@SendStatus,ExpressID=@ExpressID,ExpressCode=@ExpressCode where OrderID=@OldOrderID

drop table #BatchStock
drop table #TempProducts

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
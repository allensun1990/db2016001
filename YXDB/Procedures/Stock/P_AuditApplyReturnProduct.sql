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
@AgentID nvarchar(64)='',
@ClientID nvarchar(64),
@Result int output,
@ErrInfo nvarchar(500) output
AS

begin tran

declare @Err int=0,@OrderStatus int,@OrderSendStatus int,@OldOrderID nvarchar(64),@ReturnStatus int,@TotalMoney decimal(18,4)=0,@OrderAgentID nvarchar(64),
		@OrderCode nvarchar(50),@DocID nvarchar(64),@DepotID nvarchar(64)

select @OrderStatus=Status,@OrderSendStatus=SendStatus,@OldOrderID=OriginalID,@ReturnStatus=ReturnStatus,@OrderAgentID=AgentID,@OrderCode=OrderCode  
from AgentsOrders where OrderID=@OrderID

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


select identity(int,1,1) as AutoID,ProductID,ProductDetailID,ApplyQuantity,Price,UnitID,Remark into #TempProducts 
from AgentsOrderDetail where OrderID=@OrderID and ApplyQuantity>0

--代理商信息
declare @IsDefault int,@levelMoney decimal(18,4)
select @IsDefault=IsDefault,@levelMoney=TotalIn-TotalOut from Agents where AgentID=@OrderAgentID

if(@IsDefault=1)
begin
	while exists(select AutoID from #TempProducts where AutoID=@AutoID)
	begin
	
		select @ProductID=ProductID,@ProductDetailID=ProductDetailID,@Quantity=ApplyQuantity,@Price=Price,@UnitID=UnitID,@Remark=Remark from #TempProducts where AutoID=@AutoID

		insert into AgentsStream(ProductDetailID,ProductID,OrderID,OrderCode,OrderDate,Mark,Quantity,SurplusQuantity,AgentID,ClientID)
							values(@ProductDetailID,@ProductID,@OrderID,@OrderCode,CONVERT(varchar(100), GETDATE(), 112),1,@Quantity,0,@OrderAgentID,@ClientID)

		insert into AgentsStream(ProductDetailID,ProductID,OrderID,OrderCode,OrderDate,Mark,Quantity,SurplusQuantity,AgentID,ClientID)
							values(@ProductDetailID,@ProductID,@OldOrderID,@OrderCode,CONVERT(varchar(100), GETDATE(), 112),0,@Quantity,0,@OrderAgentID,@ClientID)
		set @Err+=@@Error

		Update AgentsStock set TotalInWay=TotalInWay-@Quantity,TotalOut=TotalOut-@Quantity where ProductDetailID=@ProductDetailID and AgentID=@OrderAgentID

		set @Err+=@@Error
		--生成退货单明细

		if exists(select AutoID from ProductStock where ProductDetailID=@ProductDetailID and WareID=@WareID)
		begin
			select top 1 @DepotID=DepotID from ProductStock where ProductDetailID=@ProductDetailID and WareID=@WareID order by BatchCode desc
		end
		else
		begin
			select top 1 @DepotID = DepotID from DepotSeat where WareID=@WareID and Status=1
		end

		insert into StorageDetail(DocID,ProductDetailID,ProductID,UnitID,IsBigUnit,Quantity,Price,TotalMoney,WareID,DepotID,BatchCode,Status,Remark,ClientID)
			values( @DocID,@ProductDetailID,@ProductID,@UnitID,0,@Quantity,@Price,@Quantity*@Price,@WareID,@DepotID,'',0,@Remark,@ClientID )

		set @TotalMoney+=@Quantity*@Price

		set @AutoID=@AutoID+1
	end

	update Agents set TotalOut=TotalOut-@TotalMoney where AgentID=@OrderAgentID

	--代理商账户处理
	insert into AgentsAccounts(AgentID,HappenMoney,EndMoney,Mark,SubjectID,Remark,CreateUserID,ClientID)
	values(@OrderAgentID,@TotalMoney,@levelMoney+@TotalMoney,0,3,'采购订单退货，订单号：'+@OrderCode,@UserID,@ClientID)
	set @Err+=@@Error

	--销售订单状态
	Update OrderDetail set ReturnQuantity=ReturnQuantity+ApplyQuantity,ApplyQuantity=0,ReturnMoney=(ReturnQuantity+ApplyQuantity)*Price where OrderID=@OldOrderID
 
	if exists(select AutoID from OrderDetail where OrderID=@OldOrderID and Quantity-ReturnQuantity>0)
	begin
		update Orders set ReturnStatus=2,ReturnMoney=ReturnMoney+@TotalMoney where OrderID=@OldOrderID
	end
	else
	begin
		update Orders set ReturnStatus=3,ReturnMoney=ReturnMoney+@TotalMoney where OrderID=@OldOrderID
	end
	set @Err+=@@Error
end

--代理商订单
Update AgentsOrderDetail set ReturnQuantity=ReturnQuantity+ApplyQuantity,ApplyQuantity=0,ReturnMoney=(ReturnQuantity+ApplyQuantity)*Price where OrderID=@OrderID 

if exists(select AutoID from AgentsOrderDetail where OrderID=@OrderID and Quantity-ReturnQuantity>0)
begin
	update AgentsOrders set ReturnStatus=2,ReturnMoney=ReturnMoney+@TotalMoney where OrderID=@OrderID
end
else
begin
	update AgentsOrders set ReturnStatus=3,ReturnMoney=ReturnMoney+@TotalMoney where OrderID=@OrderID
end

--生成退货单
insert into StorageDoc(DocID,DocCode,DocType,Status,TotalMoney,CityCode,Address,PostalCode,Remark,OriginalID,OriginalCode ,WareID,ExpressID,ExpressCode,CreateUserID,CreateTime,OperateIP,ClientID)
				values(@DocID,@DocCode,6,0,@TotalMoney,'','','','',@OrderID,@OrderCode,@WareID,'','',@UserID,GETDATE(),@UserID,@ClientID)

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
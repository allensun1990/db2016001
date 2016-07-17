Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_EffectiveOrder')
BEGIN
	DROP  Procedure  P_EffectiveOrder
END

GO
/***********************************************************
过程名称： P_EffectiveOrder
功能描述： 生效订单
参数说明：	 
编写日期： 2015/11/15
程序作者： Allen
调试记录： exec P_EffectiveOrder 
************************************************************/
CREATE PROCEDURE [dbo].[P_EffectiveOrder]
	@OrderID nvarchar(64),
	@BillingCode nvarchar(50),
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)='',
	@Result int output
AS
	
begin tran

set @Result=0

--订单信息
declare @Err int=0,@Status int,@OrderAgentID nvarchar(64),@OwnerID nvarchar(64),@OrderCode nvarchar(50),@TotalMoney decimal(18,4),@CustomerID nvarchar(64)
select @Status=Status,@OrderAgentID=AgentID,@OwnerID=OwnerID,@OrderCode=OrderCode,@TotalMoney=TotalMoney,@CustomerID=CustomerID from Orders where OrderID=@OrderID and ClientID=@ClientID

if(@Status<>1)
begin
	rollback tran
	return
end

--代理商信息
declare @IsDefault int,@levelMoney decimal(18,4),@FreezeMoney  decimal(18,4)
select @IsDefault=IsDefault,@levelMoney=TotalIn-TotalOut-FreezeMoney,@FreezeMoney=FreezeMoney from Agents where AgentID=@OrderAgentID


--代理商订单信息
declare @AutoID int=1,@ProductID nvarchar(64),@ProductDetailID nvarchar(64),@Quantity int,@ProductAmount decimal(18,4),@ProductImage nvarchar(4000),@ImgS nvarchar(4000),
		@AgentOrderID nvarchar(64),@AgentOrderMoney decimal(18,4)=0,@LevelStock int, @ShortQuantity int

set @AgentOrderID=NEWID()

--产品信息
declare @Price decimal(18,4),@BigSmallMultiple int,@IsAllow int,@StockIn int,@SaleCount int,@LogicOut int


--汇总产品明细库存
select identity(int,1,1) as AutoID,ProductDetailID,ProductID,UnitID,UnitName,Quantity,Price,TotalMoney,Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID into #TempProducts 
from OrderDetail where OrderID=@OrderID

set @Err+=@@error

--默认代理商
if(@IsDefault=1)
begin
	while exists(select AutoID from #TempProducts where AutoID=@AutoID)
	begin
		--订单明细和产品信息
		select @ProductID=ProductID,@ProductDetailID=ProductDetailID,@Quantity=Quantity,@ProductAmount=TotalMoney,@ProductImage=ProductImage,@ImgS=ImgS from #TempProducts where AutoID=@AutoID
		if(@ImgS is null or @ImgS='')
		begin
			set @ImgS=@ProductImage
		end
		select @IsAllow=IsAllow,@BigSmallMultiple=BigSmallMultiple from Products where ProductID=@ProductID

		select @StockIn=StockIn,@SaleCount=SaleCount,@LogicOut=LogicOut,@Price=Price from ProductDetail where ProductDetailID=@ProductDetailID

		--库存不足
		if(@IsAllow=0 and @StockIn-@SaleCount<@Quantity)
		begin
			set @Result=2
			rollback tran
			return
		end

		--代理商库存处理
		if exists( select AutoID from AgentsStock where ProductDetailID=@ProductDetailID)
		begin
			Update AgentsStock set TotalInWay=TotalInWay+@Quantity,TotalOut=TotalOut+@Quantity where ProductDetailID=@ProductDetailID and AgentID=@OrderAgentID
			
			set @Err+=@@error
		end
		else
		begin
			insert into AgentsStock(ProductDetailID,ProductID,TotalIn,TotalInWay,TotalOut,AgentID,ClientID)
							values(@ProductDetailID,@ProductID,0,@Quantity,@Quantity,@OrderAgentID,@ClientID)
			set @Err+=@@error
		end
		
		--代理商库存流水
		insert into AgentsStream(ProductDetailID,ProductID,OrderID,OrderCode,OrderDate,Mark,Quantity,SurplusQuantity,AgentID,ClientID,ProductName,ProductCode,DetailsCode,ProductImage,Remark)
						select @ProductDetailID,@ProductID,@AgentOrderID,@OrderCode,CONVERT(varchar(100), GETDATE(), 112),0,@Quantity,0,@OrderAgentID,@ClientID,ProductName,ProductCode,DetailsCode,@ImgS,Remark from #TempProducts where AutoID=@AutoID

		insert into AgentsStream(ProductDetailID,ProductID,OrderID,OrderCode,OrderDate,Mark,Quantity,SurplusQuantity,AgentID,ClientID,ProductName,ProductCode,DetailsCode,ProductImage,Remark)
						select @ProductDetailID,@ProductID,@OrderID,@OrderCode,CONVERT(varchar(100), GETDATE(), 112),1,@Quantity,0,@OrderAgentID,@ClientID,ProductName,ProductCode,DetailsCode,@ImgS,Remark from #TempProducts where AutoID=@AutoID

		set @Err+=@@error

		--代理商采购明细
		insert into AgentsOrderDetail(OrderID,ProductDetailID,ProductID,UnitID,UnitName,IsBigUnit,Quantity,Price,TotalMoney,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage,Imgs)
							select @AgentOrderID,ProductDetailID,ProductID,UnitID,UnitName,0,Quantity,Price,TotalMoney,Remark,@ClientID,ProductName,ProductCode,DetailsCode,ProductImage,Imgs from #TempProducts where AutoID=@AutoID
		
		--产品库存处理
		update Products set LogicOut=LogicOut+@Quantity where ProductID=@ProductID

		update ProductDetail set LogicOut=LogicOut+@Quantity where ProductDetailID=@ProductDetailID

		set @Err+=@@error

		set @AgentOrderMoney+=@ProductAmount

		set @AutoID=@AutoID+1
	end
end
else --其他代理商待续
begin
	if(@AgentOrderMoney > @levelMoney)
	begin
		set @Result=3
		rollback tran
		return
	end
end

--代理商采购订单
insert into  AgentsOrders(OrderID,OrderCode,TypeID,Status,SendStatus,TotalMoney,CityCode,Address,PostalCode,Weight,OriginalID,OriginalCode,ExpressType,PersonName,MobileTele,Remark,AuditTime,CustomerID,CreateUserID,AgentID,ClientID)
select @AgentOrderID,OrderCode,TypeID,2,0,@AgentOrderMoney,CityCode,Address,PostalCode,Weight,@OrderID,OrderCode,ExpressType,PersonName,MobileTele,Remark,getdate(),CustomerID,@OperateID,AgentID,ClientID from Orders where OrderID=@OrderID

--代理商账户处理

update Agents set TotalOut=TotalOut+@AgentOrderMoney where AgentID=@OrderAgentID

insert into AgentsAccounts(AgentID,HappenMoney,EndMoney,Mark,SubjectID,Remark,CreateUserID,ClientID)
values(@OrderAgentID,@AgentOrderMoney,@levelMoney+@FreezeMoney-@AgentOrderMoney,1,1,'采购订单支出，订单号：'+@OrderCode,@OperateID,@ClientID)

set @Err+=@@error

--订单状态					
Update Orders set Status=2,AuditTime=getdate() where OrderID=@OrderID
set @Err+=@@error

insert into OrderUser(OrderID,UserID,Status,CreateTime,CreateUserID,AgentID,ClientID)
		 values(@OrderID,@OwnerID,1,getdate(),@OperateID,@OrderAgentID,@ClientID)
set @Err+=@@error

--生成账单
insert into Billing(BillingID,BillingCode,OrderID,OrderCode,TotalMoney,Status,PayStatus,InvoiceStatus,CreateUserID,AgentID,ClientID)
						values(NEWID(),@BillingCode,@OrderID,@OrderCode,@TotalMoney,1,0,0,@OwnerID,@OrderAgentID,@ClientID)

--处理客户阶段
update Customer set StageStatus=3,OrderTime=getdate(),OpportunityTime=isnull(OpportunityTime,getdate()) where CustomerID=@CustomerID and StageStatus<3

if(@Err>0)
begin
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end

 


 


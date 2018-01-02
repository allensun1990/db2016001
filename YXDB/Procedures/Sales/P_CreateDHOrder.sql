Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateDHOrder')
BEGIN
	DROP  Procedure  P_CreateDHOrder
END

GO
/***********************************************************
过程名称： P_CreateDHOrder
功能描述： 创建大货单
参数说明：	 
编写日期： 2016/3/7
程序作者： Allen
调试记录： exec P_CreateDHOrder 'a0020b2d-e2b2-4f7f-9774-628759f3513f',
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateDHOrder]
	@OriginalID nvarchar(64),
	@OrderID nvarchar(64),
	@Discount decimal(18,4)=1,
	@Price decimal(18,4)=0,
	@OrderCode nvarchar(50),
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64),
	@YXOrderID nvarchar(64),
	@YXClientID varchar(64),
	@PersonName varchar(64),
	@MobileTele varchar(64),
	@CityCode varchar(64),
	@Address varchar(64)
AS
	
declare @Status int,@OwnerID nvarchar(64),@ProcessID nvarchar(64),@CustomerID nvarchar(64),@TurnTimes int=0,@CategoryID nvarchar(64),@DYClientID nvarchar(64),@CustomerName varchar(64)

select @Status=Status,@OwnerID=OwnerID,@CustomerID=CustomerID,@CategoryID=BigCategoryID,@DYClientID=ClientID,@CustomerName=CustomerName from Orders where OrderID=@OriginalID

if(@Status<>3)
begin
	return
end

if(@DYClientID<>@ClientID)
begin
	set @CustomerID=''
	set @CustomerName=''
end

--取得默认流程
if(@OperateID<>'' and exists(select ProcessID from OrderProcess where  ClientID=@ClientID and ProcessType=2 and CategoryID=@CategoryID and OwnerID=@OperateID and status<>9 ))
begin
	select top 1 @ProcessID=ProcessID,@OwnerID=OwnerID from OrderProcess 
	where ClientID=@ClientID and ProcessType=2 and OwnerID=@OperateID  and CategoryID=@CategoryID and status<>9 order by IsDefault desc
end
else
begin
	select @ProcessID=ProcessID,@OwnerID=OwnerID from OrderProcess where ClientID=@ClientID and ProcessType=2 and CategoryID=@CategoryID and IsDefault=1 and status<>9
end

set @OwnerID= @OperateID

declare @SourceType int=2
if(@YXOrderID<>'')
begin
	set @SourceType=5
	SELECT  @CustomerID=CustomerID,@CustomerName=Name FROM Customer where ClientID=@ClientID and YXClientID=@YXClientID and Status<>9
	insert into Orders(OrderID,OrderCode,CategoryID,OrderType,SourceType,OrderStatus,Status,ProcessID,PlanPrice,FinalPrice,PlanQuantity,TaskCount,TaskOver,OrderImage,OriginalID,OriginalCode ,
						Price,CostPrice,ProfitPrice,TotalMoney,CityCode,Address,PersonName,MobileTele,Remark,CustomerID,OwnerID,CreateTime,ClientID,Platemaking,
						GoodsCode,Title,BigCategoryID,OrderImages,GoodsID,Discount,OriginalPrice,IntGoodsCode,GoodsName,TurnTimes,YXOrderID,CreateUserID,CustomerName)
	select @OrderID,@OrderCode,CategoryID,2,@SourceType,0,0,@ProcessID,PlanPrice,@Price,0,0,0,OrderImage,OrderID,OrderCode,
			0,CostPrice,ProfitPrice,0,@CityCode,@Address,@PersonName,@MobileTele,Remark,@CustomerID,@OwnerID,getdate(),@ClientID,Platemaking,
			GoodsCode,Title,BigCategoryID,OrderImages,GoodsID,@Discount,FinalPrice,IntGoodsCode,GoodsName,TurnTimes+1,@YXOrderID,@OperateID,@CustomerName from Orders where OrderID=@OriginalID
end 
else
begin
	insert into Orders(OrderID,OrderCode,CategoryID,OrderType,SourceType,OrderStatus,Status,ProcessID,PlanPrice,FinalPrice,PlanQuantity,TaskCount,TaskOver,OrderImage,OriginalID,OriginalCode ,
						Price,CostPrice,ProfitPrice,TotalMoney,CityCode,Address,PersonName,MobileTele,Remark,CustomerID,OwnerID,CreateTime,ClientID,Platemaking,
						GoodsCode,Title,BigCategoryID,OrderImages,GoodsID,Discount,OriginalPrice,IntGoodsCode,GoodsName,TurnTimes,YXOrderID,CreateUserID,CustomerName)
	select @OrderID,@OrderCode,CategoryID,2,@SourceType,0,0,@ProcessID,PlanPrice,@Price,0,0,0,OrderImage,OrderID,OrderCode,
			0,CostPrice,ProfitPrice,0,CityCode,Address,PersonName,MobileTele,Remark,@CustomerID,@OwnerID,getdate(),@ClientID,Platemaking,
			GoodsCode,Title,BigCategoryID,OrderImages,GoodsID,@Discount,FinalPrice,IntGoodsCode,GoodsName,TurnTimes+1,@YXOrderID,@OperateID,@CustomerName from Orders where OrderID=@OriginalID
end

--处理加工成本
insert into OrderCosts(OrderID,Price,Remark,Status,ClientID,ProcessID)
select @OrderID,Price,Remark,Status,ClientID,ProcessID from OrderCosts where OrderID=@OriginalID and status=1

Update Orders set TurnTimes=TurnTimes+1 where OrderID=@OriginalID

--处理客户需求单数
Update Customer set DemandCount=DemandCount+1 where CustomerID=@CustomerID
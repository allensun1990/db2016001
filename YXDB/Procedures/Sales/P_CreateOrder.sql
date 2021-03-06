﻿Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateOrder')
BEGIN
	DROP  Procedure  P_CreateOrder
END

GO
/***********************************************************
过程名称： P_CreateOrder
功能描述： 创建销售订单
参数说明：	 
编写日期： 2015/11/13
程序作者： Allen
调试记录： exec P_CreateOrder 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateOrder]
@OrderID nvarchar(64),
@OrderCode nvarchar(20),
@AliOrderCode nvarchar(100)='',
@GoodsCode nvarchar(50)='',
@ExpressCode nvarchar(50)='',
@Title nvarchar(200)='',
@SourceType int=1,
@OrderType int,
@BigCategoryID nvarchar(64)='',
@CategoryID nvarchar(64)='',
@CustomerID nvarchar(64)='',
@Name nvarchar(64)='',
@Mobile nvarchar(64)='',
@PlanPrice decimal(18,4)=0,
@PlanQuantity int=0,
@PlanTime nvarchar(50)='',
@OrderImg nvarchar(200)='',
@OrderImages nvarchar(4000)='',
@CityCode nvarchar(10)='',
@Address nvarchar(200)='',
@Remark nvarchar(4000)='',
@UserID nvarchar(64),
@ClientID nvarchar(64),
@Result int=0 output
AS

begin tran

set @Result=0

declare @Err int=0,@OwnerID nvarchar(64),@ProcessID nvarchar(64),@OriginalID nvarchar(64)='',@TurnTimes int=0,@CustomerName nvarchar(100)

if(@AliOrderCode<>'' and exists(select AutoID from Orders where AliOrderCode=@AliOrderCode))
begin
	set @Result=1
	rollback tran
	return
end

--处理客户需求单数
if(@CustomerID='' and @Mobile<>'' and @Mobile is not null and exists (select AutoID from Customer where MobilePhone=@Mobile and ClientID=@ClientID))
begin
	select @CustomerID=CustomerID,@CustomerName=Name from Customer where MobilePhone=@Mobile and ClientID=@ClientID
end
else if(@CustomerID is not null and @CustomerID<>'')
begin
	select @CustomerName=Name from Customer where CustomerID=@CustomerID
end

if exists (select AutoID from Orders where OrderCode=@OrderCode and ClientID=@ClientID)
begin
	set @OrderCode=@OrderCode+'1'
end

if(@BigCategoryID='' or @BigCategoryID is null)
	select top 1 @BigCategoryID=CategoryID from OrderCategory where ClientID=@ClientID

if(@UserID<>'' and exists(select ProcessID from OrderProcess where  ClientID=@ClientID and ProcessType=@OrderType and CategoryID=@BigCategoryID and OwnerID=@UserID and status<>9 ))
begin
	select top 1 @ProcessID=ProcessID,@OwnerID=OwnerID from OrderProcess 
	where ClientID=@ClientID and ProcessType=@OrderType and OwnerID=@UserID and CategoryID=@BigCategoryID   and status<>9 order by IsDefault desc
end
else
begin
	select @ProcessID=ProcessID,@OwnerID=OwnerID from OrderProcess where ClientID=@ClientID and ProcessType=@OrderType and CategoryID=@BigCategoryID and IsDefault=1 and status<>9
end

set @OwnerID=@UserID

--款号已存在打样单
if(@SourceType=3 and @GoodsCode<>'' and @OrderType=2 and exists(select AutoID from Orders where OrderType=1 and Status<>9 and GoodsCode=@GoodsCode and ClientID=@ClientID))
begin
	select @OriginalID=OrderID from Orders where OrderType=1 and Status=3 and GoodsCode=@GoodsCode and ClientID=@ClientID
end


set @PlanQuantity=@OrderType % 2

set @TurnTimes=(@OrderType+1) % 2

insert into Orders(OrderID,OrderCode,AliOrderCode,Status,CustomerID,OrderImage,OrderImages,PersonName,MobileTele,CityCode,Address,OwnerID,CreateUserID,OriginalID,PlanTime,
				ClientID,ProcessID,SourceType,OrderType,PlanPrice,Remark,PlanQuantity,BigCategoryID,CategoryID,GoodsCode,Title,ExpressCode,Discount,GoodsName,TurnTimes,CustomerName)
		values (@OrderID,@OrderCode,@AliOrderCode,0,@CustomerID,@OrderImg,@OrderImages,@Name,@Mobile,@CityCode,@Address,@OwnerID,@UserID,@OriginalID,@PlanTime,
				@ClientID,@ProcessID,@SourceType,@OrderType,@PlanPrice,@Remark,@PlanQuantity,@BigCategoryID,@CategoryID,@GoodsCode,@Title,@ExpressCode,1,@Title,@TurnTimes,@CustomerName)

--款号已存在打样单
if(@OriginalID<>'')
begin
	Update Orders set TurnTimes=TurnTimes+1 where OrderID=@OriginalID
	
	update o set OriginalCode=od.OrderCode,BigCategoryID=od.BigCategoryID,CategoryID=od.CategoryID,FinalPrice=od.FinalPrice,TotalMoney=0,IntGoodsCode=od.IntGoodsCode,GoodsName=od.GoodsName,
			 Price=0,ProfitPrice=od.ProfitPrice,CostPrice=od.CostPrice,Platemaking=od.Platemaking,GoodsID=od.GoodsID,OriginalPrice=od.FinalPrice,TurnTimes=od.TurnTimes
			 from Orders o join Orders od on o.OriginalID=od.OrderID where o.OrderID=@OrderID
end

Update Customer set DemandCount=DemandCount+1 where CustomerID=@CustomerID

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
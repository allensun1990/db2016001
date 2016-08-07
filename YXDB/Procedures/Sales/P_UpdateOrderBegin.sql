Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderBegin')
BEGIN
	DROP  Procedure  P_UpdateOrderBegin
END

GO
/***********************************************************
过程名称： P_UpdateOrderBegin
功能描述： 开始执行订单
参数说明：	 
编写日期： 2016/2/19
程序作者： Allen
调试记录： exec P_UpdateOrderBegin 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderBegin]
	@OrderID nvarchar(64),
	@PlanTime nvarchar(50)='',
	@DocCode nvarchar(50),
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)='',
	@ErrorInfo nvarchar(40) output
AS
	
begin tran

declare @Err int=0,@OldStatus int,@OwnerID nvarchar(64),@IsShow int=1,@OrderCode nvarchar(20), @ProcessID nvarchar(64), @OrderImg nvarchar(400),@CategoryID nvarchar(64),
@NewProcessID nvarchar(64),@OrderType int,@TaskCount int=0,@NewOrderID nvarchar(64),@Title nvarchar(200),@OrderOwnerID nvarchar(64),@OriginalID nvarchar(64),@AliOrderCode nvarchar(50),
@AliGoodsCode nvarchar(50),@IntGoodsCode nvarchar(100),@CustomerID nvarchar(64),@Status int


select @OldStatus=Status,@OrderCode=OrderCode,@OrderImg=OrderImage,@ProcessID=ProcessID,@OrderType=OrderType,@Title=GoodsName,@OrderOwnerID=OwnerID,@CategoryID=CategoryID,
@OriginalID=OriginalID ,@AliOrderCode=AliOrderCode,@AliGoodsCode=GoodsCode,@IntGoodsCode=IntGoodsCode,@CustomerID=CustomerID
from Orders where OrderID=@OrderID  and ClientID=@ClientID

if(@OldStatus=0 and  @OrderType=1)--开始打样
begin
	set @Status=1

	insert into OrderTask(TaskID,Title,ProductName,OrderType,TaskCode,OrderID,OrderImg,ProcessID,StageID,EndTime,OwnerID,Mark,Status,FinishStatus,CreateTime,CreateUserID,ClientID,Sort,OrderCode,MaxHours)
	select NEWID(),StageName,@Title,@OrderType,@OrderCode+convert(nvarchar(2),Sort),@OrderID,@OrderImg,ProcessID,StageID,null,OwnerID,Mark,1,0,GETDATE(),OwnerID,ClientID,Sort,@OrderCode,MaxHours from OrderStage
	where ProcessID =@ProcessID and status<>9
	order by Sort

	select @TaskCount=count(0) from OrderStage where ProcessID =@ProcessID and status<>9

	Update Orders set Status=@Status,TaskCount=@TaskCount,OrderTime=GetDate(),OrderStatus=1,PlanTime=@PlanTime where OrderID=@OrderID

	--处理客户订单数
	Update Customer set DemandCount=DemandCount-1,DYCount=DYCount+1 where CustomerID=@CustomerID

	set @Err+=@@error
end 
else if(@OldStatus=0 and @OrderType=2) --开始生产
begin
	set @Status=5

	insert into OrderTask(TaskID,Title,ProductName,OrderType,TaskCode,OrderID,OrderImg,ProcessID,StageID,EndTime,OwnerID,Mark,Status,FinishStatus,CreateTime,CreateUserID,ClientID,Sort,OrderCode,MaxHours)
	select NEWID(),StageName,@Title,@OrderType,@OrderCode+convert(nvarchar(2),Sort),@OrderID,@OrderImg,ProcessID,StageID,null,OwnerID,Mark,1,0,GETDATE(),OwnerID,ClientID,Sort,@OrderCode,MaxHours from OrderStage
	where ProcessID =@ProcessID and status<>9
	order by Sort

	select @TaskCount=count(0) from OrderStage where ProcessID =@ProcessID and status<>9

	if(@OriginalID is null or @OriginalID='')
	begin
		
		declare @DYOrderID nvarchar(64)=NewID()

		insert into Orders(OrderID,OrderCode,CategoryID,OrderType,SourceType,OrderStatus,Status,ProcessID,PlanPrice,FinalPrice,PlanQuantity,TaskCount,TaskOver,OrderImage,OriginalID,OriginalCode ,
					Price,CostPrice,ProfitPrice,TotalMoney,CityCode,Address,PersonName,MobileTele,Remark,CustomerID,OwnerID,CreateTime,ClientID,Platemaking,
					GoodsCode,Title,BigCategoryID,OrderImages,GoodsID,Discount,OriginalPrice,IntGoodsCode,GoodsName,TurnTimes,YXOrderID,CreateUserID)
		select @DYOrderID,@DocCode,CategoryID,1,4,1,2,'',FinalPrice,FinalPrice,1,1,1,OrderImage,'','',
		Price,CostPrice,ProfitPrice,0,CityCode,Address,PersonName,MobileTele,Remark,CustomerID,OwnerID,getdate(),ClientID,Platemaking,
		GoodsCode,Title,BigCategoryID,OrderImages,'',1,FinalPrice,IntGoodsCode,GoodsName,1,'','' from Orders where OrderID=@OrderID

		Update Orders set Status=@Status,OrderTime=GetDate(),TaskCount=@TaskCount,OrderStatus=1,PlanTime=@PlanTime,OriginalID=@DYOrderID,OriginalCode=@DocCode where OrderID=@OrderID

		Update Customer set DemandCount=DemandCount-1,DHCount=DHCount+1,DYCount=DYCount+1 where CustomerID=@CustomerID
	end
	else
	begin

		Update Orders set Status=@Status,OrderTime=GetDate(),TaskCount=@TaskCount,OrderStatus=1,PlanTime=@PlanTime where OrderID=@OrderID

		Update Customer set DemandCount=DemandCount-1,DHCount=DHCount+1 where CustomerID=@CustomerID
	end
	set @Err+=@@error
end
else
begin
	set @ErrorInfo='无效的操作'
	rollback tran
	return
end
	

Insert into OrderStatusLog(OrderID,Status,CreateUserID) values(@OrderID,@Status,@OperateID)
set @Err+=@@error

--通知阿里待处理日志
if(@AliOrderCode is not null and @AliOrderCode<>'')
begin
	insert into AliOrderUpdateLog(LogID,OrderID,AliOrderCode,OrderType,Status,OrderStatus,OrderPrice,FailCount,UpdateTime,CreateTime,Remark,ClientID)
	values(NEWID(),@OrderID,@AliOrderCode,@OrderType,0,@Status,0,0,getdate(),getdate(),'',@ClientID)
	set @Err+=@@error
end

if(@Err>0)
begin
	set @ErrorInfo='系统异常，请稍后重试'
	rollback tran
end 
else
begin
	set @ErrorInfo=''
	commit tran
end

 


 


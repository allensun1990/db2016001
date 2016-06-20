Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderStatus')
BEGIN
	DROP  Procedure  P_UpdateOrderStatus
END

GO
/***********************************************************
过程名称： P_UpdateOrderStatus
功能描述： 更换订单状态
参数说明：	 
编写日期： 2016/2/19
程序作者： Allen
调试记录： exec P_UpdateOrderStatus 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderStatus]
	@OrderID nvarchar(64),
	@Status int,
	@PlanTime nvarchar(50)='',
	@FinalPrice decimal(18,4)=0,
	@DocCode nvarchar(50),
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)='',
	@ErrorInfo nvarchar(40) output
AS
	
begin tran

declare @Err int=0,@OldStatus int,@OwnerID nvarchar(64),@IsShow int=1,@OrderCode nvarchar(20), @ProcessID nvarchar(64), @OrderImg nvarchar(400),@CategoryID nvarchar(64),
@NewProcessID nvarchar(64),@OrderType int,@TaskCount int=0,@NewOrderID nvarchar(64),@Title nvarchar(200),@OrderOwnerID nvarchar(64),@OriginalID nvarchar(64),@AliOrderCode nvarchar(50),
@AliGoodsCode nvarchar(50),@IntGoodsCode nvarchar(100),@CustomerID nvarchar(64)


select @OldStatus=Status,@OrderCode=OrderCode,@OrderImg=OrderImage,@ProcessID=ProcessID,@OrderType=OrderType,@Title=GoodsName,@OrderOwnerID=OwnerID,@CategoryID=CategoryID,
@OriginalID=OriginalID ,@AliOrderCode=AliOrderCode,@AliGoodsCode=GoodsCode,@IntGoodsCode=IntGoodsCode,@CustomerID=CustomerID
from Orders where OrderID=@OrderID  and ClientID=@ClientID

--if(@OperateID<>@OrderOwnerID and not exists(select AutoID from OrderProcess where ProcessID=@ProcessID and OwnerID=@OperateID))
--begin
--	set @ErrorInfo='您不是订单负责人，不能进行操作'
--	rollback tran
--	return
--end


if(@OldStatus=0 and @Status=1 and @OrderType=1)--开始打样
begin
	insert into OrderTask(TaskID,Title,ProductName,OrderType,TaskCode,OrderID,OrderImg,ProcessID,StageID,EndTime,OwnerID,Mark,Status,FinishStatus,CreateTime,CreateUserID,ClientID,AgentID,Sort,OrderCode,MaxHours)
	select NEWID(),StageName,@Title,@OrderType,@OrderCode+convert(nvarchar(2),Sort),@OrderID,@OrderImg,ProcessID,StageID,null,OwnerID,Mark,1,0,GETDATE(),OwnerID,ClientID,@AgentID,Sort,@OrderCode,MaxHours from OrderStage
	where ProcessID =@ProcessID and status<>9
	order by Sort

	select @TaskCount=count(0) from OrderStage where ProcessID =@ProcessID and status<>9

	Update Orders set Status=@Status,TaskCount=@TaskCount,OrderTime=GetDate(),OrderStatus=1,PlanTime=@PlanTime where OrderID=@OrderID

	--处理客户订单数
	Update Customer set DemandCount=DemandCount-1,DYCount=DYCount+1 where CustomerID=@CustomerID

	set @Err+=@@error
end 
else if(@Status=2 and @OldStatus=1) --打样完成
begin
	Update Orders set Status=@Status where OrderID=@OrderID

	set @Err+=@@error
end
else if(@Status=3) --合价完成
begin
	
	if exists(select AutoID from OrderTask where OrderID=@OrderID and FinishStatus<>2)
	begin
		set @ErrorInfo='阶段任务尚未全部完成，不能完成合价'
		rollback tran
		return
	end

	declare @GoodsID nvarchar(64)=NewID()

	Update Orders set Status=@Status,FinalPrice=@FinalPrice,TotalMoney=@FinalPrice,EndTime=getdate(),GoodsID=@GoodsID,OrderStatus=2 where OrderID=@OrderID and Status=2 and OrderType=1

	insert into Goods(GoodsID,GoodsName,AliGoodsCode,GoodsCode,CategoryID,Price,ClientID) values( @GoodsID,@Title,@AliGoodsCode,@IntGoodsCode,@CategoryID,@FinalPrice,@ClientID ) 

	set @Err+=@@error
end
else if(@Status=5 and @OldStatus=4 and @OrderType=2) --开始生产
begin
	
	if(@OriginalID is null or @OriginalID='')
	begin
		set @ErrorInfo='大货单尚未绑定打样单，不能进行生产'
		rollback tran
		return
	end

	insert into OrderTask(TaskID,Title,ProductName,OrderType,TaskCode,OrderID,OrderImg,ProcessID,StageID,EndTime,OwnerID,Mark,Status,FinishStatus,CreateTime,CreateUserID,ClientID,AgentID,Sort,OrderCode,MaxHours)
	select NEWID(),StageName,@Title,@OrderType,@OrderCode+convert(nvarchar(2),Sort),@OrderID,@OrderImg,ProcessID,StageID,null,OwnerID,Mark,1,0,GETDATE(),OwnerID,ClientID,@AgentID,Sort,@OrderCode,MaxHours from OrderStage
	where ProcessID =@ProcessID and status<>9
	order by Sort

	select @TaskCount=count(0) from OrderStage where ProcessID =@ProcessID and status<>9

	Update Orders set Status=@Status,OrderTime=GetDate(),TaskCount=@TaskCount,OrderStatus=1,PlanTime=@PlanTime where OrderID=@OrderID

	--处理客户订单数
	Update Customer set DemandCount=DemandCount-1,DHCount=DHCount+1 where CustomerID=@CustomerID

	set @Err+=@@error
end
else if(@Status=7 and @OldStatus=6) --交易结束
begin

	if exists(select AutoID from OrderTask where OrderID=@OrderID and FinishStatus<>2)
	begin
		set @ErrorInfo='阶段任务尚未全部完成，不能交易结束'
		rollback tran
		return
	end

	Update Orders set Status=@Status,EndTime=getdate(),OrderStatus=2 where OrderID=@OrderID

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
	insert into AliOrderUpdateLog(LogID,OrderID,AliOrderCode,OrderType,Status,OrderStatus,OrderPrice,FailCount,UpdateTime,CreateTime,Remark,AgentID,ClientID)
	values(NEWID(),@OrderID,@AliOrderCode,@OrderType,0,@Status,@FinalPrice,0,getdate(),getdate(),'',@ClientID,@ClientID)
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

 


 


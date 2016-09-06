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
	@ClientID nvarchar(64)='',
	@ErrorInfo nvarchar(40) output
AS
	
begin tran

declare @Err int=0,@OldStatus int,@OwnerID nvarchar(64),@OrderCode nvarchar(20),@OrderType int,@OriginalID nvarchar(64),@AliOrderCode nvarchar(50),
@AliGoodsCode nvarchar(50),@IntGoodsCode nvarchar(100),@GoodsName nvarchar(100),@CategoryID nvarchar(64), @GoodsID nvarchar(64),@OrderClientID nvarchar(64)


select @OldStatus=Status,@OrderCode=OrderCode,@OrderType=OrderType,@OriginalID=OriginalID ,@AliOrderCode=AliOrderCode,@AliGoodsCode=GoodsCode,
@IntGoodsCode=IntGoodsCode,@GoodsName=GoodsName,@CategoryID=CategoryID,@GoodsID=GoodsID,@OrderClientID=ClientID
from Orders where OrderID=@OrderID and (ClientID=@ClientID or EntrustClientID=@ClientID)

if(@Status=2 and @OldStatus=1) --打样完成
begin
	Update Orders set Status=@Status where OrderID=@OrderID

	set @Err+=@@error
end
else if(@Status=3) --合价完成
begin
	if exists(select AutoID from OrderTask where OrderID=@OrderID and FinishStatus<>2)
	begin
		set @ErrorInfo='任务尚未全部完成，不能完成核价'
		rollback tran
		return
	end

	if(@GoodsID is null or @GoodsID='')
	begin
		set @GoodsID=NEWID()
		insert into Goods(GoodsID,GoodsName,GoodsCode,CategoryID,Price,ClientID) values(@GoodsID,@GoodsName,@IntGoodsCode,@CategoryID,@FinalPrice,@OrderClientID) 
	end
	else
	begin
		Update Goods set Price=@FinalPrice where GoodsID=@GoodsID
	end

	Update Orders set Status=@Status,FinalPrice=@FinalPrice,EndTime=getdate(),GoodsID=@GoodsID,OrderStatus=2 where OrderID=@OrderID and Status=2 and OrderType=1

	set @Err+=@@error
end
else if(@Status=7 and @OldStatus=6) --交易结束
begin

	if exists(select AutoID from OrderTask where OrderID=@OrderID and FinishStatus<>2)
	begin
		set @ErrorInfo='任务尚未全部完成，不能结束交易'
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
	insert into AliOrderUpdateLog(LogID,OrderID,AliOrderCode,OrderType,Status,OrderStatus,OrderPrice,FailCount,UpdateTime,CreateTime,Remark,ClientID)
	values(NEWID(),@OrderID,@AliOrderCode,@OrderType,0,@Status,@FinalPrice,0,getdate(),getdate(),'',@ClientID)
	set @Err+=@@error
end

if(@Err>0)
begin
	set @ErrorInfo='操作失败，请稍后重试'
	rollback tran
end 
else
begin
	set @ErrorInfo=''
	commit tran
end

 


 


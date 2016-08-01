Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_FinishTask')
BEGIN
	DROP  Procedure  P_FinishTask
END

GO
/***********************************************************
过程名称： P_FinishTask
功能描述： 标记订单任务已完成
参数说明：	 
编写日期： 2016/2/18
程序作者： MU
调试记录： declare @Result exec P_FinishTask @TaskID='0B9E8812-2F90-4C5F-B879-860E54D81C39',@UserID='',@Result=@Result output
************************************************************/
CREATE PROCEDURE [dbo].P_FinishTask
@TaskID nvarchar(64),
@UserID nvarchar(64),
@Result int output --0：失败，1：成功，2: 有前面阶段任务未完成,3:没有权限；4：任务没有接受，不能设置完成;5.任务有未完成步骤
as
	declare @IsShow int
	declare @OrderID nvarchar(64)
	declare @ClientID nvarchar(64)
	declare @OrderType int
	declare @Sort int
	declare @FinishStatus int
	declare @Mark int
	declare @ProcessID nvarchar(64)
	declare @OwnerID nvarchar(64)

	set @IsShow=0
	set @Result=0

	--任务未接受
	if(exists(select taskid from ordertask where taskid=@TaskID and finishstatus=0))
	begin
		set @Result=4
		return
	end

	select @OrderID=OrderID,@OrderType=OrderType,@ProcessID=ProcessID,@Sort=Sort,@OwnerID=OwnerID,@Mark=Mark,@FinishStatus=FinishStatus,@ClientID=ClientID 
	from OrderTask where TaskID=@TaskID

	--任务已标记完成
	if(@FinishStatus=2)
	begin
		return
	end

	--任务不是负责人操作
	if(@OwnerID<>@UserID)
	begin
		set @Result=3
		return
	end

	begin tran
	declare @Err int=0
	--更新任务进行状态为完成且加锁
	update OrderTask set FinishStatus=2,CompleteTime=GETDATE(),LockStatus=1 where TaskID=@TaskID
	set @Err+=@@ERROR

	--更新任务对应的订单的任务完成数
	update Orders set TaskOver=TaskOver+1 where OrderID=@OrderID
	set @Err+=@@ERROR

	--若订单对应的任务全部完成 自动更改订单状态
	if(not exists( select taskid from ordertask where orderid=@OrderID and status<>8 and FinishStatus<>2 ))
	begin
		declare @AliOrderCode nvarchar(50)

		select @AliOrderCode=AliOrderCode from Orders where OrderID=@OrderID  and ClientID=@ClientID
		if(@OrderType=1)
		begin
			update orders set status=2 where orderid=@OrderID

			Insert into OrderStatusLog(OrderID,Status,CreateUserID) values(@OrderID,2,@UserID)

			--通知阿里待处理日志
			if(@AliOrderCode is not null and @AliOrderCode<>'')
			begin
				insert into AliOrderUpdateLog(LogID,OrderID,AliOrderCode,OrderType,Status,OrderStatus,OrderPrice,FailCount,UpdateTime,CreateTime,Remark,ClientID)
				values(NEWID(),@OrderID,@AliOrderCode,1,0,2,0,0,getdate(),getdate(),'完成打样',@ClientID)
				set @Err+=@@error
			end
			set @Err+=@@ERROR
		end
		else
		begin
			update orders set status=6 where orderid=@OrderID
			set @Err+=@@ERROR

			Insert into OrderStatusLog(OrderID,Status,CreateUserID) values(@OrderID,6,@UserID)

			--通知阿里待处理日志
			if(@AliOrderCode is not null and @AliOrderCode<>'')
			begin
				insert into AliOrderUpdateLog(LogID,OrderID,AliOrderCode,OrderType,Status,OrderStatus,OrderPrice,FailCount,UpdateTime,CreateTime,Remark,ClientID)
				values(NEWID(),@OrderID,@AliOrderCode,2,0,6,0,0,getdate(),getdate(),'大货单生产完成，发货完毕',@ClientID)
				set @Err+=@@error
			end
		end
	end

	if(@Err>0)
	begin
		rollback tran
	end 
	else
	begin
		set @Result=1
		commit tran
	end

	
		 






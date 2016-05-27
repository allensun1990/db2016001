Use IntFactory_dev
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

	select @OrderID=OrderID,@ProcessID=ProcessID,@Sort=Sort,@OwnerID=OwnerID,@Mark=Mark,@FinishStatus=FinishStatus from OrderTask where TaskID=@TaskID

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

	--任务标记为制版时 制版信息为空；任务标记为材料时 订单没有产品详情
	if(@Mark=12)
	begin
		if(exists( select orderid from orders where orderid=@OrderID and ( (cast(Platemaking as varchar(max))='' or cast(Platemaking as varchar(max)) is  null) ) ) )
		begin
			set @Result=5;
			return;
		end
	end
	else if(@Mark=11 or @Mark=21)
	begin
		if(not exists( select AutoID from OrderDetail where orderid=@OrderID) )
		begin
			set @Result=5;
			return;
		end
	end

	--更新任务进行状态为完成且加锁
	update OrderTask set FinishStatus=2,CompleteTime=GETDATE(),LockStatus=1 where TaskID=@TaskID

	--更新任务对应的订单的任务完成数
	update Orders set TaskOver=TaskOver+1 where OrderID=@OrderID


	--update OrderTask set Status=1 
	--	where TaskID in
	--	(
	--		select top 1 TaskID from OrderTask where OrderID=@OrderID and ProcessID=@ProcessID and Status<>9 and  Sort>@Sort order by Sort asc
	--	)

	set @Result=1
		 






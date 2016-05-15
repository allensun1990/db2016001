Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateTask')
BEGIN
	DROP  Procedure  P_CreateTask
END

GO
/***********************************************************
过程名称： P_CreateTask
功能描述： 新增订单任务
参数说明：	 
编写日期： 2016/2/8
程序作者： MU
调试记录： exec P_CreateTask @OrderID='29cde542-7c1d-4902-a068-f24099d32412'
************************************************************/
CREATE PROCEDURE [dbo].P_CreateTask
@OrderID nvarchar(64)=''
as
	declare @OrderCode nvarchar(20)
	declare @ProcessID nvarchar(64)
	declare @OrderImg nvarchar(400)
	declare @AgentID nvarchar(64)
	declare @IsShow int

	set @IsShow=1

	select @OrderCode=OrderCode,@OrderImg=OrderImage,@ProcessID=ProcessID,@AgentID=AgentID from Orders where  OrderID=@OrderID 

	if(exists(select TaskID from OrderTask where OrderID=@OrderID and Status<>9 and ProcessID=@ProcessID))
	begin
		return
	end

	

	if(@IsShow=1)
	begin
		insert into OrderTask(TaskID,OrderID,OrderImg,ProcessID,StageID,EndTime,OwnerID,Status,FinishStatus,CreateTime,CreateUserID,ClientID,AgentID,Sort,OrderCode,Title)
		select NEWID(),@OrderID,@OrderImg,ProcessID,StageID,null,OwnerID,
		1,0,GETDATE(),OwnerID,ClientID,@AgentID,Sort,@OrderCode,StageName from OrderStage
		where ProcessID =@ProcessID and status<>9
		order by Sort
	end
	else
	begin
		insert into OrderTask(TaskID,OrderID,OrderImg,ProcessID,StageID,EndTime,OwnerID,Status,FinishStatus,CreateTime,CreateUserID,ClientID,AgentID,Sort,OrderCode,Title)
		select NEWID(),@OrderID,@OrderImg,ProcessID,StageID,null,OwnerID,
		0,0,GETDATE(),OwnerID,ClientID,@AgentID,Sort,@OrderCode,StageName from OrderStage
		where ProcessID =@ProcessID and status<>9
		order by Sort

		update OrderTask set Status=1 
		where TaskID in
		(
			select top 1 TaskID from OrderTask where OrderID=@OrderID and ProcessID=@ProcessID and Status<>9  order by Sort asc
		)
	end
		 






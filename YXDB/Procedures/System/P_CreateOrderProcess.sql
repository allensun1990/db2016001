Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateOrderProcess')
BEGIN
	DROP  Procedure  P_CreateOrderProcess
END

GO
/***********************************************************
过程名称： P_CreateOrderProcess
功能描述： 添加阶段流程
参数说明：	 
编写日期： 2016/1/29
程序作者： Allen
调试记录： exec P_CreateOrderProcess 
************************************************************/
CREATE PROCEDURE [dbo].P_CreateOrderProcess
@ProcessID nvarchar(64),
@ProcessName nvarchar(100),
@ProcessType int,
@CategoryID nvarchar(64),
@IsDefault int=0,
@PlanDays int=7,
@OwnerID nvarchar(64)='',
@UserID nvarchar(64)='',
@ClientID nvarchar(64)='',
@OtherProcessID nvarchar(64) output
AS

begin tran


declare @Err int=0,@Name nvarchar(64)
 
 set @OtherProcessID=''

if exists(select CategoryID from OrderCategory where ClientID=@ClientID and CategoryID=@CategoryID)
begin
	Insert into OrderProcess(ProcessID,ProcessName,ProcessType,CategoryID,IsDefault,Status,PlanDays,OwnerID,CreateUserID,ClientID)
	values(@ProcessID,@ProcessName,@ProcessType,@CategoryID,0,1,@PlanDays,@OwnerID,@UserID,@ClientID)

	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
		select NEWID(),Name,@ProcessID,Sort,1,Mark,'',@UserID,@UserID,@ClientID from CategoryItems 
		where CategoryID=@CategoryID and OrderType=@ProcessType and Type=2
end
else
begin
	
	select @Name=Name from ProcessCategory where CategoryID=@CategoryID
	if (@ProcessType=1)
	begin
		set @Name=@Name+'大货流程'
	end
	else
	begin
		set @Name=@Name+'打样流程'
	end

	Insert into OrderCategory(CategoryID,Layers,ClientID,PID) values(@CategoryID,1,@ClientID,'')

	Insert into OrderProcess(ProcessID,ProcessName,ProcessType,CategoryID,IsDefault,Status,PlanDays,OwnerID,CreateUserID,ClientID)
	values(@ProcessID,@ProcessName,@ProcessType,@CategoryID,1,1,@PlanDays,@OwnerID,@UserID,@ClientID)

	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
		select NEWID(),Name,@ProcessID,Sort,1,Mark,'',@UserID,@UserID,@ClientID from CategoryItems 
		where CategoryID=@CategoryID and OrderType=@ProcessType and Type=2

	--另一类型流程
    set @OtherProcessID = NewID()

	Insert into OrderProcess(ProcessID,ProcessName,ProcessType,CategoryID,IsDefault,Status,PlanDays,OwnerID,CreateUserID,ClientID)
	values(@OtherProcessID,@Name,@ProcessType%2+1,@CategoryID,1,1,@PlanDays,@OwnerID,@UserID,@ClientID)

	set @Err+=@@error

	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
		select NEWID(),Name,@OtherProcessID,Sort,1,Mark,'',@UserID,@UserID,@ClientID from CategoryItems 
		where CategoryID=@CategoryID and OrderType=@ProcessType%2+1 and Type=2

end

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end
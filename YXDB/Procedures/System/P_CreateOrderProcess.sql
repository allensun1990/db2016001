Use IntFactory_dev
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
@CategoryType int=1,
@IsDefault int=0,
@PlanDays int=7,
@OwnerID nvarchar(64)='',
@UserID nvarchar(64)='',
@ClientID nvarchar(64)=''
AS

begin tran


declare @Err int=0
 
if(@IsDefault=1)
begin
	Update OrderProcess set IsDefault=0 where IsDefault=1 and ClientID=@ClientID and ProcessType=@ProcessType
	set @Err+=@@error
end

Insert into OrderProcess(ProcessID,ProcessName,ProcessType,CategoryType,IsDefault,Status,PlanDays,OwnerID,CreateUserID,ClientID)
values(@ProcessID,@ProcessName,@ProcessType,@CategoryType,@IsDefault,1,@PlanDays,@OwnerID,@UserID,@ClientID)

--打样
if(@ProcessType=1 and @CategoryType=1)
begin
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'面料/辅料',@ProcessID,1,1,11,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'制版',@ProcessID,2,1,12,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'做样衣',@ProcessID,3,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'审版',@ProcessID,4,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'核价',@ProcessID,5,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'发货',@ProcessID,6,1,15,'',@UserID,@UserID,@ClientID)
end
else if(@ProcessType=1 and @CategoryType=2)
begin
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'纱线/辅料',@ProcessID,1,1,11,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'制版/工艺',@ProcessID,2,1,12,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'织片',@ProcessID,3,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'套口/缝盘',@ProcessID,4,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'审版',@ProcessID,5,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'核价',@ProcessID,6,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'发货',@ProcessID,7,1,15,'',@UserID,@UserID,@ClientID)
end
else if(@ProcessType=2 and @CategoryType=1)
begin
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'推码/工艺单',@ProcessID,1,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'面料/辅料',@ProcessID,2,1,21,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'裁剪',@ProcessID,3,1,23,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'车缝',@ProcessID,4,1,24,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'后整',@ProcessID,5,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'品控',@ProcessID,6,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'发货',@ProcessID,7,1,25,'',@UserID,@UserID,@ClientID)
end
else if(@ProcessType=2 and @CategoryType=2)
begin
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'推码/工艺单',@ProcessID,1,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'纱线/辅料',@ProcessID,2,1,21,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'织片',@ProcessID,3,1,23,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'套口/缝盘',@ProcessID,4,1,24,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'品控',@ProcessID,5,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'发货',@ProcessID,6,1,25,'',@UserID,@UserID,@ClientID)
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
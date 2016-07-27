Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_SetClientProcess')
BEGIN
	DROP  Procedure  M_SetClientProcess
END

GO
/***********************************************************
过程名称： M_SetClientProcess
功能描述： 初始化流程
参数说明：	 
编写日期： 2016/5/20
程序作者： Allen
调试记录： exec M_SetClientProcess 
************************************************************/
CREATE PROCEDURE [dbo].[M_SetClientProcess]
@Type int,
@UserID nvarchar(64),
@ClientID nvarchar(64),
@Result int output --0：失败，1：成功
AS

begin tran

set @Result=0

declare @Err int=0,@ProcessIDDY nvarchar(64),@ProcessIDDH nvarchar(64)

select @ProcessIDDY=NEWID(),@ProcessIDDH=NEWID()

--初始化状态
if not exists(select AutoID from Clients where GuideStep=1)
begin
	set @Result=1
	rollback tran
	return
end

set @Err+=@@error

if(@Type=1)
begin
	--订单打样流程
	Insert into OrderProcess(ProcessID,ProcessName,ProcessType,CategoryType,IsDefault,Status,PlanDays,OwnerID,CreateUserID,ClientID)
	values(@ProcessIDDY,'梭织打样流程',1,1,1,1,0,@UserID,@UserID,@ClientID)

	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'面料/辅料',@ProcessIDDY,1,1,11,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'制版',@ProcessIDDY,2,1,12,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'做样衣',@ProcessIDDY,3,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'审版',@ProcessIDDY,4,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'加工成本',@ProcessIDDY,5,1,16,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'发货',@ProcessIDDY,6,1,15,'',@UserID,@UserID,@ClientID)

	--订单大货流程
	Insert into OrderProcess(ProcessID,ProcessName,ProcessType,CategoryType,IsDefault,Status,PlanDays,OwnerID,CreateUserID,ClientID)
	values(@ProcessIDDH,'梭织大货流程',2,1,1,1,0,@UserID,@UserID,@ClientID)

	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'推码/工艺单',@ProcessIDDH,1,1,22,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'面料/辅料',@ProcessIDDH,2,1,21,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'裁剪',@ProcessIDDH,3,1,23,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'车缝',@ProcessIDDH,4,1,24,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'后整',@ProcessIDDH,5,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'品控',@ProcessIDDH,6,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'发货',@ProcessIDDH,7,1,25,'',@UserID,@UserID,@ClientID)
end
else if(@Type=2)
begin
	--订单打样流程
	Insert into OrderProcess(ProcessID,ProcessName,ProcessType,CategoryType,IsDefault,Status,PlanDays,OwnerID,CreateUserID,ClientID)
	values(@ProcessIDDY,'毛织打样流程',1,1,1,1,0,@UserID,@UserID,@ClientID)

	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'纱线/辅料',@ProcessIDDY,1,1,11,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'制版/工艺',@ProcessIDDY,2,1,12,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'织片',@ProcessIDDY,3,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'套口/缝盘',@ProcessIDDY,4,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'审版',@ProcessIDDY,5,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'核价',@ProcessIDDY,6,1,16,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'发货',@ProcessIDDY,7,1,15,'',@UserID,@UserID,@ClientID)

	--订单大货流程
	Insert into OrderProcess(ProcessID,ProcessName,ProcessType,CategoryType,IsDefault,Status,PlanDays,OwnerID,CreateUserID,ClientID)
	values(@ProcessIDDH,'毛织大货流程',2,1,1,1,0,@UserID,@UserID,@ClientID)

	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'推码/工艺单',@ProcessIDDH,1,1,22,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'纱线/辅料',@ProcessIDDH,2,1,21,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'织片',@ProcessIDDH,3,1,23,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'套口/缝盘',@ProcessIDDH,4,1,24,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'品控',@ProcessIDDH,5,1,0,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'发货',@ProcessIDDH,6,1,25,'',@UserID,@UserID,@ClientID)

end

Update Clients set GuideStep=2 where ClientID=@ClientID

set @Err+=@@error

if(@Err>0)
begin
	set @Result=0
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end
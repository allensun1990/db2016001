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

Insert into OrderProcess(ProcessID,ProcessName,ProcessType,IsDefault,Status,PlanDays,OwnerID,CreateUserID,ClientID)
values(@ProcessID,@ProcessName,@ProcessType,@IsDefault,1,@PlanDays,@OwnerID,@UserID,@ClientID)

--打样
if(@ProcessType=1)
begin
	insert into [OrderStage] (StageID,StageName,ProcessID,Probability,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'材料',@ProcessID,0,1,1,1,'',@UserID,@UserID,@ClientID)
	insert into [OrderStage] (StageID,StageName,ProcessID,Probability,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'制版',@ProcessID,0,2,1,2,'',@UserID,@UserID,@ClientID)
end
else
begin
	insert into [OrderStage] (StageID,StageName,ProcessID,Probability,Sort,Status,Mark,PID,OwnerID,CreateUserID,ClientID) 
	values (NEWID(),'材料',@ProcessID,0,1,1,3,'',@UserID,@UserID,@ClientID)
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
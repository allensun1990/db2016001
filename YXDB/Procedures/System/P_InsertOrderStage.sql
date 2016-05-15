Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_InsertOrderStage')
BEGIN
	DROP  Procedure  P_InsertOrderStage
END

GO
/***********************************************************
过程名称： P_InsertOrderStage
功能描述： 添加订单阶段状态
参数说明：	 
编写日期： 2016/1/30
程序作者： Allen
调试记录： exec P_InsertOrderStage 
************************************************************/
CREATE PROCEDURE [dbo].[P_InsertOrderStage]
@StageID nvarchar(64),
@StageName nvarchar(100),
@Sort int=1,
@PID nvarchar(64)='',
@ProcessID nvarchar(64)='',
@CreateUserID nvarchar(64)='',
@ClientID nvarchar(64)='',
@Result int output --0：失败，1：成功，2 编码已存在
AS

begin tran

set @Result=0

declare @Err int=0

update  OrderStage set Sort=Sort+1 where ProcessID=@ProcessID and Sort>=@Sort

insert into OrderStage(StageID,StageName,Sort,Status,Mark,PID,CreateUserID,ClientID,ProcessID,OwnerID)
                                values(@StageID,@StageName,@Sort,1,0,@PID,@CreateUserID,@ClientID,@ProcessID,@CreateUserID)
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
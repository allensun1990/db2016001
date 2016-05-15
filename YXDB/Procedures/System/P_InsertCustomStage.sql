Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_InsertCustomStage')
BEGIN
	DROP  Procedure  P_InsertCustomStage
END

GO
/***********************************************************
过程名称： P_InsertCustomStage
功能描述： 添加客户阶段
参数说明：	 
编写日期： 2015/10/28
程序作者： Allen
调试记录： exec P_InsertCustomStage 
************************************************************/
CREATE PROCEDURE [dbo].[P_InsertCustomStage]
@StageID nvarchar(64),
@StageName nvarchar(100),
@Sort int=1,
@PID nvarchar(64)='',
@CreateUserID nvarchar(64)='',
@ClientID nvarchar(64)='',
@Result int output --0：失败，1：成功，2 编码已存在
AS

begin tran

set @Result=0

declare @Err int=0

update  CustomStage set Sort=Sort+1 where ClientID=@ClientID and Sort>=@Sort

insert into CustomStage(StageID,StageName,Sort,Status,Mark,PID,CreateUserID,ClientID)
                                values(@StageID,@StageName,@Sort,1,0,@PID,@CreateUserID,@ClientID)
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
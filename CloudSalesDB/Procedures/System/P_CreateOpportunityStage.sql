Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateOpportunityStage')
BEGIN
	DROP  Procedure  P_CreateOpportunityStage
END

GO
/***********************************************************
过程名称： P_CreateOpportunityStage
功能描述： 添加机会阶段
参数说明：	 
编写日期： 2016/6/6
程序作者： Allen
调试记录： exec P_CreateOpportunityStage 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateOpportunityStage]
@StageID nvarchar(64),
@StageName nvarchar(100),
@Sort int=1,
@Probability decimal(18,4)=0,
@CreateUserID nvarchar(64)='',
@ClientID nvarchar(64)='',
@Result int output --0：失败，1：成功，2 编码已存在
AS

begin tran

set @Result=0

declare @Err int=0

update  OpportunityStage set Sort=Sort+1 where ClientID=@ClientID and Sort>=@Sort

insert into OpportunityStage(StageID,StageName,Probability,Sort,Status,Mark,CreateUserID,ClientID)
        values(@StageID,@StageName,@Probability,@Sort,1,0,@CreateUserID,@ClientID)
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
Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateCustomerStage')
BEGIN
	DROP  Procedure  P_UpdateCustomerStage
END

GO
/***********************************************************
过程名称： P_UpdateCustomerStage
功能描述： 更换客户阶段
参数说明：	 
编写日期： 2015/11/5
程序作者： Allen
调试记录： exec P_UpdateCustomerStage 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateCustomerStage]
	@CustomerID nvarchar(64)='',
	@StageID nvarchar(64)='',
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@OldStages nvarchar(64)


select @OldStages=StageID from Customer where CustomerID=@CustomerID 

if(@OldStages is null or @OldStages<>@StageID)
begin
	update Customer set StageID=@StageID where CustomerID=@CustomerID and Status=1
end

set @Err+=@@error

--处理记录
insert into CustomerStageLog(CustomerID,StageID,OldStageID,Status,Type,CreateUserID,AgentID,ClientID)
					values( @CustomerID,@StageID,@OldStages,1,1,@OperateID,@AgentID,@ClientID)

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 


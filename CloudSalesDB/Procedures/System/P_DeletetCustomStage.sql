Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeletetCustomStage')
BEGIN
	DROP  Procedure  P_DeletetCustomStage
END

GO
/***********************************************************
过程名称： P_DeletetCustomStage
功能描述： 删除客户阶段
参数说明：	 
编写日期： 2015/10/29
程序作者： Allen
调试记录： exec P_DeletetCustomStage 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeletetCustomStage]
@StageID nvarchar(64),
@UserID nvarchar(64)='',
@ClientID nvarchar(64)=''
AS

begin tran


declare @Err int=0,@Sort int=0,@Mark int=0,@Status int=1,@PrevStageID nvarchar(64)

select @Sort=Sort,@Mark=Mark,@Status=Status from CustomStage where StageID=@StageID and ClientID=@ClientID
if(@Mark=0 and @Status=1)
begin
	--取得上个客户阶段
	select @PrevStageID=StageID from CustomStage where ClientID=@ClientID and Sort=@Sort-1 and Status<>9

	update  CustomStage set Status=9 where StageID=@StageID and ClientID=@ClientID 

	update  CustomStage set Sort=Sort-1 where  ClientID=@ClientID and Sort>@Sort

	--删除原阶段日志记录
	update CustomerStageLog set Status=9 where ClientID=@ClientID and StageID=@StageID

	--记录客户阶段日志
	insert into CustomerStageLog(CustomerID,StageID,OldStageID,Status,Type,CreateUserID,AgentID,ClientID)
	select CustomerID,@PrevStageID,StageID,1,1,@UserID,AgentID,ClientID from Customer where ClientID=@ClientID and StageID=@StageID

	--更改客户阶段
	update Customer set StageID = @PrevStageID where ClientID=@ClientID and StageID=@StageID

	set @Err+=@@error
end


if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end
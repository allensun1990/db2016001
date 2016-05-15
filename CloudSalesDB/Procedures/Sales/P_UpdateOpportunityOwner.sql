Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOpportunityOwner')
BEGIN
	DROP  Procedure  P_UpdateOpportunityOwner
END

GO
/***********************************************************
过程名称： P_UpdateOpportunityOwner
功能描述： 更换机会拥有着
参数说明：	 
编写日期： 2016/5/3
程序作者： Allen
调试记录： exec P_UpdateOpportunityOwner 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOpportunityOwner]
	@OpportunityID nvarchar(64)='',
	@UserID nvarchar(64)='',
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@OldOwnerID nvarchar(64),@Status int

select @OldOwnerID=OwnerID,@Status=Status from Opportunity where OpportunityID=@OpportunityID  and ClientID=@ClientID

if(@OldOwnerID=@UserID)
begin
	rollback tran
	return
end

update Opportunity set OwnerID=@UserID,AgentID=@AgentID where OpportunityID=@OpportunityID and ClientID=@ClientID

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 


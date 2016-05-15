Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CloseOpportunity')
BEGIN
	DROP  Procedure  P_CloseOpportunity
END

GO
/***********************************************************
过程名称： P_CloseOpportunity
功能描述： 关闭机会
参数说明：	 
编写日期： 2016/5/3
程序作者： Allen
调试记录： exec P_CloseOpportunity 
************************************************************/
CREATE PROCEDURE [dbo].[P_CloseOpportunity]
	@OpportunityID nvarchar(64),
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int

select @Status=Status from Opportunity where OpportunityID=@OpportunityID  and ClientID=@ClientID

if(@Status > 1)
begin
	rollback tran
	return
end

Update Opportunity set Status=3 where OpportunityID=@OpportunityID

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 


Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOpportunityProductQuantity')
BEGIN
	DROP  Procedure  P_UpdateOpportunityProductQuantity
END

GO
/***********************************************************
过程名称： P_UpdateOpportunityProductQuantity
功能描述： 修改机会产品数量
参数说明：	 
编写日期： 2016/6/11
程序作者： Allen
调试记录： exec P_UpdateOpportunityProductQuantity 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOpportunityProductQuantity]
	@OpportunityID nvarchar(64),
	@ProductID nvarchar(64) ,
	@Quantity int=1,
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@TotalMoney decimal(18,4)

if not exists(select AutoID from Opportunity where OpportunityID=@OpportunityID and Status=1)
begin
	rollback tran
	return
end

update OpportunityProduct set Quantity=@Quantity,TotalMoney=Price*@Quantity where OpportunityID=@OpportunityID and ProductDetailID=@ProductID

select @TotalMoney=sum(TotalMoney) from OpportunityProduct where OpportunityID=@OpportunityID

Update Opportunity set TotalMoney=@TotalMoney where OpportunityID=@OpportunityID

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 


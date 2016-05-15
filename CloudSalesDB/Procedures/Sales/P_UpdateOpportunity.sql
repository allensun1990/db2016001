Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOpportunity')
BEGIN
	DROP  Procedure  P_UpdateOpportunity
END

GO
/***********************************************************
过程名称： P_UpdateOpportunity
功能描述： 编辑机会
参数说明：	 
编写日期： 2016/5/3
程序作者： Allen
调试记录： exec P_UpdateOpportunity 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOpportunity]
	@OpportunityID nvarchar(64)='',
	@PersonName nvarchar(50)='',
	@MobileTele nvarchar(50)='',
	@CityCode nvarchar(50)='',
	@Address nvarchar(50)='',
	@PostalCode nvarchar(20)='',
	@TypeID nvarchar(64)='',
	@Remark nvarchar(500)='',
	@UserID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)='',
	@Result int output
AS

set @Result=0	
begin tran

declare @Err int=0, @Status int=0,@TotalMoney decimal(18,2)=0

if not exists(select AutoID from Opportunity  where OpportunityID=@OpportunityID and ClientID=@ClientID and Status=1)
begin
	set @Result=2
	rollback tran
	return
end 


update Opportunity set PersonName=@PersonName,MobileTele=@MobileTele,CityCode=@CityCode,Address=@Address,PostalCode=@PostalCode,TypeID=@TypeID,Remark=@Remark
			  where OpportunityID=@OpportunityID and ClientID=@ClientID and Status=1

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end

 


 


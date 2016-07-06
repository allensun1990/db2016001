Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateOpportunity')
BEGIN
	DROP  Procedure  P_CreateOpportunity
END

GO
/***********************************************************
过程名称： P_CreateOpportunity
功能描述： 创建销售机会
参数说明：	 
编写日期： 2016/4/29
程序作者： Allen
调试记录： exec P_CreateOpportunity 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateOpportunity]
@OpportunityID nvarchar(64),
@OpportunityCode nvarchar(20),
@CustomerID nvarchar(64)='',
@TypeID nvarchar(64)='',
@Name nvarchar(50)='',
@Mobile nvarchar(50)='',
@CityCode nvarchar(10)='',
@Address nvarchar(500)='',
@Remark nvarchar(500)='',
@UserID nvarchar(64),
@AgentID nvarchar(64),
@ClientID nvarchar(64)
AS

begin tran

declare  @Err int=0,@StageID nvarchar(64)

if exists (select AutoID from Opportunity where OpportunityCode=@OpportunityCode and ClientID=@ClientID)
begin
	set @OpportunityCode=@OpportunityCode+'1'
end

select top 1 @StageID=StageID from OpportunityStage where ClientID=@ClientID and Status=1 order by Sort 

insert into Opportunity(OpportunityID,OpportunityCode,Status,TypeID,CustomerID,PersonName,MobileTele,CityCode,Address,Remark,OwnerID,CreateUserID,AgentID,ClientID,StageID)
		values (@OpportunityID,@OpportunityCode,1,@TypeID,@CustomerID,@Name,@Mobile,@CityCode,@Address,@Remark,@UserID,@UserID,@AgentID,@ClientID,@StageID)

if exists(select AutoID from Customer where CustomerID=@CustomerID and StageStatus<2)
begin
	update Customer set StageStatus=2,OpportunityTime=getdate(),OpportunityID=@OpportunityID,OpportunityCount=OpportunityCount+1 where CustomerID=@CustomerID and StageStatus<2
end
else
begin
	update Customer set OpportunityCount=OpportunityCount+1 where CustomerID=@CustomerID
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
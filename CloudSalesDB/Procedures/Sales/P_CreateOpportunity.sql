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
@UserID nvarchar(64),
@AgentID nvarchar(64),
@ClientID nvarchar(64)
AS

declare @PersonName nvarchar(50),@MobileTele nvarchar(20),@CityCode nvarchar(20),@Address nvarchar(200),@OwnerID nvarchar(64),@Type int,@StageID nvarchar(64)

select @PersonName=Name,@MobileTele=MobilePhone,@CityCode=CityCode,@Address=Address,@OwnerID=OwnerID,@Type=Type from Customer where CustomerID=@CustomerID
if(@Type=1)
begin	
	select @PersonName=Name,@MobileTele=MobilePhone,@CityCode=CityCode,@Address=Address from Contact where CustomerID=@CustomerID and Status<>9 Order By [Type] desc
end


if(@OwnerID is null or @OwnerID='')
begin
	set @OwnerID=@UserID
end

if exists (select AutoID from Opportunity where OpportunityCode=@OpportunityCode and ClientID=@ClientID)
begin
	set @OpportunityCode=@OpportunityCode+'1'
end

select top 1 @StageID=StageID from OpportunityStage where ClientID=@ClientID and Status=1 order by Sort 

insert into Opportunity(OpportunityID,OpportunityCode,Status,TypeID,CustomerID,PersonName,MobileTele,CityCode,Address,OwnerID,CreateUserID,AgentID,ClientID,StageID)
		values (@OpportunityID,@OpportunityCode,1,@TypeID,@CustomerID,@PersonName,@MobileTele,@CityCode,@Address,@OwnerID,@UserID,@AgentID,@ClientID,@StageID)

update Customer set StageStatus=2 where CustomerID=@CustomerID and StageStatus<2

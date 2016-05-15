Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateOrder')
BEGIN
	DROP  Procedure  P_CreateOrder
END

GO
/***********************************************************
过程名称： P_CreateOrder
功能描述： 创建销售订单
参数说明：	 
编写日期： 2015/11/13
程序作者： Allen
调试记录： exec P_CreateOrder 
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateOrder]
@OrderID nvarchar(64),
@OrderCode nvarchar(20),
@CustomerID nvarchar(64)='',
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

if exists (select AutoID from Orders where OrderCode=@OrderCode and ClientID=@ClientID)
begin
	set @OrderCode=@OrderCode+'1'
end

select top 1 @StageID=StageID from OpportunityStage where ClientID=@ClientID and Probability>0 order by Probability 

insert into Orders(OrderID,OrderCode,Status,CustomerID,PersonName,MobileTele,CityCode,Address,OwnerID,CreateUserID,AgentID,ClientID,StageID)
		values (@OrderID,@OrderCode,0,@CustomerID,@PersonName,@MobileTele,@CityCode,@Address,@OwnerID,@UserID,@AgentID,@ClientID,@StageID)

--处理客户阶段
declare @CustomerStageID nvarchar(64),@Sort int,@OldStageID nvarchar(64),@OldSort int
select @CustomerStageID=StageID,@Sort=Sort from CustomStage where ClientID=@ClientID and Mark=2
select @OldStageID=StageID from Customer where CustomerID=@CustomerID
select @OldSort=Sort from CustomStage where StageID=@OldStageID

if(@CustomerStageID<>@OldStageID and @OldSort< @Sort)
begin
	update Customer set StageID=@CustomerStageID where CustomerID=@CustomerID

	insert into CustomerStageLog(CustomerID,StageID,OldStageID,Status,Type,CreateUserID,AgentID,ClientID)
					values( @CustomerID,@CustomerStageID,@OldStageID,1,1,@UserID,@AgentID,@ClientID)
end

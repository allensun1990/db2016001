Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_SubmitOrder')
BEGIN
	DROP  Procedure  P_SubmitOrder
END

GO
/***********************************************************
过程名称： P_SubmitOrder
功能描述： 提交订单
参数说明：	 
编写日期： 2015/11/14
程序作者： Allen
调试记录： exec P_SubmitOrder 
************************************************************/
CREATE PROCEDURE [dbo].[P_SubmitOrder]
	@OpportunityID nvarchar(64)='',
	@OrderCode nvarchar(50)='',
	@UserID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)='',
	@Result int output
AS

set @Result=0	
begin tran

declare @Err int=0, @OrderID nvarchar(64)=NEWID(),@CustomerID nvarchar(64),@Status int=0

select @CustomerID=CustomerID,@Status=Status from Opportunity where OpportunityID=@OpportunityID and ClientID=@ClientID

if (@Status<>1)
begin
	set @Result=2
	rollback tran
	return
end 

if exists (select AutoID from Orders where OrderCode=@OrderCode and ClientID=@ClientID)
begin
	set @OrderCode=@OrderCode+'1'
end

insert into Orders(OrderID,OrderCode,Status,CustomerID,PersonName,MobileTele,CityCode,Address,OwnerID,CreateUserID,AgentID,ClientID,StageID,TypeID,OpportunityID,OpportunityCode,TotalMoney)
		select @OrderID,@OrderCode,1,CustomerID,PersonName,MobileTele,CityCode,Address,OwnerID,@UserID,AgentID,ClientID,StageID,TypeID,OpportunityID,OpportunityCode,TotalMoney from Opportunity where OpportunityID=@OpportunityID

insert into OrderDetail(OrderID,ProductDetailID,ProductID,UnitID,UnitName,IsBigUnit,BigSmallMultiple,Quantity,Price,TotalMoney,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID,ProviderName)
select @OrderID,ProductDetailID,ProductID,UnitID,UnitName,IsBigUnit,BigSmallMultiple,Quantity,Price,TotalMoney,Remark,ClientID,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProviderID,ProviderName from OpportunityProduct
where OpportunityID=@OpportunityID

set @Err+=@@error


update Opportunity set Status=2,OrderTime=getdate(),OrderID=@OrderID,OrderCode=@OrderCode where OpportunityID=@OpportunityID and ClientID=@ClientID and Status=1

update Customer set OrderCount=OrderCount+1 where CustomerID=@CustomerID

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

 


 


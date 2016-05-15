Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_EditOrder')
BEGIN
	DROP  Procedure  P_EditOrder
END

GO
/***********************************************************
过程名称： P_EditOrder
功能描述： 编辑订单
参数说明：	 
编写日期： 2015/12/7
程序作者： Allen
调试记录： exec P_EditOrder 
************************************************************/
CREATE PROCEDURE [dbo].[P_EditOrder]
	@OrderID nvarchar(64)='',
	@PersonName nvarchar(50)='',
	@MobileTele nvarchar(50)='',
	@CityCode nvarchar(50)='',
	@Address nvarchar(50)='',
	@PostalCode nvarchar(20)='',
	@TypeID nvarchar(64)='',
	@ExpressType int=0,
	@Remark nvarchar(500)='',
	@UserID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)='',
	@Result int output
AS

set @Result=0	
begin tran

declare @Err int=0, @Status int=0,@TotalMoney decimal(18,2)=0

if not exists(select AutoID from Orders  where OrderID=@OrderID and ClientID=@ClientID and Status<=1)
begin
	set @Result=2
	rollback tran
	return
end 


update Orders set PersonName=@PersonName,MobileTele=@MobileTele,CityCode=@CityCode,Address=@Address,PostalCode=@PostalCode,TypeID=@TypeID,ExpressType=@ExpressType,Remark=@Remark
			  where OrderID=@OrderID and ClientID=@ClientID and Status<=1

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

 


 


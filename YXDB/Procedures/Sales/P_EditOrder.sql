Use IntFactory_dev
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
	@IntGoodsCode nvarchar(50)='',
	@GoodsName nvarchar(100)='',
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

declare @Err int=0, @Status int=0,@OrderType int=1

select @Status=OrderStatus,@OrderType=OrderType from Orders  where OrderID=@OrderID and ClientID=@ClientID

if (@Status>=2)
begin
	set @Result=2
	rollback tran
	return
end 

if(@OrderType=1)
begin
	if(@IntGoodsCode<>'' and exists(select AutoID from Orders where OrderID<>@OrderID and ClientID=@ClientID and IntGoodsCode=@IntGoodsCode))
	begin
		set @Result=3
		rollback tran
		return
	end
	else
	begin
		update Orders set IntGoodsCode=@IntGoodsCode,GoodsName=@GoodsName,PersonName=@PersonName,MobileTele=@MobileTele,CityCode=@CityCode,Address=@Address,PostalCode=@PostalCode,TypeID=@TypeID,ExpressType=@ExpressType,Remark=@Remark
			  where OrderID=@OrderID and ClientID=@ClientID 
	end
end
else
begin
	update Orders set PersonName=@PersonName,MobileTele=@MobileTele,CityCode=@CityCode,Address=@Address,PostalCode=@PostalCode,TypeID=@TypeID,ExpressType=@ExpressType,Remark=@Remark
			  where OrderID=@OrderID and ClientID=@ClientID 
end


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

 


 


Use IntFactory
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
	@ExpressType int=0,
	@Remark nvarchar(500)='',
	@UserID nvarchar(64)='',
	@ClientID nvarchar(64)='',
	@Result int output
AS

set @Result=0	
begin tran

declare @Err int=0, @Status int=0,@OrderType int,@OriginalID nvarchar(64),@GoodsID nvarchar(64),@OrderClientID nvarchar(64)

select @Status=OrderStatus,@OrderType=OrderType,@OriginalID=OriginalID,@GoodsID=GoodsID,@OrderClientID=ClientID 
from Orders  where OrderID=@OrderID and (ClientID=@ClientID or EntrustClientID=@ClientID)

if (@Status>=2)
begin
	set @Result=2
	rollback tran
	return
end 

if(@GoodsID<>'' and  exists(select AutoID from Goods where GoodsID<>@GoodsID and ClientID=@OrderClientID and GoodsCode=@IntGoodsCode))
begin
	set @Result=3
	rollback tran
	return
end

if(@OrderType=1)
begin
	update Orders set IntGoodsCode=@IntGoodsCode,GoodsName=@GoodsName,PersonName=@PersonName,MobileTele=@MobileTele,CityCode=@CityCode,Address=@Address,PostalCode=@PostalCode,ExpressType=@ExpressType,Remark=@Remark
			where OrderID=@OrderID 

	Update Orders set IntGoodsCode=@IntGoodsCode,GoodsName=@GoodsName where OriginalID=@OrderID

end
else
begin
	update Orders set IntGoodsCode=@IntGoodsCode,GoodsName=@GoodsName,PersonName=@PersonName,MobileTele=@MobileTele,CityCode=@CityCode,Address=@Address,PostalCode=@PostalCode,ExpressType=@ExpressType,Remark=@Remark
				  where OrderID=@OrderID
	
	Update Orders set IntGoodsCode=@IntGoodsCode,GoodsName=@GoodsName where OrderID=@OriginalID
end

if(@GoodsID<>'')
begin
	Update Goods set GoodsCode=@IntGoodsCode,GoodsName=@GoodsName where GoodsID=@GoodsID
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

 


 


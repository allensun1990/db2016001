Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderAttrName')
BEGIN
	DROP  Procedure  P_UpdateOrderAttrName
END

GO
/***********************************************************
过程名称： P_UpdateOrderAttrName
功能描述： 修改订单规格名称
参数说明：	 
编写日期： 2017/11/15
程序作者： Allen
调试记录： exec P_UpdateOrderAttrName 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderAttrName]
	@OrderID nvarchar(64),
	@OrderAttrID nvarchar(64),
	@Name nvarchar(64),
	@Type int
AS
	
begin tran

declare @Err int=0,@Status int,@OldNameAll nvarchar(50),@OldName nvarchar(50),@GoodsID nvarchar(64)

select @Status=OrderStatus,@GoodsID=GoodsID from Orders where OrderID=@OrderID 

if(@Status>=2)
begin
	rollback tran
	return
end

select @OldNameAll=AttrName,@OldName=REPLACE(REPLACE(@OldNameAll,'【',''),'】','') from OrderAttrs where OrderAttrID=@OrderAttrID

if(@OldName=@Name)
begin
	rollback tran
	return
end

--打样规格
update OrderAttrs set AttrName='【'+@Name+'】' where OrderAttrID=@OrderAttrID



--下单明细
if(@Type=1)
begin
	update OrderGoods set XRemark=replace(XRemark,@OldNameAll,'【'+@Name+'】'),Remark=replace(Remark,'：'+@OldName+'】','：'+@Name+'】') where OrderID=@OrderID
end
else
begin
	--款式材料
	update OrderDetail set SalesAttr='【'+@Name+'】' where OrderAttrID=@OrderAttrID

	update OrderGoods set YRemark=replace(YRemark,@OldNameAll,'【'+@Name+'】'),Remark=replace(Remark,'：'+@OldName+'】','：'+@Name+'】') where OrderID=@OrderID
end

update OrderGoods set XYRemark=XRemark+YRemark where OrderID=@OrderID

--款式明细
update GoodsDetail set Description=replace(Description,'：'+@OldName+'】','：'+@Name+'】') where GoodsID=@GoodsID


set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 


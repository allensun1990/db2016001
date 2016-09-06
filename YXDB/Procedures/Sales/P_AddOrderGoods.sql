Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AddOrderGoods')
BEGIN
	DROP  Procedure  P_AddOrderGoods
END

GO
/***********************************************************
过程名称： P_AddOrderGoods
功能描述： 添加大货单明细
参数说明：	 
编写日期： 2016/3/7
程序作者： Allen
调试记录： exec P_AddOrderGoods 
************************************************************/
CREATE PROCEDURE [dbo].[P_AddOrderGoods]
@OrderID nvarchar(64),
@AttrList nvarchar(max),
@ValueList nvarchar(max),
@AttrValueList nvarchar(max),
@Quantity decimal(18,4),
@XRemark nvarchar(500)='',
@YRemark nvarchar(500)='',
@XYRemark nvarchar(500)='',
@Description nvarchar(4000),
@OperateID nvarchar(64),
@ClientID nvarchar(64)
AS


declare @GoodsID nvarchar(64),@Status int,@GoodsDetailID nvarchar(64),@Price decimal(18,4),@OriginalPrice decimal(18,4),
@DetailID nvarchar(64),@TotalQuantity decimal(18,4),@TotalMoney decimal(18,4),@OrderClientID nvarchar(64),@OrderType int

select @GoodsID=isnull(GoodsID,''),@Status=Status,@Price=FinalPrice,@OriginalPrice=OriginalPrice,@OrderClientID=ClientID,@OrderType=OrderType from Orders where OrderID=@OrderID


if (@GoodsID<>'' and exists(select AutoID from GoodsDetail where GoodsID=@GoodsID  and replace(Description,' ','')=replace(@Description,' ','')))
begin
	select @DetailID=GoodsDetailID from GoodsDetail where GoodsID=@GoodsID  and replace(Description,' ','')=replace(@Description,' ','')
end
else if(@GoodsID<>'')
begin
	set @DetailID=NEWID()
	INSERT INTO GoodsDetail(GoodsDetailID,GoodsID,[SaleAttr],[AttrValue],[SaleAttrValue],[Price] ,[Description],[CreateUserID] ,[ClientID])
				VALUES(@DetailID,@GoodsID,@AttrList,@ValueList,@AttrValueList,@OriginalPrice,@Description,@OperateID,@OrderClientID);
end

if exists(select AutoID from OrderGoods where GoodsDetailID=@DetailID and OrderID=@OrderID)
begin
	Update OrderGoods set Quantity=Quantity+@Quantity,TotalMoney=@Price*(Quantity+@Quantity) where GoodsDetailID=@DetailID and OrderID=@OrderID
end
else
begin
	insert into OrderGoods(OrderID,GoodsID,GoodsDetailID,Quantity,Price,TotalMoney,Remark,XRemark,YRemark,XYRemark)
	values(@OrderID,@GoodsID,@DetailID,@Quantity,@Price,@Quantity*@Price,@Description,@XRemark,@YRemark,@XYRemark)
end

select @TotalQuantity=sum(Quantity) from OrderGoods where OrderID=@OrderID

if(@OrderType=1)
begin
	if not exists(select AutoID from OrderAttrs where OrderID=@OrderID and replace(AttrName,' ','')=replace(@XRemark,' ','') and AttrType=1)
	begin
		insert into OrderAttrs(OrderAttrID,OrderID,GoodsID,AttrName,AttrType,Price,FinalPrice)
		values(NewID(),@OrderID,'',@XRemark,1,0,0)
	end

	if not exists(select AutoID from OrderAttrs where OrderID=@OrderID and replace(AttrName,' ','')=replace(@YRemark,' ','') and AttrType=2)
	begin
		insert into OrderAttrs(OrderAttrID,OrderID,GoodsID,AttrName,AttrType,Price,FinalPrice)
		values(NewID(),@OrderID,'',@YRemark,2,0,0)
	end
	Update Orders set PlanQuantity=@TotalQuantity where OrderID=@OrderID
end
else
begin
	update OrderDetail set OrderQuantity=@TotalQuantity,PlanQuantity=Quantity*@TotalQuantity,TotalMoney=Price*Quantity*@TotalQuantity 
	where OrderID=@OrderID 

	select @TotalMoney=sum(TotalMoney) from OrderDetail where OrderID=@OrderID

	Update Orders set PlanQuantity=@TotalQuantity,Price=isnull(@TotalMoney,0) where OrderID=@OrderID
end






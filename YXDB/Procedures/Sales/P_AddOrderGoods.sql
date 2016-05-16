Use IntFactory_dev
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
@Description nvarchar(4000),
@OperateID nvarchar(64),
@ClientID nvarchar(64)
AS


declare @GoodsID nvarchar(64),@Status int,@GoodsDetailID nvarchar(64),@Price decimal(18,4),@OriginalPrice decimal(18,4),
@DetailID nvarchar(64),@TotalQuantity decimal(18,4),@TotalMoney decimal(18,4)

select @GoodsID=GoodsID,@Status=Status,@Price=FinalPrice,@OriginalPrice=OriginalPrice from Orders where OrderID=@OrderID


if exists(select AutoID from GoodsDetail where GoodsID=@GoodsID  and [AttrValue]=@ValueList)
begin
	
	select @DetailID=GoodsDetailID from GoodsDetail where GoodsID=@GoodsID  and [AttrValue]=@ValueList
end
else
begin
	set @DetailID=NEWID()
	INSERT INTO GoodsDetail(GoodsDetailID,GoodsID,[SaleAttr],[AttrValue],[SaleAttrValue],[Price] ,[Description],[CreateUserID] ,[ClientID])
				VALUES(@DetailID,@GoodsID,@AttrList,@ValueList,@AttrValueList,@OriginalPrice,@Description,@OperateID,@ClientID);
end


if exists(select AutoID from OrderGoods where GoodsDetailID=@DetailID and OrderID=@OrderID)
begin
	Update OrderGoods set Quantity=Quantity+@Quantity,TotalMoney=@Price*(Quantity+@Quantity) where GoodsDetailID=@DetailID and OrderID=@OrderID
end
else
begin
	insert into OrderGoods(OrderID,GoodsID,GoodsDetailID,Quantity,Price,TotalMoney,Remark)
	values(@OrderID,@GoodsID,@DetailID,@Quantity,@Price,@Quantity*@Price,@Description)
end

select @TotalQuantity=sum(Quantity),@TotalMoney=sum(TotalMoney) from OrderGoods where OrderID=@OrderID

Update Orders set PlanQuantity=@TotalQuantity,TotalMoney=@TotalMoney where OrderID=@OrderID




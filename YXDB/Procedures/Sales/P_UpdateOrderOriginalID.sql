Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderOriginalID')
BEGIN
	DROP  Procedure  P_UpdateOrderOriginalID
END

GO
/***********************************************************
过程名称： P_UpdateOrderOriginalID
功能描述： 绑定打样订单
参数说明：	 
编写日期： 2016/3/7
程序作者： Allen
调试记录： exec P_UpdateOrderOriginalID 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderOriginalID]
	@OrderID nvarchar(64),
	@OriginalID nvarchar(64),
	@OperateID nvarchar(64)='',
	@AgentID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int=-1,@OrderType int

select @Status=Status,@OrderType=OrderType from Orders where OrderID=@OrderID and ClientID=@ClientID and OriginalID=''

if(@Status<>0 or @OrderType<>2)
begin
	rollback tran
	return
end

Update Orders set OriginalID=@OriginalID,OrderTime=getdate() where OrderID=@OrderID

update o set OriginalCode=od.OrderCode,BigCategoryID=od.BigCategoryID,CategoryID=od.CategoryID,FinalPrice=od.FinalPrice,TotalMoney=od.FinalPrice*o.PlanQuantity,IntGoodsCode=od.IntGoodsCode,GoodsName=od.GoodsName,
			 Price=od.Price,ProfitPrice=od.ProfitPrice,CostPrice=od.CostPrice,Platemaking=od.Platemaking,PlateRemark=od.PlateRemark,Status=4,GoodsID=od.GoodsID,OriginalPrice=od.FinalPrice 
			 from Orders o join Orders od on o.OriginalID=od.OrderID where o.OrderID=@OrderID
	
--复制打样材料列表
insert into OrderDetail(OrderID,ProductDetailID,ProductID,UnitID,Quantity,Price,Loss,TotalMoney,Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProdiverID )
select @OrderID,ProductDetailID,ProductID,UnitID,Quantity,Price,Loss,TotalMoney,Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProdiverID  from OrderDetail where OrderID=@OriginalID

Insert into OrderStatusLog(OrderID,Status,CreateUserID) values(@OrderID,4,@OperateID)

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 


Use IntFactory_dev
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_CreateDHOrder')
BEGIN
	DROP  Procedure  P_CreateDHOrder
END

GO
/***********************************************************
过程名称： P_CreateDHOrder
功能描述： 创建大货单
参数说明：	 
编写日期： 2016/3/7
程序作者： Allen
调试记录： exec P_CreateDHOrder 'a0020b2d-e2b2-4f7f-9774-628759f3513f',
************************************************************/
CREATE PROCEDURE [dbo].[P_CreateDHOrder]
	@OriginalID nvarchar(64),
	@OrderID nvarchar(64),
	@Discount decimal(18,4)=1,
	@Price decimal(18,4)=0,
	@OrderCode nvarchar(50),
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)
AS
	
declare @Status int,@OwnerID nvarchar(64),@ProcessID nvarchar(64)

select @Status=Status,@OwnerID=OwnerID,@ProcessID=ProcessID from Orders where OrderID=@OriginalID and ClientID=@ClientID

if(@Status<>3)
begin
	return
end


select @ProcessID=ProcessID,@OwnerID=OwnerID from OrderProcess where ClientID=@ClientID and ProcessType=2 and IsDefault=1

insert into Orders(OrderID,OrderCode,CategoryID,TypeID,OrderType,SourceType,Status,ProcessID,PlanPrice,FinalPrice,PlanQuantity,PlanType,TaskCount,TaskOver,OrderImage,OriginalID,OriginalCode ,
					Price,CostPrice,ProfitPrice,TotalMoney,CityCode,Address,PersonName,MobileTele,Remark,CustomerID,OwnerID,CreateTime,AgentID,ClientID,Platemaking,PlateRemark,
					GoodsCode,Title,BigCategoryID,OrderImages,GoodsID,Discount,OriginalPrice,IntGoodsCode,GoodsName)
select @OrderID,@OrderCode,CategoryID,TypeID,2,1,4,@ProcessID,PlanPrice,@Price,0,PlanType,0,0,OrderImage,OrderID,OrderCode,
		Price,CostPrice,ProfitPrice,0,CityCode,Address,PersonName,MobileTele,Remark,CustomerID,@OwnerID,getdate(),AgentID,ClientID,Platemaking,PlateRemark,
		GoodsCode,Title,BigCategoryID,OrderImages,GoodsID,@Discount,FinalPrice,IntGoodsCode,GoodsName from Orders where OrderID=@OriginalID
	
--复制打样材料列表
insert into OrderDetail(OrderID,ProductDetailID,ProductID,UnitID,Quantity,Price,Loss,TotalMoney,Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProdiverID )
select @OrderID,ProductDetailID,ProductID,UnitID,Quantity,Price,Loss,TotalMoney,Remark,ProductName,ProductCode,DetailsCode,ProductImage,ImgS,ProdiverID  from OrderDetail where OrderID=@OriginalID




Insert into OrderStatusLog(OrderID,Status,CreateUserID) values(@OrderID,4,@OperateID)
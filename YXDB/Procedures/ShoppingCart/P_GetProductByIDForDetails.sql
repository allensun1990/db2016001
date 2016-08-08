Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetProductByIDForDetails')
BEGIN
	DROP  Procedure  P_GetProductByIDForDetails
END

GO
/***********************************************************
过程名称： P_GetProductByIDForDetails
功能描述： 获取产品详情（加入购物车页面）
参数说明：	 
编写日期： 2015/7/1
程序作者： Allen
调试记录： exec P_GetProductByIDForDetails 'cba6e56e-4b72-45d2-b72c-3dd0db19438f1','162df060-3b7b-4c2a-8609-a86fafca69c6'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetProductByIDForDetails]
	@ProductID nvarchar(64),
	@ClientID nvarchar(64)=''
AS

declare @ProdiverID nvarchar(64),@CategoryID nvarchar(64)

select @ProdiverID=ProviderID from Products where ProductID=@ProductID

select p.ProductID,ProductCode,ProductName,UnitID,CategoryID,SaleAttr,AttrList,ValueList,AttrValueList,Price,p.ClientID,
		Weight,ProductImage,ShapeCode,ProviderID,Description,CreateTime,isnull(c.StockIn,0) StockIn,isnull(c.StockOut,0) StockOut,isnull(c.LogicOut,0) LogicOut
from Products p left join ClientProducts c on p.ProductID=c.ProductID and c.ClientID=@ClientID where p.ProductID=@ProductID 

select p.ProductID,p.ProductDetailID,DetailsCode,Price,SaleAttr,AttrValue,SaleAttrValue,ImgS,Weight,Description,CreateTime,Remark,p.ClientID,
	   isnull(c.StockIn,0) StockIn,isnull(c.StockOut,0) StockOut,isnull(c.LogicOut,0) LogicOut,p.IsDefault 
from ProductDetail  p left join ClientProductDetails c on p.ProductDetailID=c.ProductDetailID and c.ClientID=@ClientID where p.ProductID=@ProductID and p.Status<>9

select * from Providers where ProviderID= @ProdiverID

select * from ProductStock where ClientID=@ClientID and ProductID=@ProductID


 


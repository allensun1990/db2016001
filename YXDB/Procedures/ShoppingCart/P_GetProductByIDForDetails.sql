﻿Use IntFactory
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
调试记录： exec P_GetProductByIDForDetails 'CD867D63-B61D-47DE-9C63-0B1A56D68486'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetProductByIDForDetails]
	@ProductID nvarchar(64),
	@ClientID nvarchar(64)=''
AS

declare @ProdiverID nvarchar(64),@CategoryID nvarchar(64)

select @ProdiverID=ProdiverID,@CategoryID=CategoryID from Products where ProductID=@ProductID

select p.ProductID,ProductCode,ProductName,SmallUnitID,CategoryID,SaleAttr,AttrList,ValueList,AttrValueList,Price,OnlineTime,
		IsNew,Weight,ProductImage,ShapeCode,ProdiverID,Description,CreateTime,isnull(c.StockIn,0) StockIn,isnull(c.StockOut,0) StockOut,isnull(c.LogicOut,0) LogicOut
from Products p left join ClientProducts c on p.ProductID=c.ProductID and c.ClientID=@ClientID where p.ProductID=@ProductID 

select p.ProductID,p.ProductDetailID,DetailsCode,Price,SaleAttr,AttrValue,SaleAttrValue,ImgS,Weight,Description,CreateTime,Remark,p.ClientID,
	   isnull(c.StockIn,0) StockIn,isnull(c.StockOut,0) StockOut,isnull(c.LogicOut,0) LogicOut 
from ProductDetail  p left join ClientProductDetails c on p.ProductDetailID=c.ProductDetailID and c.ClientID=@ClientID where p.ProductID=@ProductID

select * from Providers where ProviderID= @ProdiverID

select p.AttrID,p.AttrName,c.Type into #AttrTable from ProductAttr p join CategoryAttr c on p.AttrID=c.AttrID 
where c.Status=1 and c.CategoryID= @CategoryID and p.Status=1 order by p.AutoID
--属性
select * from #AttrTable
--属性值
select ValueID,ValueName,AttrID from AttrValue  where AttrID in (select AttrID from #AttrTable) and Status<>9


 


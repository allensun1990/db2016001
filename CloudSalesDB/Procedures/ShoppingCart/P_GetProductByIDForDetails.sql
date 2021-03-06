﻿Use [CloudSales1.0_dev]
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
	@ProductID nvarchar(64)
AS

declare @CategoryID nvarchar(64),@HasDetails int

select @HasDetails=HasDetails,@CategoryID=CategoryID from Products where ProductID=@ProductID

select * from Products where ProductID=@ProductID 

if(@HasDetails=1)
begin
	select * from ProductDetail where ProductID=@ProductID and Status=1 and (IsDefault=0 or StockIn>0 or LogicOut>0 ) order by Remark
end
else
begin
	select * from ProductDetail where ProductID=@ProductID and Status=1 order by Remark
end


--select p.AttrID,p.AttrName,c.Type from ProductAttr p join CategoryAttr c on p.AttrID=c.AttrID 
--where c.Status=1 and c.CategoryID= @CategoryID and p.Status=1 order by  c.Sort,c.AutoID

 


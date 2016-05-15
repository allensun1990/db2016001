Use IntFactory_dev
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetOrderCategoryDetailsByID')
BEGIN
	DROP  Procedure  P_GetOrderCategoryDetailsByID
END

GO
/***********************************************************
过程名称： P_GetOrderCategoryDetailsByID
功能描述： 获取订单分类详情
参数说明：	 
编写日期： 2015/6/1
程序作者： Allen
调试记录： exec P_GetOrderCategoryDetailsByID 'f539d39b-8a58-4d70-a08f-550d126b0709','68a0471c-05e6-40c7-9430-dbe728bb8982'
************************************************************/
CREATE PROCEDURE [dbo].[P_GetOrderCategoryDetailsByID]
	@CategoryID nvarchar(64),
	@OrderID nvarchar(64)
AS

select * from Category where CategoryID=@CategoryID

select p.AttrID,AttrName,Description,p.CategoryID,c.Type into #AttrTable from ProductAttr p join CategoryAttr c on p.AttrID=c.AttrID 
where c.Status=1 and c.CategoryID= @CategoryID and p.Status=1 order by p.AutoID
--属性
select * from #AttrTable
--属性值
select ValueID,ValueName,AttrID from AttrValue  where AttrID in (select AttrID from #AttrTable) and Status<>9 order by Sort



--select ValueID,ValueName,AttrID from AttrValue  where AttrID in (select AttrID from #AttrTable where Type=2) and Status<>9
--union
--select a.ValueID,a.ValueName,a.AttrID from AttrValue a join OrderTaskPlateAttr o on a.ValueID=o.ValueID  
--where AttrID in (select AttrID from #AttrTable where Type=1) and Status<>9 and o.OrderID=@OrderID


 


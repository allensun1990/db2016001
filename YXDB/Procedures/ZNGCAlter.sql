
DROP  Procedure  P_GetAttrByID
GO
DROP  Procedure  P_GetCategoryDetailByID
GO
DROP  Procedure  P_GetAttrsByCategoryID
GO
DROP  Procedure  P_GetTaskPlateAttrByCategoryID
GO
DROP  Procedure  P_GetOrderCategoryDetailsByID
GO
DROP  Procedure  P_GetWareHouses
GO
DROP  Procedure  P_AddShoppingCartBatchIn
Go
DROP  Procedure  P_AddShoppingCartBatchOut
GO
DROP  Procedure  P_GetOpportunitys

--删除无效菜单和权限
delete from Menu where IsHide=1 
delete from RolePermission where MenuCode not in (select MenuCode from Menu)

--Orders 表 PlanPrice 改为 decimal 类型

--处理批次信息
Update ShoppingCart set BatchCode=''
update StorageDetail set BatchCode=''
GO
select ProductDetailID,ProductID,WareID,DepotID,ClientID,SUM(StockIn) StockIn,sum(StockOut) StockOut into #tempstock from ProductStock 
group by ProductDetailID,ProductID,WareID,DepotID,ClientID
GO
truncate table ProductStock
GO
insert into ProductStock(ProductDetailID,ProductID,WareID,DepotID,ClientID,StockIn,StockOut)
select ProductDetailID,ProductID,WareID,DepotID,ClientID,StockIn,StockOut from #tempstock
Go
Drop table #tempstock
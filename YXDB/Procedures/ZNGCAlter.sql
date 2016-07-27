
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
GO
DROP  Procedure  P_GetActivitys
GO
DROP  Procedure  P_InsertCustomSource
GO
DROP  Procedure  P_InsertCustomStage
GO
DROP  Procedure  P_DeletetCustomStage
GO
DROP  Procedure  P_UpdateCustomerStage

--删除订单类别表
drop table OrderType
--删除客户来源表
drop table CustomSource
drop table Activity
drop table ActivityReply
drop table CustomerStageLog


--删除无效菜单和权限
delete from Menu where MenuCode in ('103029001','103029003','103030301','103030303','103030401','103030403')

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

DROP  Procedure  P_GetAttrByID

DROP  Procedure  P_GetCategoryDetailByID

DROP  Procedure  P_GetAttrsByCategoryID

DROP  Procedure  P_GetTaskPlateAttrByCategoryID

DROP  Procedure  P_GetOrderCategoryDetailsByID

DROP  Procedure  P_GetWareHouses

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
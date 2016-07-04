
--材料表和材料明细表，库存相关数据类型变更

--材料报损报溢
update Menu set IsHide=0 where AutoID in (94,99)

--大货单翻单批次
alter table Orders add TurnTimes int default 0
Update Orders set TurnTimes=0 where OrderType=1
Update Orders set TurnTimes=1 where OrderType=2

select o.OriginalID,o.OrderID,count(o1.AutoID) C into #Temp from  Orders o join Orders o1 on o.OriginalID=o1.OriginalID and o1.AutoID<o.AutoID
where o.OrderType=2 and o1.OrderType=2 and o.OriginalID<>'' group by o.OriginalID,o.OrderID 

UPDATE o set TurnTimes=TurnTimes+o1.C from Orders o join #Temp o1 on o.OrderID=o1.OrderID

drop table #Temp

Update o set TurnTimes=od.C from Orders o join (
select OriginalID,count(AutoID) C  from  Orders where OrderType=2 and OriginalID<>'' group by OriginalID) od on o.OrderID=od.OriginalID  

--材料库存
create table ClientProducts 
(
AutoID int identity(1,1) primary key,
ProductID nvarchar(64),
StockIn decimal(18,4) default 0,
StockOut decimal(18,4) default 0,
LogicOut decimal(18,4) default 0,
ClientID nvarchar(64)
)

insert into ClientProducts(ProductID,StockIn,StockOut,LogicOut,ClientID)
select ProductID,SUM(StockIn),SUM(StockOut), SUM(StockOut),ClientID from ProductStock group by ProductID,ClientID

--材料规格库存
create table ClientProductDetails 
(
AutoID int identity(1,1) primary key,
ProductDetailID nvarchar(64),
ProductID nvarchar(64),
StockIn decimal(18,4) default 0,
StockOut decimal(18,4) default 0,
LogicOut decimal(18,4) default 0,
ClientID nvarchar(64)
)

insert into ClientProductDetails(ProductID,ProductDetailID,StockIn,StockOut,LogicOut,ClientID)
select ProductID,ProductDetailID,SUM(StockIn),SUM(StockOut), SUM(StockOut),ClientID from ProductStock group by ProductDetailID,ProductID,ClientID


--智能工厂客户端和二当家打通内容
alter table Customer add YXAgentID nvarchar(64)
alter table Customer add YXClientID nvarchar(64)
alter table Customer add YXClientCode nvarchar(50)



insert into Menu(MenuCode,Name,Area,Controller,[View],IcoPath,IcoHover,Type,IsHide,PCode,Sort,Layer,IsMenu,IsLimit,Remark) 
values ('203010500','工量统计','','Orders','UserLoadReport','','',1,0,'102010000',4,3,1,1,'')

--订单款式规格
create table OrderAttrs
(
AutoID int identity(1,1),
OrderAttrID nvarchar(64) primary key,
OrderID nvarchar(64),
GoodsID nvarchar(64),
AttrName nvarchar(100),
AttrType int,
Price decimal(18,4) default 0,
FinalPrice decimal(18,4) default 0,
Sort int default 0
)

--大货下单表
alter table OrderGoods add Sort int default 0

--制版属性
insert into OrderAttrs(OrderAttrID,OrderID,GoodsID,AttrName,AttrType,Price,FinalPrice)
select NEWID(),o.OriginalID,g.GoodsID,XRemark,1,0,0 from OrderGoods g join Orders o on g.OrderID=o.OrderID 
where o.OriginalID<>''
group by o.OriginalID,XRemark,g.GoodsID 

--规格属性
insert into OrderAttrs(OrderAttrID,OrderID,GoodsID,AttrName,AttrType,Price,FinalPrice)
select NEWID(),o.OriginalID,g.GoodsID,YRemark,2,AVG(g.Price/PlanQuantity),AVG(g.Price/PlanQuantity) from OrderGoods g join Orders o on g.OrderID=o.OrderID 
where o.OriginalID<>''
group by o.OriginalID,YRemark,g.GoodsID 

--材料关联规格
alter table OrderDetail add OrderAttrID nvarchar(64)
alter table OrderDetail add SalesAttr nvarchar(100)

--处理只有一种颜色的打样单材料
update d set OrderAttrID=o.OrderAttrID,SalesAttr=o.AttrName from OrderAttrs o join OrderDetail d on o.OrderID=d.OrderID
where o.AttrType=2 and o.OrderID in
(select OrderID from OrderAttrs where AttrType=2 group by OrderID having count(0)=1)

--处理多种颜色打样单材料
update d set OrderAttrID=o.OrderAttrID,SalesAttr=o.AttrName from OrderAttrs o join OrderDetail d on o.OrderID=d.OrderID
where o.AttrType=2 and o.AutoID in
(select MAX(AutoID) from OrderAttrs where AttrType=2 group by OrderID having count(0)>1)

--尺码排序问题
update OrderAttrs set Sort=0
GO
update o set Sort=a.Sort from OrderAttrs o join AttrValue a on o.AttrName='【'+a.ValueName+'】'
where o.AttrType=1 and a.Status=1
GO
update o set Sort=a.Sort from OrderAttrs o join AttrValue a on o.AttrName='【'+a.ValueName+'】'
where o.AttrType=1 and a.Status=9 and o.Sort=0
GO
update OrderAttrs set Sort=999 where Sort=0 and AttrType=1

--大货单尺码排序问题
update OrderGoods set Sort=0
GO
update o set Sort=a.Sort from OrderGoods o join AttrValue a on o.XRemark='【'+a.ValueName+'】'
where  a.Status=1
GO
update o set Sort=a.Sort from OrderGoods o join AttrValue a on o.XRemark='【'+a.ValueName+'】'
where  a.Status=9 and o.Sort=0
GO
update OrderGoods set Sort=999 where Sort=0 

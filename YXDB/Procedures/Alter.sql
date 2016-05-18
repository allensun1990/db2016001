alter table GoodsDoc add Quantity int default 0

update GoodsDoc set Quantity=0

update g set Quantity=d.Quantity from GoodsDoc g join
(select DocID,SUM(Quantity) Quantity from GoodsDocDetail group by DocID) d on g.DocID=d.DocID




--流程阶段

alter table orderprocess add CategoryType int default 1
update orderprocess set CategoryType=1

update OrderStage set Mark=11 where Mark=1
update OrderStage set Mark=12 where Mark=2
update OrderStage set Mark=21 where Mark=3

update OrderTask set Mark=11 where Mark=1
update OrderTask set Mark=12 where Mark=2
update OrderTask set Mark=21 where Mark=3

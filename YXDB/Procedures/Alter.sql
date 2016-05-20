

--流程阶段
alter table orderprocess add CategoryType int default 1
update orderprocess set CategoryType=1

update OrderStage set Mark=11 where Mark=1
update OrderStage set Mark=12 where Mark=2
update OrderStage set Mark=21 where Mark=3

update OrderTask set Mark=11 where Mark=1
update OrderTask set Mark=12 where Mark=2
update OrderTask set Mark=21 where Mark=3

--材料耗损率
alter table OrderDetail add LossRate decimal(18,4) default 0
update OrderDetail set LossRate=Loss/Quantity

--引导步骤
alter table Clients add GuideStep int default 1
update Clients set GuideStep=1

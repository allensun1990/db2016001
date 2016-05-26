
--流程变更
alter table [OrderStage] add MaxHours int default 0
GO
update [OrderStage] set MaxHours=0

--任务增加完成小时数
alter table OrderTask add MaxHours int default 0
GO
update OrderTask set MaxHours=0
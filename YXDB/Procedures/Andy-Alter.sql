

alter table ordertask add LockStatus int default 0 not null

update ordertask set LockStatus=1 where FinishStatus=2
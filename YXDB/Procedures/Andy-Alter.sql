


insert into Menu
select '108020900','标签设置',Area,Controller,'LabelSet',IcoPath,IcoHover,Type,IsHide,PCode,8,Layer,IsMenu,IsLimit,Remark from Menu
where AutoID=183

alter table orders add YXOrderID nvarchar(64) null







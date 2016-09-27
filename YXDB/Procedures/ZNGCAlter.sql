
--insert into Menu(MenuCode,Name,Area,Controller,[View],IcoPath,IcoHover,Type,IsHide,PCode,Sort,Layer,IsMenu,IsLimit,Remark) 
--values ('203010500','工量统计','','Orders','UserLoadReport','','',1,0,'102010000',4,3,1,1,'')

alter table StorageDoc add ProgressStatus int default 0
GO
Update StorageDoc set ProgressStatus=0

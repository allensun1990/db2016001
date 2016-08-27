
update t set CreateUserID=g.CreateUserID,OwnerID=g.OwnerID from GoodsDoc g join GoodsDoc t on g.DocID=t.OriginalID


insert into Menu(MenuCode,Name,Area,Controller,[View],IcoPath,IcoHover,Type,IsHide,PCode,Sort,Layer,IsMenu,IsLimit,Remark) 
values ('203010500','工量统计','','Orders','UserLoadReport','','',1,0,'102010000',4,3,1,1,'')

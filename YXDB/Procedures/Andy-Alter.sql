

alter table PlateMaking alter  column Remark varchar(500)

insert into Menu
values('206000000','帮助中心','','HelpCenter','Contents',
'','',2,0,
'100000000',6,1,1,1,'')

insert into Menu
values('206010000','分类管理','','HelpCenter','Types',
'','',2,0,
'206000000',1,2,1,1,'')

insert into Menu
values('206010100','添加分类','','HelpCenter','AddType',
'','',2,0,
'206010000',1,3,1,1,'')

insert into Menu
values('206010200','分类列表','','HelpCenter','Types',
'','',2,0,
'206010000',2,3,1,1,'')


insert into Menu
values('206020000','内容管理','','HelpCenter','Contents',
'','',2,0,
'206000000',2,2,1,1,'')

insert into Menu
values('206020100','添加内容','','HelpCenter','AddContent',
'','',2,0,
'206020000',1,3,1,1,'')

insert into Menu
values('206020200','内容列表','','HelpCenter','Contents',
'','',2,0,
'206020000',2,3,1,1,'')



alter table orders add IsPublic int default(0)








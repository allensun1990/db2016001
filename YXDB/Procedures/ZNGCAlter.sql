
--SP

R_GetUserTaskQuantity
R_GetOrderProductionRPT
R_GetUserWorkloadDate

insert into Menu(MenuCode,Name,Area,Controller,[View],IcoPath,IcoHover,Type,IsHide,PCode,Sort,Layer,IsMenu,IsLimit,Remark)
values('105030300','车缝量统计','','Report','UserSewnReport','','',1,0,'105030000',2,3,1,1,'')

update Menu set Name='裁片量统计',[View]='UserCutReport' where MenuCode='105030200'








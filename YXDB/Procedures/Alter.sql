
alter table [dbo].[M_Users] DROP CONSTRAINT UQ__M_Users__DB8464FF5165187F  

update GoodsDetail set Description='['+Description+']'
update GoodsDetail set Description=REPLACE(Description,',','] [')
update GoodsDetail set Description=REPLACE(Description,':','：')

update OrderGoods set Remark='['+Remark+']'
update OrderGoods set Remark=REPLACE(Remark,',','] [')
update OrderGoods set Remark=REPLACE(Remark,':','：')


--处理菜单和权限
insert into RolePermission(RoleID,MenuCode,CreateTime,CreateUserID,ClientID)
select RoleID,'102010600',CreateTime,CreateUserID,ClientID from RolePermission where MenuCode='102010100'
insert into RolePermission(RoleID,MenuCode,CreateTime,CreateUserID,ClientID)
select RoleID,'102010700',CreateTime,CreateUserID,ClientID from RolePermission where MenuCode='102010100'
insert into RolePermission(RoleID,MenuCode,CreateTime,CreateUserID,ClientID)
select RoleID,'102010800',CreateTime,CreateUserID,ClientID from RolePermission where MenuCode='102010100'

insert into RolePermission(RoleID,MenuCode,CreateTime,CreateUserID,ClientID)
select RoleID,'102010601',CreateTime,CreateUserID,ClientID from RolePermission where MenuCode='102010300'
insert into RolePermission(RoleID,MenuCode,CreateTime,CreateUserID,ClientID)
select RoleID,'102010701',CreateTime,CreateUserID,ClientID from RolePermission where MenuCode='102010300'
insert into RolePermission(RoleID,MenuCode,CreateTime,CreateUserID,ClientID)
select RoleID,'102010801',CreateTime,CreateUserID,ClientID from RolePermission where MenuCode='102010300'

delete from RolePermission where MenuCode in ('103029001','103029003','103030301','103030303','103030401','103030403','108020702',
											 '108020703','108020301','108020302','108020303','102010100','102010300','109000000','109010000','109010100','109010300',
											 '102019029','102019030','102019031','102019032','102019013','102019033','102019014','102019015','102019016',
											'102019017','102019021','102019023','102019006','102019022','102010503','102019003','102019005','102019007',
											'102019010','102019011','102019012','102019018','102019019','102019020','102019024','102019025','102019026',
											'102019027','102019028','102019035')

--处理制版工艺类型名称
alter table PlateMaking add TypeName nvarchar(50)
GO
update PlateMaking set TypeName='裁剪' where Type=1
update PlateMaking set TypeName='粘衬' where Type=2
update PlateMaking set TypeName='缝制工艺' where Type=3
update PlateMaking set TypeName='成衣整烫' where Type=4
update PlateMaking set TypeName='成衣检验' where Type=5
update PlateMaking set TypeName='成品包装' where Type=6

--客户讨论表
alter table CustomerReply add ClientID nvarchar(64)
--GO
Update c set ClientID=u.ClientID from CustomerReply c join users u on c.CreateUserID=u.UserID

--订单讨论表
alter table OrderReply add ClientID nvarchar(64)
--GO
Update c set ClientID=u.ClientID from OrderReply c join users u on c.CreateUserID=u.UserID

--同步工厂人数和到期时间
update C set EndTime=a.EndTime,UserQuantity=a.UserQuantity from agents a join Clients c on a.ClientID=c.ClientID


--处理下单明细remark
Update OrderGoods set Remark=REPLACE(Remark,':','：')
Update OrderGoods set Remark=REPLACE(Remark,'[','【')
Update OrderGoods set Remark=REPLACE(Remark,']','】')
Update OrderGoods set Remark=REPLACE(Remark,' ','')
GO
alter table OrderGoods add XRemark nvarchar(200)
alter table OrderGoods add YRemark nvarchar(200)
alter table OrderGoods add XYRemark nvarchar(200)
GO
update OrderGoods set XYRemark=Remark,XRemark=Remark,YRemark=Remark
Update OrderGoods set XYRemark=REPLACE(XYRemark,'尺码：','')
Update OrderGoods set XYRemark=REPLACE(XYRemark,'颜色：','')
update OrderGoods set XRemark=XYRemark,YRemark=XYRemark

update o set o.XRemark='【'+v.ValueName+'】' from AttrValue v join OrderGoods o on o.XRemark like('%【'+v.ValueName+'】%')  
where AttrID='c6ced2c2-4808-474b-a301-ab56a751858a'

update OrderGoods set XRemark='【XXL】' where XRemark like('%【XXL】%')  

update OrderGoods set YRemark=REPLACE(YRemark,XRemark,'')


---处理成品明细Description
Update GoodsDetail set Description=REPLACE(Description,':','：')
Update GoodsDetail set Description=REPLACE(Description,'[','【')
Update GoodsDetail set Description=REPLACE(Description,']','】')
Update GoodsDetail set Description=REPLACE(Description,' ','')

--处理材料明细Description
Update ProductDetail set Description=REPLACE(Description,':','：')
Update ProductDetail set Description=REPLACE(Description,'[','【')
Update ProductDetail set Description=REPLACE(Description,']','】')
Update ProductDetail set Description=REPLACE(Description,' ','')

--处理购物车明细remark
Update ShoppingCart set Remark=REPLACE(Remark,':','：')
Update ShoppingCart set Remark=REPLACE(Remark,'[','【')
Update ShoppingCart set Remark=REPLACE(Remark,']','】')
Update ShoppingCart set Remark=REPLACE(Remark,' ','')

--处理订单材料明细remark
Update OrderDetail set Remark=REPLACE(Remark,':','：')
Update OrderDetail set Remark=REPLACE(Remark,'[','【')
Update OrderDetail set Remark=REPLACE(Remark,']','】')
Update OrderDetail set Remark=REPLACE(Remark,' ','')

--处理裁片明细remark
Update GoodsDocDetail set Remark=REPLACE(Remark,':','：')
Update GoodsDocDetail set Remark=REPLACE(Remark,'[','【')
Update GoodsDocDetail set Remark=REPLACE(Remark,']','】')
Update GoodsDocDetail set Remark=REPLACE(Remark,' ','')

--处理采购明细remark
Update StorageDetail set Remark=REPLACE(Remark,':','：')
Update StorageDetail set Remark=REPLACE(Remark,'[','【')
Update StorageDetail set Remark=REPLACE(Remark,']','】')
Update StorageDetail set Remark=REPLACE(Remark,' ','')

--购物车单位名称冗余
alter table ShoppingCart add UnitName nvarchar(20)
--GO
update s  set UnitName=u.UnitName from ShoppingCart s join ProductUnit u on s.UnitID=u.UnitID  

--Orders 表 PlanPrice 改为 decimal 类型
alter table Orders alter column PlanPrice decimal(18,4)
--GO
alter table Orders add YXOrderID nvarchar(64) null
--GO

--处理批次信息
select ProductDetailID,ProductID,WareID,DepotID,ClientID,SUM(StockIn) StockIn,sum(StockOut) StockOut into #tempstock from ProductStock 
group by ProductDetailID,ProductID,WareID,DepotID,ClientID
--GO
truncate table ProductStock
--GO
insert into ProductStock(ProductDetailID,ProductID,WareID,DepotID,ClientID,StockIn,StockOut)
select ProductDetailID,ProductID,WareID,DepotID,ClientID,StockIn,StockOut from #tempstock
--Go
Drop table #tempstock

--注册来源
alter table Clients add RegisterType int default 0
--GO
update Clients set RegisterType=1
Update Clients set RegisterType=3 where AliMemberID<>'' and  AliMemberID is not null

--用户名
insert into UserAccounts(AccountName,AccountType,ProjectID,UserID,ClientID)
select LoginName,1,'',UserID,ClientID from Users where LoginName is not null and LoginName<>''

--手机账号
insert into UserAccounts(AccountName,AccountType,ProjectID,UserID,ClientID)
select BindMobilePhone,2,'',UserID,ClientID from Users where BindMobilePhone is not null and BindMobilePhone<>''

--阿里账号
insert into UserAccounts(AccountName,AccountType,ProjectID,UserID,ClientID)
select AliMemberID,3,'',UserID,ClientID from Users where AliMemberID is not null and AliMemberID<>''

--微信账号 
insert into UserAccounts(AccountName,AccountType,ProjectID,UserID,ClientID)
select WeiXinID,4,'',UserID,ClientID from Users where WeiXinID is not null and WeiXinID<>''

--处理流程和品类 CategoryID 需要更改
alter table OrderProcess add CategoryID nvarchar(64)
--GO
update OrderProcess set CategoryID='4902b471-7f9a-42a2-b892-14caabe14ec2' where CategoryType=1 and Status<>9
update OrderProcess set CategoryID='54d1c8bd-bb7c-45d8-a9c1-8c8b6974c221' where CategoryType=2 and Status<>9
--GO
truncate table OrderCategory
--GO
insert into OrderCategory (CategoryID,ClientID,Layers,PID) 
select CategoryID,ClientID,1,'' from OrderProcess where CategoryID is not null and CategoryID<>'' group by CategoryID,ClientID 
--GO
update o set BigCategoryID=p.CategoryID from Orders o join OrderProcess p on o.ProcessID=p.ProcessID


--任务和订单阶段mark处理
Update OrderTask set Mark=Mark%10+10 where Mark>0
Update OrderStage set Mark=Mark%10+10 where Mark>0

--处理待大货为需求单
Update Orders set OrderStatus=0,Status=0 where Status=4
--GO
update Customer set DYCount=0,DHCount=0,DemandCount=0
--GO
update C set DemandCount=o.Quantity from Customer c join
(select CustomerID,COUNT(AutoID) Quantity from Orders where OrderStatus=0 group by CustomerID) o on c.CustomerID=o.CustomerID

update C set DYCount=o.Quantity from Customer c join
(select CustomerID,COUNT(AutoID) Quantity from Orders where OrderStatus>0 and OrderStatus<>9 and OrderType=1 group by CustomerID) o on c.CustomerID=o.CustomerID

update C set DHCount=o.Quantity from Customer c join
(select CustomerID,COUNT(AutoID) Quantity from Orders where OrderStatus>0 and OrderStatus<>9 and OrderType=2 group by CustomerID) o on c.CustomerID=o.CustomerID

--处理订单单据表
alter table GoodsDoc add OrderID nvarchar(64) 
alter table GoodsDoc add OrderCode nvarchar(64)
Go
Update GoodsDoc set OrderID=OriginalID,OrderCode=OriginalCode
Update GoodsDoc set OriginalID='',OriginalCode=''

alter table GoodsDocDetail add ReturnQuantity int default 0
Go
Update GoodsDocDetail set ReturnQuantity=0

--订单材料增加数据
alter table OrderDetail add PurchaseQuantity decimal(18,4) default 0
alter table OrderDetail add InQuantity decimal(18,4) default 0
alter table OrderDetail add UseQuantity decimal(18,4) default 0

Go
Update OrderDetail set PurchaseQuantity=0
Update OrderDetail set InQuantity=0
Update OrderDetail set UseQuantity=0

--处理订单发货总数
alter table Orders add SendQuantity int default 0
GO
Update Orders set SendQuantity=0

update o set SendQuantity=t.Quantity from Orders o join
(select OrderID,SUM(SendQuantity) Quantity from OrderGoods group by OrderID) t on o.OrderID=t.OrderID

update Orders set TotalMoney=SendQuantity*FinalPrice




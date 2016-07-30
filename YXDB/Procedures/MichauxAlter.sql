
--删除表
drop table Agents
drop table dbo.AgentsAccounts
drop table dbo.AgentsOrderDetail
drop table dbo.AgentsOrders
drop table dbo.AgentsStock
drop table dbo.AgentsStream
drop table OrderType
drop table CustomSource
drop table Activity
drop table ActivityReply
drop table CustomerStageLog
drop table Brand
drop table ProductImg
drop table StorageDocAction
drop table CustomerPool
drop table CustomerOwner
drop table OrderTaskPlateAttr
drop table Billing
drop table OrderUser
drop table OrderStageLog
drop table CustomStage
drop table OrderImg

--删除列
--删除购物车批次
alter table ShoppingCart drop constraint DF_ShoppingCart_BatchCode
GO
alter table ShoppingCart drop column BatchCode

alter table ShoppingCart drop column IsBigUnit

--删除用户表字段
alter table Users drop constraint DF_Users_LoginName
GO
alter table Users drop column LoginName

alter table Users drop constraint DF_Users_MDUserID
GO
alter table Users drop column MDUserID

alter table Users drop constraint DF_Users_MDProjectID
GO
alter table Users drop column MDProjectID

alter table Users drop constraint DF__Users__AliMember__00E0B825
GO
alter table Users drop column AliMemberID

alter table Users drop constraint DF_Users_BindMobilePhone
GO
alter table Users drop column BindMobilePhone

alter table Users drop column WeiXinID

--分类
alter table Category drop constraint DF__C_Categor__Brand__4AD81681
GO
alter table Category drop column BrandList

--删除材料表
EXEC  sp_rename   'Products.SmallUnitID' , 'UnitID'
Go
alter table Products drop constraint DF__C_Product__IsCom__2F9A1060
GO
alter table Products drop column IsCombineProduct

alter table Products drop constraint DF__C_Product__Brand__308E3499
GO
alter table Products drop column BrandID

alter table Products drop constraint DF__C_Product__BigUn__318258D2
GO
alter table Products drop column BigUnitID

alter table Products drop constraint DF__C_Product__BigSm__336AA144
GO
alter table Products drop column BigSmallMultiple

alter table Products drop constraint DF__C_Product__Prefe__3BFFE745
GO
alter table Products drop column PV

alter table Products drop constraint DF__C_Product__Onlin__3EDC53F0
GO
alter table Products drop column OnlineTime

alter table Products drop constraint DF__C_Product__UseTy__3FD07829
GO
alter table Products drop column UseType

alter table Products drop constraint DF__C_Product__IsNew__40C49C62
GO
alter table Products drop column IsNew

alter table Products drop DF__C_Product__IsRec__41B8C09B 
GO
alter table Products drop column IsRecommend

alter table Products drop DF_Products_IsAutoSend 
GO
alter table Products drop column IsAutoSend

--删除材料明细表
Go
alter table ProductDetail drop constraint DF_ProductDetail_BigPrice
GO
alter table ProductDetail drop column BigPrice

alter table ProductDetail drop constraint DF__C_ProductD__ImgM__6B44E613
GO
alter table ProductDetail drop column ImgM

--删除成品表
EXEC  sp_rename   'Goods.SmallUnitID' , 'UnitID'
Go
alter table Goods drop constraint DF_Goods_AliGoodsCode
GO
alter table Goods drop column AliGoodsCode

alter table Goods drop constraint DF__C_Good__Brand__308E3499
GO
alter table Goods drop column BrandID

alter table Goods drop constraint DF__C_Good__BigUn__318258D2
GO
alter table Goods drop column BigUnitID

alter table Goods drop constraint DF__C_Good__BigSm__336AA144
GO
alter table Goods drop column BigSmallMultiple

alter table Goods drop constraint DF__C_Good__Prefe__3BFFE745
GO
alter table Goods drop column PV

alter table Goods drop constraint DF__C_Good__Onlin__3EDC53F0
GO
alter table Goods drop column OnlineTime

alter table Goods drop constraint DF__C_Good__UseTy__3FD07829
GO
alter table Goods drop column UseType

alter table Goods drop DF_Goods_IsAutoSend 
GO
alter table Goods drop column IsAutoSend

alter table Goods drop DF__C_Good__Prodi__4959E263 
GO
alter table Goods drop column ProdiverID 

--删除成品明细表
Go
alter table GoodsDetail drop constraint DF_Goods_AliGoodsCode
GO
alter table GoodsDetail drop column BigPrice

alter table GoodsDetail drop constraint DF__C_Goods__ImgM__6B44E613
GO
alter table GoodsDetail drop column ImgM

--删除材料库存表
Go
alter table ProductStock drop constraint DF__C_Product__Batch__634EBE90
GO
alter table ProductStock drop column BatchCode

--删除材料流水
Go
alter table ProductStream drop constraint DF__C_Product__Batch__0A688BB1
GO
alter table ProductStream drop column BatchCode

--删除单据明细表
EXEC  sp_rename   'StorageDetail.ProdiverID' , 'ProviderID'
Go
alter table StorageDetail drop constraint DF_StorageDetail_IsBigUnit
GO
alter table StorageDetail drop column IsBigUnit

alter table StorageDetail drop constraint DF__C_Storage__Batch__251C81ED
GO
alter table StorageDetail drop column BatchCode 

--删除裁片明细表
Go
alter table GoodsDoc drop constraint DF__C_Goods__Prodi__2EA5EC27
GO
alter table GoodsDoc drop column ProviderID 

--删除成品明细表
Go
alter table GoodsDocDetail drop constraint DF__C_Goods__Prodi__2EA5EC27
GO
alter table GoodsDocDetail drop column ProdiverID 

--删除客户表
Go
alter table Customer drop constraint DF__Customer__Activi__1B88F612
GO
alter table Customer drop column ActivityID 

alter table Customer drop constraint DF__C_Goods__ImgM__6B44E613
GO
alter table Customer drop column StageID

alter table Customer drop constraint DF__C_Good__BigUn__318258D2
GO
alter table Customer drop column ChildStageID

alter table Customer drop constraint DF__C_Good__BigSm__336AA144
GO
alter table Customer drop column AllocationTime

alter table Customer drop constraint DF__C_Good__Prefe__3BFFE745
GO
alter table Customer drop column OrderTime

--删除订单表
Go
alter table Orders drop constraint DF_Orders_TypeID
GO
alter table Orders drop column TypeID 

alter table Orders drop constraint DF_Orders_StageID
GO
alter table Orders drop column StageID

alter table Orders drop constraint DF_Orders_PlanType
GO
alter table Orders drop column PlanType

alter table Orders drop constraint DF_Orders_ReplyTimes
GO
alter table Orders drop column ReplyTimes

alter table Orders drop constraint DF__C_Good__Prefe__3BFFE745
GO
alter table Orders drop column AuditTime

alter table Orders drop constraint DF__Orders__UpdateTi__5986288B
GO
alter table Orders drop column UpdateTime

alter table Orders drop constraint DF__Orders__OperateI__5A7A4CC4
GO
alter table Orders drop column OperateIP

alter table Orders drop DF_Goods_IsAutoSend 
GO
alter table Orders drop column PlateRemark

--删除订单材料表
EXEC  sp_rename   'OrderDetail.ProdiverID' , 'ProviderID'
Go
alter table OrderDetail drop constraint DF__OrderDeta__IsBig__220B0B18
GO
alter table OrderDetail drop column IsBigUnit 

alter table OrderDetail drop constraint DF__OrderDeta__TaxMo__25DB9BFC
GO
alter table OrderDetail drop column TaxMoney

alter table OrderDetail drop constraint DF__OrderDeta__TaxRa__26CFC035
GO
alter table OrderDetail drop column TaxRate

alter table OrderDetail drop constraint DF__OrderDeta__LossR__78A077DF
GO
alter table OrderDetail drop column LossRate

alter table OrderDetail drop constraint DF_OrderDetail_ApplyQuantity
GO
alter table OrderDetail drop column ApplyQuantity

alter table OrderDetail drop constraint DF__OrderDeta__Retur__27C3E46E
GO
alter table OrderDetail drop column ReturnQuantity

alter table OrderDetail drop constraint DF__OrderDeta__Retur__28B808A7
GO
alter table OrderDetail drop column ReturnPrice

alter table OrderDetail drop DF__OrderDeta__Retur__29AC2CE0 
GO
alter table OrderDetail drop column ReturnMoney

alter table OrderDetail drop DF_OrderDetail_BigSmallMultiple 
GO
alter table OrderDetail drop column BigSmallMultiple

alter table OrderDetail drop DF__OrderDeta__Batch__2C88998B 
GO
alter table OrderDetail drop column BatchCode 

alter table OrderDetail drop DF__OrderDeta__Batch__2C88998B 
GO
alter table OrderDetail drop column BatchCode 

--删除订单下单明细表
Go
alter table OrderGoods drop constraint DF__OrderGoods__IsBig__220B0B18
GO
alter table OrderGoods drop column IsBigUnit 

alter table OrderGoods drop constraint DF__OrderGoods__TaxMo__25DB9BFC
GO
alter table OrderGoods drop column TaxMoney

alter table OrderGoods drop constraint DF__OrderGoods__TaxRa__26CFC035
GO
alter table OrderGoods drop column TaxRate

alter table OrderGoods drop constraint DF__OrderGoods__Retur__28B808A7
GO
alter table OrderGoods drop column ReturnPrice

alter table OrderGoods drop constraint DF_OrderGoods_BigSmallMultiple
GO
alter table OrderGoods drop column BigSmallMultiple

alter table OrderGoods drop constraint DF__OrderGoods__WareI__2AA05119
GO
alter table OrderGoods drop column WareID

alter table OrderGoods drop constraint DF__OrderGoods__Depot__2B947552
GO
alter table OrderGoods drop column DepotID   

alter table OrderGoods drop DF__OrderGoods__Batch__2C88998B 
GO
alter table OrderGoods drop column BatchCode  


--删除所有AgentID
alter table dbo.AliOrderDownloadLog drop column AgentID
alter table dbo.AliOrderDownloadPlan drop column AgentID
alter table dbo.AliOrderUpdateLog drop column AgentID
alter table Clients drop column AgentID
alter table dbo.BillingInvoice drop column AgentID
alter table dbo.BillingPay drop column AgentID
alter table dbo.ClientAccounts drop column AgentID
alter table dbo.ClientAuthorizeLog drop column AgentID
alter table dbo.ClientOrder drop column AgentID
alter table dbo.Contact drop column AgentID
alter table dbo.Customer drop column AgentID
alter table dbo.CustomerColor drop column AgentID
alter table dbo.CustomerLog drop column AgentID
alter table dbo.CustomerReply drop column AgentID
GO
alter table Log_Action drop constraint DF__Log_Actio__Agent__3DFE09A7
alter table dbo.Log_Action drop column AgentID
GO
alter table Log_Login drop constraint DF_Log_Login_AgentID
alter table dbo.Log_Login drop column AgentID
GO
alter table M_Report_AgentAction_Day drop constraint DF_M_Report_AgentAction_Day_AgentID
alter table dbo.M_Report_AgentAction_Day drop column AgentID
GO
alter table dbo.OperateLog drop column AgentID
alter table dbo.OrderColor drop column AgentID
alter table dbo.OrderReply drop column AgentID
alter table dbo.Orders drop column AgentID
alter table dbo.OrdersLog drop column AgentID
alter table dbo.OrderTask drop column AgentID
alter table dbo.OrderTaskLog drop column AgentID
alter table dbo.Report_AgentAction_Day drop column AgentID
alter table dbo.Report_AgentLogin_Day drop column AgentID
alter table dbo.Role drop column AgentID
alter table dbo.StorageBilling drop column AgentID
alter table dbo.TaskColor drop column AgentID
alter table dbo.TaskMember drop column AgentID
alter table dbo.Teams drop column AgentID
alter table dbo.Users drop column AgentID

--删除所有存储过程
--SELECT identity(int ,1,1) as  id , name Into #table FROM sysobjects  WHERE (xtype = 'p')
--declare @tablename nvarchar(100), @execSQL nvarchar(300), @id int, @count int
--select @count=max(id) from #table
--set @id=1
--while @id<=@count
--begin
--	select @tablename=[name] from #table where id=@id
--	set @id=@id+1
--	set @execSQL =' drop Procedure '+ @tablename
--	exec (@execSQL)
--end
--drop table #table
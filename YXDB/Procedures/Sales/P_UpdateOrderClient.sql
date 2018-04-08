Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderClient')
BEGIN
	DROP  Procedure  P_UpdateOrderClient
END

GO
/***********************************************************
过程名称： P_UpdateOrderClient
功能描述： 更换订单流程
参数说明：	 
编写日期： 2016/3/6
程序作者： Allen
调试记录： exec P_UpdateOrderClient 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderClient]
	@OrderID nvarchar(64),
	@NewClientID nvarchar(64),
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS

if(@NewClientID=@ClientID)
begin
	return
end
	
begin tran

declare @Err int=0,@Status int=-1,@OrderType int,@OwnerID nvarchar(64),@ProcessID nvarchar(64),@CategoryID nvarchar(64)

select @Status=OrderStatus,@OrderType=OrderType,@CategoryID=BigCategoryID from Orders where OrderID=@OrderID and ClientID=@ClientID

if(@Status<>0)
begin
	rollback tran
	return
end


select @OwnerID=OwnerID,@ProcessID=ProcessID from OrderProcess where ClientID=@NewClientID and ProcessType=@OrderType and CategoryID=@CategoryID and IsDefault=1

Update Orders set ProcessID=@ProcessID,OwnerID=@OwnerID,EntrustClientID=@NewClientID,EntrustStatus=1,EntrustTime=getdate() where OrderID=@OrderID and ClientID=@ClientID

--处理协作工厂

declare @GoodsNum int=0,@OrderNum int=0
if(@OrderType=1)
begin
	set @GoodsNum=1
end
else
begin
	set @OrderNum=1
end

if exists(select * from ProviderClient where ClientID=@ClientID and ProviderClientID=@NewClientID)
begin
	update ProviderClient set GoodsNum=GoodsNum+@GoodsNum,OrderNum=OrderNum+@OrderNum where ClientID=@ClientID and ProviderClientID=@NewClientID
end
else
begin
	insert into ProviderClient(ClientID,ProviderClientID,GoodsNum,OrderNum,CreateTime,LastTime)
	values(@ClientID,@NewClientID,@GoodsNum,@OrderNum,getdate(),getdate())
end

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 


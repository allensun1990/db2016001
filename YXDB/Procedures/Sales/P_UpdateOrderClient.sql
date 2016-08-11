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

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 


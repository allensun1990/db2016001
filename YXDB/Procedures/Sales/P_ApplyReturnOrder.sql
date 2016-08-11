Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_ApplyReturnOrder')
BEGIN
	DROP  Procedure  P_ApplyReturnOrder
END

GO
/***********************************************************
过程名称： P_ApplyReturnOrder
功能描述： 退回委托
参数说明：	 
编写日期： 2016/3/6
程序作者： Allen
调试记录： exec P_ApplyReturnOrder 
************************************************************/
CREATE PROCEDURE [dbo].[P_ApplyReturnOrder]
	@OrderID nvarchar(64),
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)='',
	@Result int output
AS
	
begin tran

set @Result=0

--订单信息
declare @Err int=0,@Status int=-1,@OrderType nvarchar(64),@OldClientID nvarchar(64),@ProcessID nvarchar(64),@OwnerID nvarchar(64),@CategoryID nvarchar(64)

select @Status=Status,@OrderType=OrderType,@OldClientID=ClientID,@CategoryID=BigCategoryID from Orders where OrderID=@OrderID and (ClientID=@ClientID or EntrustClientID=@ClientID)

if(@Status<>0)
begin
	rollback tran
	return
end


select @OwnerID=OwnerID,@ProcessID=ProcessID from OrderProcess where ClientID=@OldClientID and CategoryID=@CategoryID and ProcessType=@OrderType and IsDefault=1

Update Orders set ProcessID=@ProcessID,OwnerID=@OwnerID,EntrustClientID='',EntrustStatus=2 where OrderID=@OrderID

if(@Err>0)
begin
	rollback tran
end 
else
begin
	set @Result=1
	commit tran
end

 


 


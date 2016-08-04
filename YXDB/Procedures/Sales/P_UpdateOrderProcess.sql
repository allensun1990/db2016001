Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderProcess')
BEGIN
	DROP  Procedure  P_UpdateOrderProcess
END

GO
/***********************************************************
过程名称： P_UpdateOrderProcess
功能描述： 更换订单流程
参数说明：	 
编写日期： 2016/2/19
程序作者： Allen
调试记录： exec P_UpdateOrderProcess 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderProcess]
	@OrderID nvarchar(64),
	@CategoryID nvarchar(64),
	@ProcessID nvarchar(64),
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int,@OwnerID nvarchar(64)
select @Status=Status from Orders where OrderID=@OrderID  and ClientID=@ClientID

if(@Status<>0)
begin
	rollback tran
	return
end

select @OwnerID=OwnerID from OrderProcess where ProcessID=@ProcessID

Update Orders set ProcessID=@ProcessID,OwnerID=@OwnerID,BigCategoryID=@CategoryID where OrderID=@OrderID

set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 


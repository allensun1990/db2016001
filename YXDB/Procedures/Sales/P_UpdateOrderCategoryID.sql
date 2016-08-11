Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderCategoryID')
BEGIN
	DROP  Procedure  P_UpdateOrderCategoryID
END

GO
/***********************************************************
过程名称： P_UpdateOrderCategoryID
功能描述： 绑定品类
参数说明：	 
编写日期： 2016/3/20
程序作者： Allen
调试记录： exec P_UpdateOrderCategory 
************************************************************/
CREATE PROCEDURE [dbo].[P_UpdateOrderCategoryID]
	@OrderID nvarchar(64),
	@PID nvarchar(64),
	@CategoryID nvarchar(64),
	@OperateID nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS
	
begin tran

declare @Err int=0,@Status int=-1

select @Status=Status from Orders where OrderID=@OrderID and (ClientID=@ClientID or EntrustClientID=@ClientID)

if(@Status<>0)
begin
	rollback tran
	return
end

Update Orders set CategoryID=@CategoryID where OrderID=@OrderID


set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 


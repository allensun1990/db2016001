Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteOrderType')
BEGIN
	DROP  Procedure  P_DeleteOrderType
END

GO
/***********************************************************
过程名称： P_DeleteOrderType
功能描述： 删除订单类型
参数说明：	 
编写日期： 2016/7/8
程序作者： Allen
调试记录： exec P_DeleteOrderType 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteOrderType]
@TypeID nvarchar(64),
@ClientID nvarchar(64)=''
AS

begin tran

declare @Err int=0

if not exists(select AutoID from Orders where ClientID=@ClientID and TypeID=@TypeID and Status<>9)
begin
	update OrderType set Status=9  where ClientID=@ClientID and TypeID=@TypeID
	set @Err+=@@error
end

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end
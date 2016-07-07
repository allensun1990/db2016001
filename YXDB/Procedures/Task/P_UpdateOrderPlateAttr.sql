Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateOrderPlateAttr')
BEGIN
	DROP  Procedure  P_UpdateOrderPlateAttr
END

GO
/***********************************************************
过程名称： P_UpdateOrderPlateAttr
功能描述： 更新订单制版信息
参数说明：	 
编写日期： 2016/5/27
程序作者： MU
调试记录： exec P_UpdateOrderPlateAttr '50a9187a-2535-4f55-8f36-9290b8763085','22','11','',3
************************************************************/
CREATE PROCEDURE [dbo].P_UpdateOrderPlateAttr
@OrderID nvarchar(64),
@Platehtml text
as
	declare @OriginalID nvarchar(64)=''

	select @OriginalID=OriginalID from orders where OrderID=@OrderID
	if(@OriginalID<>'')
	begin
		set @OrderID=@OriginalID
	end

	begin tran
	declare @Err int=0

	update orders set Platemaking=@Platehtml where OrderID=@OrderID
	set @Err+=@@ERROR

	update orders set Platemaking=@Platehtml 
	where OrderID in 
	( 
		select OrderID from Orders
		where OrderType=2 and OriginalID=@OrderID and OrderStatus = 1
	)	
	set @Err+=@@ERROR

	if(@Err>0)
	begin
		rollback tran
	end 
	else
	begin
		commit tran
	end


		 






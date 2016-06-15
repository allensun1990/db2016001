Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_AddClientOrderAccount')
BEGIN
	DROP  Procedure  M_AddClientOrderAccount
END

GO

/***********************************************************
过程名称： M_AddClientOrderAccount
功能描述： 后台订单账目新增
参数说明：	 
编写日期： 2016/05/19
程序作者： Michaux
调试记录： 
************************************************************/
Create proc M_AddClientOrderAccount 
@OrderID nvarchar(64),
@PayType int=3,
@Type int=1,
@RealAmount decimal(18,4)=0.0000,
@ClientID nvarchar(64),
@CreateUserID nvarchar(64),
@Remark nvarchar(500)='',
@Result int output
as
begin
set @Result=-1
if((select COUNT(1) from ClientOrder where Status=1 and OrderID=@OrderID)>0)
begin
declare @payStatus int  set @payStatus=2
	insert into ClientOrderAccount (OrderID,PayType,Type,status,RealAmount,ClientID,CreateUserID,Remark) values
	(@OrderID,@PayType,@Type,1,@RealAmount,@ClientID,@CreateUserID,@Remark)
	if(@Type=1)
	begin
		if((select SUM(RealAmount) from ClientOrderAccount where OrderID=@OrderID and Status=1 group by OrderID )>=(select RealAmount from ClientOrder where Status=1 and OrderID=@OrderID))
		begin
			set @payStatus=1
		end
		update ClientOrder set PayFee=PayFee+@RealAmount,PayStatus=@payStatus where  OrderID=@OrderID
		set @Result=1
	end
	else
	begin
		declare @RefundFee decimal(18,4) declare @PayFee decimal(18,4) 
		set @RefundFee=0.000 set @PayFee=0.0000
		select @RefundFee=RefundFee,@PayFee=PayFee from  ClientOrder  where  OrderID=@OrderID
		set @payStatus=3
		if(@PayFee=(@RefundFee+@RealAmount))
		begin
			set @payStatus=4
		end
		update ClientOrder set RefundFee=RefundFee+@RealAmount,PayStatus=@payStatus where  OrderID=@OrderID
		set @Result=1
	end
end

end
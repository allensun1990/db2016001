Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_PayOrderAndAuthorizeClient')
BEGIN
	DROP  Procedure  M_PayOrderAndAuthorizeClient
END

GO

/***********************************************************
过程名称： M_PayOrderAndAuthorizeClient
功能描述： 后台订单支付及后台客户授权
参数说明：	 
编写日期： 2015/11/24
程序作者： mu
调试记录： exec M_PayOrderAndAuthorizeClient ''
************************************************************/
CREATE PROCEDURE [dbo].[M_PayOrderAndAuthorizeClient]
@M_OrderID nvarchar(64)
AS

begin tran

declare @Err int ,
	@M_ClientID nvarchar(64),@M_AgentID nvarchar(64),
	@UserQuantity int,@Years int,
	@RealAmount decimal(18,3),@Type int,
	@EndTime datetime,@BeginTime datetime,
	@OrderID varchar(64),@OrderCode varchar(20),
	@BillingID varchar(64),@BillingCode varchar(20),
	@YX_AgentID nvarchar(64),@YX_ClientID nvarchar(64)
set @Err=0
--客户订单已支付
if(@M_OrderID<>'' and exists(select OrderID from ClientOrder where OrderID=@M_OrderID and status=1) )
begin
	rollback tran
	return
end

--变量赋值
select @YX_AgentID=AgentID,@YX_ClientID=ClientID from Clients where IsDefault=1

select @M_ClientID=ClientID,@M_AgentID=AgentID,@UserQuantity=UserQuantity,@Years=Years,@RealAmount=RealAmount,@Type=Type from  ClientOrder where OrderID=@M_OrderID

select @BeginTime=EndTime from Agents where AgentID=@M_AgentID

--购买或续费
if(@Type=1 or @Type=3)
begin
	if(@BeginTime<getdate())
	begin
		set @BeginTime=getdate()
	end

	set @EndTime=DATEADD(yy,@Years,@BeginTime);
end
else
	set @EndTime=@BeginTime

set @BillingID=NEWID();
set @BillingCode=replace(replace(replace(CONVERT(varchar, getdate(), 120 ),'-',''),':',''),' ','')+SUBSTRING(convert(varchar,rand()),3,3);
set @OrderID=NEWID();
set @OrderCode=replace(replace(replace(CONVERT(varchar, getdate(), 120 ),'-',''),':',''),' ','')+SUBSTRING(convert(varchar,rand()),3,3);


--新增订单
insert into Orders(OrderID,OrderCode,Status,TotalMoney,CustomerID,AgentID,ClientID,AuditTime,CreateTime) 
values(@OrderID,@OrderCode,2,@RealAmount,@M_ClientID,@YX_AgentID,@YX_ClientID,@BeginTime,getdate())
set @Err+=@@error

--新增账单
insert into Billing(BillingID,BillingCode,OrderID,OrderCode,TotalMoney,Status,PayStatus,PayTime,PayMoney,InvoiceStatus,CreateTime,AgentID,ClientID) 
values(@BillingID,@BillingCode,@OrderID,@OrderCode,@RealAmount,1,2,getdate(),@RealAmount,0,getdate(),@YX_AgentID,@YX_ClientID)
set @Err+=@@error

--新增账单支付明细
insert into BillingPay(BillingID,Type,Status,PayType,PayMoney,PayTime,CreateTime,AgentID,ClientID) 
values(@BillingID,2,1,3,@RealAmount,getdate(),getdate(),@YX_AgentID,@YX_ClientID)
set @Err+=@@error

--更新后台订单状态为支付
update ClientOrder set status=1 where OrderID=@M_OrderID
set @Err+=@@error

--更改代理商客户授权
--购买或续费
if(@Type=1 or @Type=3)
begin
	update Agents set UserQuantity=@UserQuantity,EndTime=@EndTime,AuthorizeType=1 where AgentID=@M_AgentID

	set @Err+=@@error
end
else --购买人数
begin
	update Agents set UserQuantity+=@UserQuantity,AuthorizeType=1 where AgentID=@M_AgentID
	set @Err+=@@error
end

--新增后台代理商授权记录
insert into ClientAuthorizeLog(ClientiD,AgentID,OrderID,UserQuantity,BeginTime,EndTime,SystemType,Type) 
values(@M_ClientID,@M_AgentID,@M_OrderID,@UserQuantity,@BeginTime,@EndTime,2,@Type)
set @Err+=@@error
   

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end
GO



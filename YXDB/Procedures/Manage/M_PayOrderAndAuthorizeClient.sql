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
修改信息: Michaux 2016/05/18  添加审核人审核时间
************************************************************/
CREATE PROCEDURE [dbo].[M_PayOrderAndAuthorizeClient]
@M_OrderID nvarchar(64),
@M_CheckUserID nvarchar(64),
@M_PayStatus int=-1,
@M_PayType int=1
AS

begin tran

declare @Err int ,
	@M_ClientID nvarchar(64),
	@UserQuantity int,@Years int,
	@RealAmount decimal(18,3),@Type int,
	@EndTime datetime,@BeginTime datetime

set @Err=0
--客户订单已支付
if(@M_OrderID<>'' and exists(select OrderID from ClientOrder where OrderID=@M_OrderID and status=1) )
begin
	rollback tran
	return
end

--变量赋值
select @M_ClientID=ClientID,@UserQuantity=UserQuantity,@Years=Years,@RealAmount=RealAmount,@Type=Type from  ClientOrder where OrderID=@M_OrderID

select @BeginTime=EndTime from Clients where ClientID=@M_ClientID

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

--更新后台订单状态为支付
update ClientOrder set status=1,CheckUserID=@M_CheckUserID,CheckTime=getdate(),payStatus=case when @M_PayStatus>-1 then @M_PayStatus else payStatus end  
where OrderID=@M_OrderID
set @Err+=@@error

--支付宝付款
if(@M_PayType=3)
begin
	insert into ClientOrderAccount (OrderID,PayType,Type,status,RealAmount,ClientID,CreateUserID,Remark) values
	(@M_OrderID,@M_PayType,1,1,@RealAmount,@M_ClientID,@M_CheckUserID,'支付宝自动付款')
end

--更改代理商客户授权
--购买或续费
if(@Type=1 or @Type=3)
begin
	update Clients set UserQuantity=@UserQuantity,EndTime=@EndTime,AuthorizeType=1 where ClientID=@M_ClientID

	set @Err+=@@error
end
else --购买人数
begin
	update Clients set UserQuantity+=@UserQuantity,AuthorizeType=1 where ClientID=@M_ClientID
	set @Err+=@@error
end

--新增后台代理商授权记录
insert into ClientAuthorizeLog(ClientiD,OrderID,UserQuantity,BeginTime,EndTime,SystemType,Type) 
values(@M_ClientID,@M_OrderID,@UserQuantity,@BeginTime,@EndTime,2,@Type)
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



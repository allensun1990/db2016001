
Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_InsertIntoFeeChange')
BEGIN
	DROP  Procedure  P_InsertIntoFeeChange
END

GO
/***********************************************************
过程名称： P_InsertIntoFeeChange
功能描述： 会员积分变动记录
参数说明：	 
编写日期： 2016/08/01
程序作者： Michaux
调试记录： exec P_InsertIntoFeeChange 
************************************************************/
create proc P_InsertIntoFeeChange
@ChangFeeType int,
@ChangeFee decimal(18,4),
@CustomerID varchar(50),
@AgentID varchar(50),
@ClientID varchar(50),
@CreateUserID varchar(50),
@Reamrk varchar(500)
as
insert into IntegerFeeChange  
select  @ChangFeeType,@ChangeFee,Customer.IntegerFee+@ChangeFee,GETDATE(),@CreateUserID,@CustomerID,@AgentID,@ClientID,@Reamrk
from Customer where CustomerID=@CustomerID
return SCOPE_IDENTITY()
 
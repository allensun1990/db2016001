Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_SetCustomerYXinfo')
BEGIN
	DROP  Procedure  P_SetCustomerYXinfo
END

GO
/***********************************************************
过程名称： P_SetCustomerYXinfo
功能描述： 关联客户与二当家联系
参数说明：	 
编写日期： 2016/7/8
程序作者： MU
调试记录： exec P_SetCustomerYXinfo 
************************************************************/
CREATE PROCEDURE [dbo].[P_SetCustomerYXinfo]
	@CustomerID nvarchar(64)='',
	@YXAgentID nvarchar(64)='',
	@YXClientID nvarchar(64)='',
	@YXClientCode nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS

if( exists( select CustomerID from Customer where ClientID=@ClientID and CustomerID=@CustomerID and YXClientCode<>'' ) )
	return

begin tran
declare @Err int

	update Customer set @YXAgentID=@YXAgentID,@YXClientID=@YXClientID,@YXClientCode=@YXClientCode
	where ClientID=@ClientID and CustomerID=@CustomerID
	set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


 


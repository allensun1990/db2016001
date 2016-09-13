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
修改记录： Michaux 2016-09-01  解决二当家客户手机号变更后重复注册问题
************************************************************/
CREATE PROCEDURE [dbo].[P_SetCustomerYXinfo]
	@CustomerID nvarchar(64)='',
	@Name nvarchar(64)='',
	@MobilePhone nvarchar(64)='',
	@YXAgentID nvarchar(64)='',
	@YXClientID nvarchar(64)='',
	@YXClientCode nvarchar(64)='',
	@ClientID nvarchar(64)=''
AS

if( exists( select CustomerID from Customer where ClientID=@ClientID and CustomerID=@CustomerID and YXClientCode<>'' ) )
	return

begin tran
declare @Err int
	if(@CustomerID<>'')
	begin
		update Customer set YXAgentID=@YXAgentID,YXClientID=@YXClientID,YXClientCode=@YXClientCode
		where ClientID=@ClientID and CustomerID=@CustomerID
	end
	else
	begin
		if( exists( select CustomerID from Customer where ClientID=@ClientID and MobilePhone=@MobilePhone and isnull(YXClientID,'')=''  and status<>9 ) )
		begin
			update Customer set YXAgentID=@YXAgentID,YXClientID=@YXClientID,YXClientCode=@YXClientCode
			where ClientID=@ClientID and MobilePhone=@MobilePhone and status<>9
		end
		else
		begin
			if(exists( select CustomerID from Customer where ClientID=@ClientID and YXClientID=@YXClientID and status<>9 ))
			begin
				update Customer set YXAgentID=@YXAgentID,YXClientID=@YXClientID,YXClientCode=@YXClientCode 
				where  ClientID=@ClientID and YXClientID=@YXClientID and status<>9
			end
			else
			begin
				insert into Customer(CustomerID,Name,Type,MobilePhone,SourceType,Status,CreateTime,ClientID,FirstName,YXAgentID,YXClientID,YXClientCode)
				values(newid(),@Name,0,@MobilePhone,3,1,getdate(),@ClientID,dbo.fun_getFirstPY(left(@Name,1)),@YXAgentID,@YXClientID,@YXClientCode)
			end
		end
	end

	set @Err+=@@error
	if(@Err>0)
	begin
		rollback tran
	end 
	else
	begin
		commit tran
	end

 


 


Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetCustomersByKeywords')
BEGIN
	DROP  Procedure  P_GetCustomersByKeywords
END

GO
/***********************************************************
过程名称： P_GetCustomersByKeywords
功能描述： 获取客户列表
参数说明：	 
编写日期： 2015/11/12
程序作者： Allen
调试记录： exec P_GetCustomersByKeywords 
************************************************************/
CREATE PROCEDURE [dbo].[P_GetCustomersByKeywords]
	@Keywords nvarchar(4000),
	@UserID nvarchar(64)='',
	@AgentID nvarchar(64),
	@ClientID nvarchar(64)
AS

	declare @condition nvarchar(4000)
	set @condition='ClientID='''+@ClientID+''' and Status<>9 '


	if(@UserID<>'')
	begin
		set @condition +=' and OwnerID = '''+@UserID+''''
	end

	if(@keyWords <> '')
	begin
		set @condition +=' and (Name like ''%'+@keyWords+'%'' or MobilePhone like ''%'+@keyWords+'%'')'
	end

	exec('select top 20 * from Customer where '+@condition+' order by AutoID desc')
 


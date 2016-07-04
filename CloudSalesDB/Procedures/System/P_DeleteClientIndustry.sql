Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteClientIndustry')
BEGIN
	DROP  Procedure  P_DeleteClientIndustry
END

GO
/***********************************************************
过程名称： P_DeleteClientIndustry
功能描述： 删除行业
参数说明：	 
编写日期： 2016/7/1
程序作者： Allen
调试记录： exec P_DeleteClientIndustry 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteClientIndustry]
@ClientIndustryID nvarchar(64)='',
@AgentID nvarchar(64)='',
@ClientID nvarchar(64)=''
AS

begin tran

declare @Err int=0

if not exists(select AutoID from Customer where ClientID=@ClientID and IndustryID=@ClientIndustryID)
begin

	update ClientsIndustry set Status=9 where ClientIndustryID=@ClientIndustryID and ClientID=@ClientID

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
Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteCustomColor')
BEGIN
	DROP  Procedure  P_DeleteCustomColor
END

GO
/***********************************************************
过程名称： P_DeleteCustomColor
功能描述： 删除团队
参数说明：	 
编写日期： 2016/6/21
程序作者： Allen
调试记录： exec P_DeleteCustomColor 
************************************************************/
CREATE PROCEDURE [dbo].[P_DeleteCustomColor]
@ColorID int,
@UpdateUserID nvarchar(64)='',
@AgentID nvarchar(64),
@ClientID nvarchar(64)=''
AS

begin tran

declare @Err int=0

if not exists(select AutoID from Customer where ClientID=@ClientID and Mark=@ColorID)
begin
	update CustomerColor set Status=9,UpdateUserID=@UpdateUserID,UpdateTime=getdate()
                   where AgentID=@AgentID and ClientID=@ClientID and ColorID=@ColorID
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
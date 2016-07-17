Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_UnBindUserWeiXinID')
BEGIN
	DROP  Procedure  M_UnBindUserWeiXinID
END

GO
/***********************************************************
过程名称： M_UnBindUserWeiXinID
功能描述： 给用户解绑微信ID
参数说明：	 
编写日期： 2016/7/17
程序作者： MU
调试记录： exec M_UnBindUserWeiXinID 
************************************************************/
CREATE PROCEDURE [dbo].[M_UnBindUserWeiXinID]
@ClientiD nvarchar(64),
@UserID nvarchar(64)
AS

begin tran

declare @Err int=0
declare @LoginName nvarchar(64)=''

select @LoginName=LoginName from users where UserID=@UserID  AND ClientiD=@ClientiD

if(@LoginName='' or @LoginName is null )
begin
	rollback tran
	return
end

update users set WeiXinID='' where UserID=@UserID  AND ClientiD=@ClientiD
set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end
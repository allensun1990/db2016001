Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_BindUserWeiXinID')
BEGIN
	DROP  Procedure  M_BindUserWeiXinID
END

GO
/***********************************************************
过程名称： M_BindUserWeiXinID
功能描述： 给用户绑定微信ID
参数说明：	 
编写日期： 2016/7/17
程序作者： Michaux
调试记录： exec M_BindUserWeiXinID 
************************************************************/
CREATE PROCEDURE [dbo].[M_BindUserWeiXinID]
@ClientiD nvarchar(64),
@UserID nvarchar(64),
@WeiXinID nvarchar(64),
@Type int =0
AS

begin tran

declare @Err int=0

if(@Type=0)
begin
	declare @OriginalWeiXinID nvarchar(64)=''

	select @OriginalWeiXinID=WeiXinID from users where UserID=@UserID  AND ClientiD=@ClientiD

	if(@OriginalWeiXinID<>'' )
	begin
		rollback tran
		return
	end
end
update users set WeiXinID=@WeiXinID where UserID=@UserID  AND ClientiD=@ClientiD
set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end
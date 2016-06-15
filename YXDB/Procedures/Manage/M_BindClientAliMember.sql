Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_BindClientAliMember')
BEGIN
	DROP  Procedure  M_BindClientAliMember
END

GO
/***********************************************************
过程名称： M_BindClientAliMember
功能描述： 给客户端绑定阿里会员
参数说明：	 
编写日期： 2016/3/24
程序作者： MU
调试记录： exec M_BindClientAliMember 
************************************************************/
CREATE PROCEDURE [dbo].[M_BindClientAliMember]
@ClientiD nvarchar(64),
@UserID nvarchar(64),
@AliMemberID nvarchar(64)
AS

begin tran

declare @Err int=0
declare @MemberID nvarchar(64)=''

select @MemberID=AliMemberID from clients where ClientiD=@ClientiD 

if(@MemberID<>'' and @MemberID is not null)
begin
rollback tran
return
end

update clients set AliMemberID=@AliMemberID where ClientiD=@ClientiD 
set @Err+=@@error

update users set AliMemberID=@AliMemberID where UserID=@UserID 
set @Err+=@@error

if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end
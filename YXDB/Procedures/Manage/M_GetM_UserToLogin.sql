

Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_GetM_UserToLogin')
BEGIN
	DROP  Procedure  M_GetM_UserToLogin
END

GO
/***********************************************************
�������ƣ� M_GetM_UserToLogin
���������� ��֤����ϵͳ��¼��������Ϣ
����˵����	 
��д���ڣ� 2016/4/20
�������ߣ� Michaux
���Լ�¼�� exec M_GetM_UserToLogin 'admin','F7D931C986841F4301D971C59F804409',0
************************************************************/
CREATE PROCEDURE [dbo].[M_GetM_UserToLogin]
@LoginName nvarchar(200),
@LoginPWD nvarchar(64),
@Result int output  --1:��ѯ������2���û��������ڣ�3���û���������
AS

declare @UserID nvarchar(64),@RoleID nvarchar(64)

IF  EXISTS(select UserID from M_Users where LoginName=@LoginName  and Status<>9)
begin
	select @UserID = UserID,@RoleID=RoleID from M_Users 
	where LoginName=@LoginName and LoginPWD=@LoginPWD and Status=1
	
	if(@UserID is not null)
	begin
		set @Result=1
		--��Ա��Ϣ
		select * from M_Users where UserID=@UserID
		--Ȩ����Ϣ
		select m.* from Menu m left join M_RolePermission r on r.MenuCode=m.MenuCode 
		where [Type] =2 and (RoleID=@RoleID or IsLimit=0 )

	end
	else
		set @Result=3
end
else
set @Result=2

 


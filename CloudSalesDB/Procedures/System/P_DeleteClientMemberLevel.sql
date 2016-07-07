
Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_DeleteClientMemberLevel')
BEGIN
	DROP  Procedure  P_DeleteClientMemberLevel
END

GO
/***********************************************************
过程名称： P_DeleteClientMemberLevel
功能描述： 删除客户等级
参数说明：	 
编写日期： 2016/07/07
程序作者： Michaux
调试记录： exec P_DeleteClientMemberLevel 
***********************************************************/
create proc P_DeleteClientMemberLevel
@LevelID varchar(50), 
@ClientID  varchar(50), 
@result varchar(50) output
as
begin
	set @result=''
	if(exists(select top 1 Name from Customer where MemberLevelID=@LevelID and [Status]<>9 ))
	begin
		set   @result='会员等级已被使用,删除失败'
		return -1
	end
	update ClientMemberLevel set Status=9 where LevelID=@LevelID and ClientID=@ClientID
end 
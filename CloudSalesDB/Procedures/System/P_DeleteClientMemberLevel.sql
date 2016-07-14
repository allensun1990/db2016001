
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
	declare @tempID varchar(50)
	select top 1 @tempID=LevelID  from ClientMemberLevel where  ClientID=@ClientID and [Status]<>9 order by origin desc
	if(exists(select top 1 Name from Customer where MemberLevelID=@LevelID and [Status]<>9 ))
	begin
		set   @result='会员等级已被使用,删除失败'
		return -1
	end
	if(@tempID!=@LevelID)
	begin
		set   @result='会员信息不是最新,请刷新页面后,再执行删除操作'
		return -1
	end
	if((select [Status] from ClientMemberLevel where  LevelID=@LevelID and ClientID=@ClientID )=9)
	begin
		set   @result='会员已被他人删除,不能重复操作,删除操作.'
		return -1
	end
	update ClientMemberLevel set Status=9 where LevelID=@LevelID and ClientID=@ClientID
end 
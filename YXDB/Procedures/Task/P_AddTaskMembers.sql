Use IntFactory_dev
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetTaskDetail')
BEGIN
	DROP  Procedure  P_GetTaskDetail
END

GO
/***********************************************************
过程名称： P_GetTaskDetail
功能描述： 添加任务成员
参数说明：	 
编写日期： 2016/5/18
程序作者： MU
调试记录： declare @Result exec P_GetTaskDetail @TaskID='0B9E8812-2F90-4C5F-B879-860E54D81C39',@OwnerID='',@Result=@Result output
************************************************************/
CREATE PROCEDURE [dbo].P_GetTaskDetail
@TaskID nvarchar(64),
@AgentID nvarchar(64),
@UserID nvarchar(64),
@MemberIDs nvarchar(2000),
@Result int output --0：失败，1：成功，2: 非任务负责人
as
	declare @sql varchar(4000)

	if(not exists(select taskid from ordertask where taskid=@TaskID and OwnerID=@UserID))
	begin
		set @Result=2
	end

	set @sql='insert into TaskMember(TaskID,MemberID,CreateTime,CreateUserID,AgentID,status,PermissionType) select '''+@TaskID+''',MemberID,getdate(),'''+@UserID+''','''+@AgentID+''',1,1  from (  select MemberID='''+ replace(@MemberIDs,',',''' union all select ''')+''' ) as valueTB'
	exec (@sql)

	set  @Result=1
		 






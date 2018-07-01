Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_AddCustomerMembers')
BEGIN
	DROP  Procedure  P_AddCustomerMembers
END

GO
/***********************************************************
过程名称： P_AddCustomerMembers
功能描述： 添加成员
参数说明：	 
编写日期： 2018/6/30
程序作者： Allen
调试记录： declare @Result exec P_AddCustomerMembers @TaskID='0B9E8812-2F90-4C5F-B879-860E54D81C39',@OwnerID='',@Result=@Result output
************************************************************/
CREATE PROCEDURE [dbo].P_AddCustomerMembers
@CustomerID nvarchar(64),
@UserID nvarchar(64),
@OperateID nvarchar(2000),
@ClientID nvarchar(64),
@Result int output --0：失败，1：成功，2: 非负责人
as
	declare @sql varchar(4000)

	if(not exists(select CustomerID from CustomerMember where CustomerID=@CustomerID and MemberID=@UserID and Status=1))
	begin
		insert into CustomerMember(CustomerID,MemberID,CreateUserID,Status,ClientID)
		values(@CustomerID,@UserID,@OperateID,1,@ClientID)
	end
	set  @Result=1
		 






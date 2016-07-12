
Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_RefreshMemberLevelID')
BEGIN
	DROP  Procedure  P_RefreshMemberLevelID
END

GO
/***********************************************************
过程名称： P_RefreshMemberLevelID
功能描述： 刷新客户等级
参数说明：	 
编写日期： 2016/7/12
程序作者： Michaux
调试记录： exec P_RefreshMemberLevelID  'eda082bc-b848-4de8-8776-70235424fc06'
************************************************************/
create proc P_RefreshMemberLevelID
@ClientID varchar(50),
@IP varchar(50),
@CreateUserID varchar(50),
@AgentID varchar(50)
as
	declare @i int 
	declare @j int
	set @i=0
	select @j=COUNT(1) from ClientMemberLevel where ClientID=@ClientID and Status<>9
	while @i<@j
	begin
		set @i=@i+1
		declare @levelID varchar(50)  declare @levelName varchar(50) 
		declare @integerFee decimal(18,2)
		select @levelID=LevelID,@integerFee=IntegFeeMore,@levelName=Name from ClientMemberLevel where ClientID=@ClientID and Origin=@i and Status<>9 
		if(@i=1)
		begin			
			insert into CustomerLog (LogGUID,Remark,CreateUserID,OperateIP,GUID,AgentID,ClientID) 
			select CustomerID,'客户等级变更为:'+@levelName+'(操作来自:客户配置->等级配置->应用到所有会员)',@CreateUserID,@IP,newid(),@AgentID,@ClientID from Customer where ClientID=@ClientID and IntegerFee<@integerFee and IntegerFee>=0		
			
			update Customer set MemberLevelID=@levelID  where ClientID=@ClientID and IntegerFee<@integerFee and IntegerFee>=0
		end 
		else if(@i=@j)
		begin 
			insert into CustomerLog (LogGUID,Remark,CreateUserID,OperateIP,GUID,AgentID,ClientID) 
			select CustomerID,'客户等级变更为:'+@levelName+'(操作来自:客户配置->等级配置->应用到所有会员)',@CreateUserID,@IP,newid(),@AgentID,@ClientID from Customer where ClientID=@ClientID and  IntegerFee>=@integerFee
			
			update Customer set MemberLevelID=@levelID  where  ClientID=@ClientID and IntegerFee>=@integerFee
		end
		else
		begin
			declare @nextFee decimal(18,2) 
			select @nextFee=IntegFeeMore from ClientMemberLevel where ClientID=@ClientID and Origin=(@i+1)	and Status<>9 
			
			insert into CustomerLog (LogGUID,Remark,CreateUserID,OperateIP,GUID,AgentID,ClientID) 
			select CustomerID,'客户等级变更为:'+@levelName+'(操作来自:客户配置->等级配置->应用到所有会员)',@CreateUserID,@IP,newid(),@AgentID,@ClientID from Customer
			where ClientID=@ClientID and IntegerFee<@nextFee and IntegerFee>=@integerFee
			
			update Customer set MemberLevelID=@levelID  where  ClientID=@ClientID and IntegerFee<@nextFee and IntegerFee>=@integerFee
			
		end	
		
	end
  	return 1
  
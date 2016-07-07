Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_InsertClientMemberLevel')
BEGIN
	DROP  Procedure  P_InsertClientMemberLevel
END

GO
/***********************************************************
过程名称： P_InsertClientMemberLevel
功能描述： 查入客户等级
参数说明：	 
编写日期： 2016/07/07
程序作者： Michaux
调试记录： exec P_InsertClientMemberLevel 
***********************************************************/
Create proc  P_InsertClientMemberLevel
@LevelID varchar(50),
@Name  varchar(50),
@ClientID  varchar(50),
@AgentID  varchar(50),
@DiscountFee decimal(18,2)=1.00,
@Status int=1,
@CreateUserID  varchar(50),
@IntegFeeMore decimal(18,2)=1.00, 
@ImgUrl varchar(150)='',
@result varchar(50) output
as
begin
	set @result=''
	declare @origin int
	if(@IntegFeeMore=0) 
	begin 
		set @result='升级条件不能为0'
		return 0
	end
	
	select @origin=isnull(max(origin),0) from ClientMemberLevel where ClientID=@ClientID and Status<>9
	
	if(@origin>0) 
	begin
		if(@IntegFeeMore<(select IntegFeeMore from ClientMemberLevel where ClientID=@ClientID and Status<>9 and origin=@origin))
		begin 
			set @result='会员达成条件后一个积分必须大于等于前一个积分设置'
			return 0
		end 
	end 
	if(exists(select Name from ClientMemberLevel where Name=@Name and ClientID=@ClientID and Status<>9))
	begin
		set @result='会员等级名称已存在'
		return 0
	end  
	set @origin=@origin+1
	insert into ClientMemberLevel (LevelID,Name,ClientID,AgentID,DiscountFee,Status,CreateUserID,IntegFeeMore ,Origin,ImgUrl)
	values(@LevelID,@Name,@ClientID,@AgentID,@DiscountFee,@Status,@CreateUserID,@IntegFeeMore,@origin,@ImgUrl)
	return @origin
end
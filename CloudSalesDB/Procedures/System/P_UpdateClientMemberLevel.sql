
Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateClientMemberLevel')
BEGIN
	DROP  Procedure  P_UpdateClientMemberLevel
END

GO
/***********************************************************
过程名称： P_InsertClientMemberLevel
功能描述： 修改客户等级
参数说明：	 
编写日期： 2016/07/07
程序作者： Michaux
调试记录： exec P_UpdateClientMemberLevel 
***********************************************************/
create  proc P_UpdateClientMemberLevel
@LevelID varchar(50),
@Name  varchar(50),
@ClientID  varchar(50), 
@DiscountFee decimal(18,2)=1.00, 
@IntegFeeMore decimal(18,2), 
@ImgUrl varchar(150)='',
@result varchar(50) output
as
begin
	set @result=''
	declare @origin int
	select @origin=origin from ClientMemberLevel where ClientID=@ClientID and LevelID=@LevelID
	if(@IntegFeeMore>0 and @origin>1 and @IntegFeeMore<(select IntegFeeMore from ClientMemberLevel where Status<>9 and ClientID=@ClientID and origin=(@origin-1))) 
	begin
		set @result='会员达成条件后一个积分必须大于等于前一个积分设置'
		return 0
	end
	declare @maxorigin int 
	select @maxorigin=MAX(origin) from ClientMemberLevel where ClientID=@ClientID and Status<>9 

	if(@IntegFeeMore>0 and @origin<@maxorigin and @IntegFeeMore>=(	select IntegFeeMore from ClientMemberLevel where Status<>9 and ClientID=@ClientID and origin=(@origin+1))) 
	begin
		set @result='会员达成条件后一个积分必须小于等于后一个积分设置'
		return 0
	end
	if(exists(select Name from ClientMemberLevel where Name=@Name and Status<>9 and ClientID=@ClientID and LevelID!=@LevelID))
	begin
		set @result='会员等级名称已存在'
		return 0
	end 
	update ClientMemberLevel 
		set Name=@Name,DiscountFee=@DiscountFee,IntegFeeMore=@IntegFeeMore ,
		ImgUrl=case  when LEN(@ImgUrl) >0 then @ImgUrl else ImgUrl end
		where LevelID=@LevelID and ClientID=@ClientID

end



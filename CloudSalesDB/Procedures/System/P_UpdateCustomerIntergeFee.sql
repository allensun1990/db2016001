Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_UpdateCustomerIntergeFee')
BEGIN
	DROP  Procedure  P_UpdateCustomerIntergeFee
END

GO
/***********************************************************
过程名称： P_UpdateCustomerIntergeFee
功能描述： 刷新客户积分
参数说明：	 
编写日期： 2016/8/2
程序作者： Michaux
调试记录： exec P_UpdateCustomerIntergeFee 
************************************************************/
 create proc P_UpdateCustomerIntergeFee
 @ChangeType int,
 @ChangeFee decimal(18,2),
 @CustomerID varchar(50),
 @AgentID varchar(50),
 @ClientID varchar(50),
 @UpdateUserID varchar(50),
 @Remark varchar(500),
 @OrderID varchar(50)=''
 as
 begin
	 declare @LevelID varchar(50),@LevelName varchar(100),@OldIntergeFee decimal(18,2),@OldLevelID varchar(50)
	 
	 select @ChangeFee=isnull(@ChangeFee,0.000)*isnull(DValue,0.0000) from ClientSetting where KeyType=2 and ClientID=@ClientID
	 select @OldIntergeFee=TotalIntegerFee,@OldLevelID=MemberLevelID  from  Customer where CustomerID=@CustomerID
	 set @Remark=isnull(@OrderID,'')+isnull(@Remark,'积分变动')+isnull(cast(@ChangeFee as varchar),'')
	 
	 exec P_InsertIntoFeeChange @ChangeType,@ChangeFee,@CustomerID,@AgentID,@ClientID,@UpdateUserID,@Remark

	select top 1 @LevelID=LevelID,@LevelName=Name from  ClientMemberLevel  where ClientID=@ClientID and (@OldIntergeFee+@ChangeFee)>IntegFeeMore order  by Origin asc
	if(@OldLevelID!=@LevelID)
	begin
		update Customer set TotalIntegerFee=isnull(TotalIntegerFee,0.0000)+case @ChangeType when 1 then @ChangeFee else 0 end ,IntegerFee=IntegerFee+@ChangeFee,MemberLevelID=@LevelID where CustomerID=@CustomerID and ClientID=@ClientID
		--插入客户等级日志里面
		insert into CustomerLog (LogGUID,Remark,CreateUserID,OperateIP,GUID,AgentID,ClientID) 
		values(@CustomerID,'客户等级变更为:'+@LevelName+'(操作来自:'+isnull(@OrderID,'')+'订单发货)',@UpdateUserID,'',NEWID(),@AgentID,@ClientID) 
	end
	else
	begin
		update Customer set  TotalIntegerFee=isnull(TotalIntegerFee,0.0000)+case @ChangeType when 1 then @ChangeFee else 0 end ,IntegerFee=IntegerFee+@ChangeFee where CustomerID=@CustomerID and ClientID=@ClientID		
	end

	insert into CustomerLog (LogGUID,Remark,CreateUserID,OperateIP,GUID,AgentID,ClientID) 
		values(@CustomerID,@Remark,@UpdateUserID,'',NEWID(),@AgentID,@ClientID) 
end 

 
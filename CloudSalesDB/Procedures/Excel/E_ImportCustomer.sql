Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'E_ImportCustomer')
BEGIN
	DROP  Procedure  E_ImportCustomer
END
GO 
/****** Object:  StoredProcedure [dbo].[E_ImportCustomer]    Script Date: 06/04/2016 11:54:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************
过程名称： E_ImportCustomer
功能描述： Excel导入新建客户
参数说明：	 
编写日期： 2016/06/03
程序作者： Michaux
调试记录： exec E_ImportCustomer 
************************************************************/
Create PROCEDURE [dbo].[E_ImportCustomer]
@CustomerID nvarchar(64),
@Name nvarchar(50),
@Type int=0,
@SourceID nvarchar(64)='',
@ActivityID nvarchar(64)='',
@IndustryID nvarchar(64)='',
@Extent int=0,
@CityCode nvarchar(20)='',
@Address nvarchar(500)='',
@ContactName nvarchar(200)='',
@MobilePhone nvarchar(50)='',
@OfficePhone nvarchar(50)='',
@Email nvarchar(500)='',
@Jobs nvarchar(200)='',
@Description nvarchar(500)='',
@OwnerID nvarchar(64)='',
@CreateUserID nvarchar(64)='',
@AgentID nvarchar(64)='',
@ClientID nvarchar(64),
@OverType int =0, --0仅导入 1 覆盖导入 2仅覆盖
@CheckType int=0 --0客户 1手机 2客户和手机
AS
begin 
tran
	declare @Err int=0,@StageID nvarchar(64),@LevelID varchar(50),@AllocationTime datetime=null 
	select top 1 @LevelID=LevelID from ClientMemberLevel where Status<>9  order by Origin asc
	if(@AgentID='')
	begin
		select @AgentID=AgentID from Clients where ClientID=@ClientID
	end

	if(@OwnerID <>'')
	begin
		insert into CustomerOwner(CustomerID,UserID,Status,CreateTime,CreateUserID,AgentID,ClientID)
		values(@CustomerID,@OwnerID,1,getdate(),@CreateUserID,@AgentID,@ClientID)
		set @AllocationTime=getdate()
		set @Err+=@@error
	end
	declare @SysCustomerID nvarchar(64)
	declare @SysContactID nvarchar(64)
	if(@CheckType=0)
	begin
		select @SysCustomerID=CustomerID  from  Customer where  Name=@Name and ClientID=@ClientID
		select @SysContactID=ContactID    from  Contact  where  Name=@ContactName  and CustomerID=@SysCustomerID
	end
	else if(@CheckType=1)
	begin
		select @SysCustomerID=CustomerID  from  Customer where  MobilePhone=@MobilePhone  and ClientID=@ClientID
		select @SysContactID=ContactID    from  Contact  where  MobilePhone=@MobilePhone  and CustomerID=@SysCustomerID
	end
	begin
		select @SysCustomerID=CustomerID  from  Customer where  Name=@Name and MobilePhone=@MobilePhone  and ClientID=@ClientID
		select @SysContactID=ContactID    from  Contact  where  Name=@ContactName and MobilePhone=@MobilePhone and CustomerID=@SysCustomerID
	end 
	set @SysContactID=ISNULL(@SysContactID,'')
	set @SysCustomerID=ISNULL(@SysCustomerID,'')
	if(@OverType<2)
	begin
		if(@SysCustomerID='')
		begin
		---负责人导入时为空 需要时把@StageID,null 替换为@StageID,@OwnerID
		
			insert into Customer(CustomerID,Name,ContactName,Type,IndustryID,Extent,CityCode,Address,MobilePhone,OfficePhone,Email,Jobs,Description,SourceID,ActivityID,
								StageID,OwnerID,Status,AllocationTime,OrderTime,CreateTime,CreateUserID,AgentID,ClientID,MemberLevelID,IntegerFee)
			values(@CustomerID,@Name,@ContactName,@Type,@IndustryID,@Extent,@CityCode,@Address,@MobilePhone,@OfficePhone,@Email,@Jobs,@Description,@SourceID,@ActivityID,
								@StageID,@OwnerID,1,@AllocationTime,null,getdate(),@CreateUserID,@AgentID,@ClientID,@LevelID,0)

			set @Err+=@@error
			if(@ContactName<>'')
			begin
				insert into Contact(ContactID,Name,Type,MobilePhone,OfficePhone,Email,Jobs,Status,CityCode,Address,OwnerID,CustomerID,CreateUserID,AgentID,ClientID)
				values(NEWID(),@ContactName,1,@MobilePhone,@OfficePhone,@Email,@Jobs,1,@CityCode,@Address,@OwnerID,@CustomerID,@CreateUserID,@AgentID,@ClientID)
			end

			if(@ActivityID<>'')
			begin
				update Activity set CustomerQuantity=CustomerQuantity+1 where ActivityID=@ActivityID
			end
		end
	end
	if(@OverType>0)
	begin
		if(@SysCustomerID<>'')
		begin
			update Customer set 
			Name=case when @CheckType=1 then @Name else Name end ,ContactName=@ContactName,		
			MobilePhone=case when @CheckType=0 then @MobilePhone else MobilePhone end,
			Email=@Email, IndustryID=@IndustryID,
			Type=@Type,Extent=@Extent,CityCode=@CityCode,
			[Address]=@Address,Jobs=@Jobs,[Description]=@Description
			where CustomerID=@SysCustomerID
		end
		if(@ContactName<>''  )
		begin
			if(@SysContactID<>'')
			begin
				update Contact set  
				Name=case when @CheckType=1 then @ContactName else Name end ,		
				MobilePhone=case when @CheckType=0 then @MobilePhone else MobilePhone end,
				Email=@Email,CityCode =@CityCode,
				[Address]=@Address,Jobs=@Jobs,[Description]=@Description
				where  ContactID=@SysContactID	
			end		
			--1 时 覆盖导入 即不存在新增  2 仅覆盖不导入
			if(@Type=1 and @SysContactID='')
			begin
				update Contact set [Type]=0 where  CustomerID=@SysCustomerID	
				---负责人导入时为空 需要时把@Jobs,1,null 替换为@Jobs,1,@OwnerID
				insert into Contact(ContactID,Name,Type,MobilePhone,OfficePhone,Email,Jobs,Status,OwnerID,CustomerID,CreateUserID,AgentID,ClientID)
				values(NEWID(),@ContactName,1,@MobilePhone,@OfficePhone,@Email,@Jobs,1,@OwnerID,@SysCustomerID,@CreateUserID,@AgentID,@ClientID)
			end
		end		
	end
	
if(@Err>0)
begin
	rollback tran
end 
else
begin
	commit tran
end

 


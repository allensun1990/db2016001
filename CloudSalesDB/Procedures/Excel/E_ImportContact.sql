Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'E_ImportContact')
BEGIN
	DROP  Procedure  E_ImportContact
END
GO 

/****** Object:  StoredProcedure [dbo].[E_ImportContact]    Script Date: 06/04/2016 15:13:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***********************************************************
过程名称： E_ImportContact
功能描述： Excel导入联系人
参数说明：	 
编写日期： 2016/06/4
程序作者： Michaux
调试记录： exec E_ImportContact 
************************************************************/
CREATE PROCEDURE [dbo].[E_ImportContact]
@ContactID nvarchar(64),
@CustomerID nvarchar(64),
@Name nvarchar(50),
@CompanyName nvarchar(50),
@CityCode nvarchar(20)='',
@Address nvarchar(500)='',
@MobilePhone nvarchar(50)='',
@OfficePhone nvarchar(50)='',
@Email nvarchar(500)='',
@Jobs nvarchar(200)='',
@Description nvarchar(500)='',
@CreateUserID nvarchar(64)='',
@AgentID nvarchar(64)='',
@ClientID nvarchar(64),
@OverType int =0, --0仅导入 1 覆盖导入 2仅覆盖
@CheckType int=0 --0客户 1手机 2客户和手机
AS
begin tran 
	select @CustomerID=CustomerID from Customer where Name=@CompanyName 
	declare @Err int=0,@Type int=0,@OwnerID nvarchar(64)
	set @OwnerID=''
	set @CustomerID=ISNULL(@CustomerID,'')
	if(@CustomerID<>'')
	begin  
		declare @SysContactID nvarchar(64)
		if(@CheckType=0)
		begin 
			select @SysContactID=ContactID  from  Contact  where  Name=@Name  and CustomerID=@CustomerID
		end
		else if(@CheckType=1)
		begin 
			select @SysContactID=ContactID  from  Contact  where  MobilePhone=@MobilePhone   and CustomerID=@CustomerID
		end
		begin 
			select @SysContactID=ContactID  from  Contact  where  Name=@Name and MobilePhone=@MobilePhone   and CustomerID=@CustomerID
		end 
		set @SysContactID=isnull(@SysContactID,'')
		--有插入操作
		if(@OverType<2)
		begin
			if(@SysContactID='')
			begin
				select @OwnerID=OwnerID from Customer where CustomerID=@CustomerID
				if not exists(select AutoID from Contact where CustomerID=@CustomerID and Type=1 and Status<>9)
				begin
					set @Type=1
				end
				insert into Contact(ContactID,Name,Type,MobilePhone,OfficePhone,CityCode,Email,Jobs,Address,Status,OwnerID,CustomerID,CreateUserID,AgentID,ClientID,Description)
					values(@ContactID,@Name,@Type,@MobilePhone,@OfficePhone,@CityCode,@Email,@Jobs,@Address,1,'',@CustomerID,@CreateUserID,@AgentID,@ClientID,@Description)
			end
		end
		---有修改操作 1 2
		if(@OverType>0)
			begin
			if(@SysContactID<>'' )
			begin			
				update Contact set  
				Name=case when @CheckType=1 then @Name else Name end ,		
				MobilePhone=case when @CheckType=0 then @MobilePhone else MobilePhone end,
				Email=@Email,CityCode =@CityCode,
				[Address]=@Address,Jobs=@Jobs,[Description]=@Description
				where  ContactID=@SysContactID	
			end		
			if(@OverType=1 and @SysContactID='')
			begin
				update Contact set [Type]=0 where  CustomerID=@CustomerID	
				---负责人导入时为空 需要时把@Jobs,1,null 替换为@Jobs,1,@OwnerID
				insert into Contact(ContactID,Name,Type,MobilePhone,OfficePhone,Email,Jobs,Status,OwnerID,CustomerID,CreateUserID,AgentID,ClientID,Description)
				values(NEWID(),@Name,1,@MobilePhone,@OfficePhone,@Email,@Jobs,1,@OwnerID,@CustomerID,@CreateUserID,@AgentID,@ClientID,@Description)
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

GO



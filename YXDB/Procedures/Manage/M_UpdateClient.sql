USE [IntFactory_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_UpdateClient')
BEGIN
	DROP  Procedure  M_UpdateClient
END
/****** Object:  StoredProcedure [dbo].[M_UpdateClient]    Script Date: 05/09/2016 14:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************
过程名称： M_UpdateClient
功能描述： 编辑客户端	
程序作者： MU 
编写日期： 2015/10/11
修改记录： Michaux 2016-05-09
修改摘要： Logo 为空时不修改
************************************************************/
Create PROCEDURE [dbo].[M_UpdateClient]
@ClientiD nvarchar(64),
@CompanyName nvarchar(200),
@MobilePhone nvarchar(64),
@Industry nvarchar(64),
@CityCode nvarchar(10),
@Address nvarchar(200),
@Description nvarchar(200),
@ContactName nvarchar(50),
@Logo nvarchar(200),
@OfficePhone nvarchar(50),
@CreateUserID nvarchar(64)
AS

--客户端
if(isnull(@Logo,'')<>'')
begin
	update Clients set CompanyName=@CompanyName,
	MobilePhone=@MobilePhone,Industry=@Industry, CityCode=@CityCode, 
	Address=@Address,Description=@Description,ContactName=@ContactName,
	Logo=@Logo,OfficePhone=@OfficePhone
	 where ClientiD=@ClientiD
 end
else
begin 
	update Clients set CompanyName=@CompanyName,
	MobilePhone=@MobilePhone,Industry=@Industry, CityCode=@CityCode, 
	Address=@Address,Description=@Description,ContactName=@ContactName,
	OfficePhone=@OfficePhone
	 where ClientiD=@ClientiD
end 

Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'M_UpdateClient')
BEGIN
	DROP  Procedure  M_UpdateClient
END

GO
/***********************************************************
过程名称： M_UpdateClient
功能描述： 编辑客户端
参数说明：	 
编写日期： 2015/10/11
程序作者： MU
调试记录： exec M_UpdateClient 
************************************************************/
CREATE PROCEDURE [dbo].M_UpdateClient
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
update Clients set CompanyName=@CompanyName,
MobilePhone=@MobilePhone,Industry=@Industry, CityCode=@CityCode, 
Address=@Address,Description=@Description,ContactName=@ContactName,
Logo=@Logo,OfficePhone=@OfficePhone
 where ClientiD=@ClientiD


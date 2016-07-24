USE [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_GetOrderDetailReport')
BEGIN
	DROP  Procedure  R_GetOrderDetailReport
END

/****** Object:  StoredProcedure [dbo].[R_GetOrderDetailReeport]    Script Date: 05/23/2016 13:05:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************
过程名称： R_GetOrderDetailReport
功能描述： 查询客户销售报表	 
编写日期： 2016/07/22
程序作者： Michaux
修改信息:   
调试记录： exec [R_GetOrderDetailReport] 'eda082bc-b848-4de8-8776-70235424fc06','2016-04-04','2016-04-07','',''
************************************************************/

create proc R_GetOrderDetailReport
@clientID varchar(50)='',
@beginTime varchar(50)='',
@endTime varchar(50)='',
@customerID varchar(50)='',
@remark varchar(500)

as
declare @sql varchar(4000)
set @sql='select b.ProductCode,b.ProductName,b.Remark,b.UnitName,SUM(b.Quantity-b.ReturnQuantity) as Quantity, SUM(b.TotalMoney-b.ReturnMoney) from  Orders a  join OrderDetail b  on a.OrderID=b.OrderID'
  
 if(@clientID<>'')
	set @sql=@sql+' b.ClientID='''+@clientID+''''

if(@customerID<>'')
	set @sql=@sql+' a.CustomerID='''+@customerID+''''
	
if(@remark<>'')
	set @sql=@sql+' b.Remark='''+@remark+''''

if(@beginTime<>'')
	set @sql=@sql+' a.CreateTime>='''+@beginTime+''''
	
if(@endTime<>'')
	set @sql=@sql+' a.CreateTime<='''+@endTime+' 23:59:59:999'''
	
set @sql=@sql+ ' group  by b.ProductCode,b.ProductName,b.Remark,b.UnitName '

exec (@sql)

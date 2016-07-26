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
@keyWords varchar(500),
@pageSize int,
@pageIndex int,
@orderBy varchar(500),
@totalCount int output,
@pageCount int output

as 
DECLARE @tableName nvarchar(400),
	@columns nvarchar(1000), 	 
	@condition  nvarchar(400),
	@groupColumn nvarchar(100)

	set @columns=' b.ProductID,a.ClientID,b.ProductCode,b.ProductName,b.Remark,b.UnitName,SUM(b.Quantity-b.ReturnQuantity) as Quantity, SUM(b.TotalMoney-b.ReturnMoney) as TotalMoney '
	set @tableName='  Orders a  join OrderDetail b  on a.OrderID=b.OrderID '
	set @condition =' a.Status<>9 ' 
	 if(@clientID<>'')
		set @condition=@condition+' and b.ClientID='''+@clientID+''''

	if(@customerID<>'')
		set @condition=@condition+' and a.CustomerID='''+@customerID+''''
	
	if(@keyWords<>'')
		set @condition=@condition+' and  b.Remark like ''%'+@keyWords+'%'''

	if(@beginTime<>'')
		set @condition=@condition+' and a.CreateTime>='''+@beginTime+''''
	
	if(@endTime<>'')
		set @condition=@condition+' and a.CreateTime<='''+@endTime+' 23:59:59:999'''
	
	set @condition=@condition+ ' group  by a.ClientID,b.ProductID,b.ProductCode,b.ProductName,b.Remark,b.UnitName '
 
	declare @CommandSQL nvarchar(4000)

	set @CommandSQL= 'select @totalCount=count(0) from( select a.ClientID  from '+@tableName+' where '+@condition +') as c '
	 
	exec sp_executesql @CommandSQL,N'@totalCount int output',@totalCount output
	set @pageCount=CEILING(@totalCount * 1.0/@pageSize)

	if(@pageIndex=0 or @pageIndex=1)
	begin 
		set @CommandSQL='select top '+str(@pageSize)+' '+@columns+' from '+@tableName+' where '+@condition+' order by '+@orderBy
	end
	else
	begin
		if(@pageIndex>@pageCount)
		begin
			set @pageIndex=@pageCount
		end
		set @CommandSQL='select * from (select row_number() over( order by '+@orderBy+' ) as rowid ,'+@columns+' from '+@tableName+' where '+@condition+' ) as dt where rowid between '+str((@pageIndex-1) * @pageSize + 1)+' and '+str(@pageIndex* @pageSize)
	end  
	exec (@CommandSQL)

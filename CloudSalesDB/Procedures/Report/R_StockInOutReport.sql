 Use [CloudSales1.0_dev]
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'R_StockInOutReport')
BEGIN
	DROP  Procedure  R_StockInOutReport
END

GO
/****** Object:  StoredProcedure [dbo].[R_StockInOutReport]    Script Date: 05/04/2016 14:38:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***********************************************************
过程名称： R_StockInOutReport
功能描述： 查询产品库存明细报表
参数说明：	 
编写日期： 2016/7/26
程序作者： Michaux
调试记录：
************************************************************/
create  proc  R_StockInOutReport
@clientID varchar(50)='',
@beginTime varchar(50)='',
@endTime varchar(50)='',  
@keyWords varchar(500),
@pageSize int,
@pageIndex int, 
@totalCount int output,
@pageCount int output
 as
 begin 
	 if(@beginTime='')
	 begin
		set @beginTime= cast(dateadd(MONTH,3 ,GETDATE()) as varchar)
	 end 
	 if(@endTime='')
	 begin 
		set @endTime=GETDATE()
	 end
	 else
	 begin
		set @endTime=@endTime+' 23:59:59:999'
	 end
 
	DECLARE @condition  nvarchar(400),@columns nvarchar(4000)
	set @condition=''
	if(@keyWords<>'')
	begin
		set @condition=@condition+' and  a.Remark like ''%'+@keyWords+'%''' 
	end
	if(@clientID<>'')
	begin
		set @condition=@condition+' and  a.ClientID='''+@clientID+'''' 
	end

	declare @CommandSQL nvarchar(4000)

	set @CommandSQL= 'select @totalCount=count(0) from ProductDetail a join Products b on a.ProductID=b.ProductID  where a.status<>9 and b.status<>9 '+@condition
 print @CommandSQL
	exec sp_executesql @CommandSQL,N'@totalCount int output',@totalCount output
	set @pageCount=CEILING(@totalCount * 1.0/@pageSize) 
	
	/*插入临时表*/
	select Mark,ProductID,ProductDetailID,SUM(Quantity) as Quantity into #InOut
	from ProductStream where CreateTime>=@beginTime and CreateTime <=@endTime and ClientID=@clientID
	group by Mark,ProductID,ProductDetailID

 set @columns=' d.ProductCode,d.ProductName,d.CategoryID,d.UnitID,a.*,isnull(b.Quantity,0) as InQuantity,isnull(c.Quantity,0) as OutQuantity ,
	isnull(( select top 1 case mark when 0 then SurplusQuantity+Quantity else SurplusQuantity-Quantity  end as QCQuantity
		from ProductStream where ProductDetailID=a.ProductDetailID and  CreateTime>='''+@beginTime+''' 
		 and CreateTime <='''+@endTime+''' and ClientID='''+@clientID+''' order by CreateTime asc 
	),0)as QCQuantity,
   isnull((select top 1 case mark when 0 then SurplusQuantity+Quantity else SurplusQuantity-Quantity  end as JYQuantity
		from ProductStream where ProductDetailID=a.ProductDetailID and  CreateTime>='''+@beginTime +'''
		 and CreateTime <='''+@endTime+''' and ClientID='''+@clientID+''' order by CreateTime desc 
	),0)as JYQuantity 
	from ProductDetail a 
	join Products d on a.ProductID=d.ProductID 
	left join (select * from  #InOut where  Mark=0 ) b  on a.ProductDetailID=b.ProductDetailID 
	left join (select * from  #InOut where  Mark=1 ) c on a.ProductDetailID=c.ProductDetailID 
	where a.status<>9 and d.status<>9 ' 

	if(@pageIndex=0 or @pageIndex=1)
	begin 
		set @CommandSQL='select top '+str(@pageSize)+' '+@columns+ @condition+' order by ProductCode asc '	 
	end
	else
	begin
		if(@pageIndex>@pageCount)
		begin
			set @pageIndex=@pageCount
		end
		set @CommandSQL='select * from (select row_number() over( order by  ProductCode asc ) as rowid ,'+@columns + @condition+' ) as dt where rowid between '+str((@pageIndex-1) * @pageSize + 1)+' and '+str(@pageIndex* @pageSize)
	end   
	 print @CommandSQL
	exec (@CommandSQL)

	drop table #InOut  
 end
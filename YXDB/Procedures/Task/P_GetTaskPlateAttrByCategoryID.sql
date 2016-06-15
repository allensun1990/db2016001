Use IntFactory
GO
IF EXISTS (SELECT * FROM sysobjects WHERE type = 'P' AND name = 'P_GetTaskPlateAttrByCategoryID')
BEGIN
	DROP  Procedure  P_GetTaskPlateAttrByCategoryID
END

GO
/***********************************************************
过程名称： P_GetTaskPlateAttrByCategoryID
功能描述： 获取任务制版属性
参数说明：	 
编写日期： 2016/3/5
程序作者： MU
调试记录： exec P_GetTaskPlateAttrByCategoryID @CategoryID='0B9E8812-2F90-4C5F-B879-860E54D81C39'
************************************************************/
CREATE PROCEDURE [dbo].P_GetTaskPlateAttrByCategoryID
@CategoryID nvarchar(64)=''
as
declare @AttrID nvarchar(64)

select @AttrID=AttrID from CategoryAttr where CategoryID=@CategoryID and Type=1 and Status<>9

select * from ProductAttr where AttrID=@AttrID and Status<>9

select * from AttrValue where AttrID=@AttrID and Status<>9  order by sort 


		 






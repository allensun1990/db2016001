alter table Products add HasDetails int default 0
GO
alter table productdetail add IsDefault int default 0
GO
Update productdetail set IsDefault=0 
Update productdetail set IsDefault=1 where SaleAttr=''
GO
insert into productdetail(productdetailid,detailscode,ProductID,Price,ImgS,Status,CreateUserID,ClientID,IsDefault)
select NEWID(),ProductCode,ProductID,Price,ProductImage,1,CreateUserID,ClientID,1 from Products
where ProductID not in(select ProductID from productdetail where IsDefault=1)
GO
update Products set HasDetails=0
Update Products set HasDetails=1 where ProductID in(
select ProductID from ProductDetail where Status<>9 group by ProductID having COUNT(0)>1
)
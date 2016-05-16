create function [dbo].[fun_getFirstPY](@chn nchar(1))
returns char(1)
as
begin
declare @n int
declare @c char(1)
set @n = 63
select @n = @n +1,
       @c = case chn when @chn then char(@n) else @c end
from(
select top 27 * from (
     select chn =
'吖' union all select
'八' union all select
'嚓' union all select
'咑' union all select
'妸' union all select
'发' union all select
'旮' union all select
'铪' union all select
'丌' union all select  --because have no 'i'
'丌' union all select
'咔' union all select
'垃' union all select
'嘸' union all select
'拏' union all select
'噢' union all select
'妑' union all select
'七' union all select
'呥' union all select
'仨' union all select
'他' union all select
'屲' union all select  --no 'u'
'屲' union all select  --no 'v'
'屲' union all select
'夕' union all select
'丫' union all select
'帀' union all select @chn) as a
order by chn COLLATE Chinese_PRC_CI_AS
) as b
if(@c='@')
 set @c=@chn

return(@c)
end
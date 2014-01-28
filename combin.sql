declare
type comb is table of number(1) INDEX BY varchar2(4000) ;
t_comb comb;
v_prev varchar(4000) := '';
v_prev_i varchar(4000) := '';
v_index varchar(4000) := '';
v_cnt number := 16;
function sortlist( f_list in varchar2) return varchar2 is
v_prev_i_2 varchar(4000) := '';
begin
for r in (select distinct item_val item3 from table(bfdba.pkg_utility.string_tokenizer(f_list)) order by item_val) loop
 if v_prev_i_2 is null then 
 v_prev_i_2 := r.item3;
 else 
 v_prev_i_2 :=v_prev_i_2 || ',' || r.item3;
 end if;
end loop;
return v_prev_i_2;
end; 
procedure recrchk(p_list in varchar2, p_comb in out comb,cnt in number) is
p_index varchar2(4000) := '';
begin
if cnt <= 16 then
--p_index := p_list; 
for r in (select distinct row_num nums, bene_typ from bbuckey.met_forms where bene_typ not in (select distinct trim(item_val) FROM TABLE(bfdba.pkg_utility.STRING_TOKENIZER(p_list))) order by row_num) loop
p_index := p_list || ',' || r.bene_typ;
p_index := sortlist(p_index);
p_comb(p_index) := 1;
recrchk(p_index,p_comb,cnt+1);
end loop;
end if;
end;
begin
--DBMS_OUTPUT.ENABLE(1000000);
for rec in (select distinct row_num, bene_typ from bbuckey.met_forms order by row_num) loop
v_index := rec.bene_typ;
t_comb(v_index) := 1;
recrchk(v_index,t_comb,1);
v_index := '';
end loop;
v_prev_i := t_comb.FIRST;
    WHILE v_prev_i IS NOT NULL LOOP
        DBMS_OUTPUT.PUT_LINE(v_prev_i);
        v_prev_i := t_comb.NEXT(v_prev_i);
    END LOOP;
end;

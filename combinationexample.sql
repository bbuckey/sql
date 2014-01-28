declare
type comb is table of number(1) INDEX BY varchar2(4000) ;
t_comb comb;
v_prev varchar(4000) := '';
v_prev_i varchar(4000) := '';
v_index varchar(4000) := '';
v_cnt number := 1;
p_index varchar2(4000) := '';
p_list varchar2(4000) := '';
v_cnt_l number := null;
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
begin
--DBMS_OUTPUT.ENABLE(1000000);
for rec in (select distinct row_num, bene_typ from bbuckey.met_forms order by row_num) loop
v_index := rec.bene_typ;
t_comb(v_index) := 1;
select count(distinct row_num) into v_cnt_l from bbuckey.met_forms where bene_typ not in (select item_val FROM TABLE(bfdba.pkg_utility.STRING_TOKENIZER(v_index)));
while v_cnt <= v_cnt_l loop
v_cnt := v_cnt + 1;
p_index := '';
for r in (select distinct row_num , bene_typ from bbuckey.met_forms where bene_typ not in (select item_val FROM TABLE(bfdba.pkg_utility.STRING_TOKENIZER(v_index))) order by row_num) loop
p_index := v_index || ',' || r.bene_typ;
p_index := sortlist(p_index);
t_comb(p_index) := 1;
end loop;
p_list := '';
begin
select distinct bene_typ into p_list from bbuckey.met_forms where bene_typ not in (select item_val FROM TABLE(bfdba.pkg_utility.STRING_TOKENIZER(v_index))) and rownum = 1;
v_index := v_index ||',' || p_list;
exception
    when OTHERS then
            v_cnt := v_cnt_l+1;
            DBMS_OUTPUT.PUT_LINE('change to subtract 1 from while loop ' || sqlerrm);
            p_list := '';
end;            
end loop;
v_cnt := 1;
v_index := '';
end loop;
v_prev_i := t_comb.FIRST;
    WHILE v_prev_i IS NOT NULL LOOP
       DBMS_OUTPUT.PUT_LINE(v_prev_i);
        v_prev_i := t_comb.NEXT(v_prev_i);
    END LOOP;
exception
    when OTHERS then
            DBMS_OUTPUT.PUT_LINE('what''s the error ' || sqlerrm);    
end;

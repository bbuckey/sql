declare
v_total_cyc number := 0;  /*23969 1129*/ /* first number is the total number of table columns with base schema 2nd is tables*/
V_OWNER varchar2(100):= 'BASE';
V_TABLE varchar2(100) :='PERSON';
v_index PLS_INTEGER := 1;
V_id number := 1183953953;--1168686483; -- id value of table serach
v_rep_val varchar2(5) := '_id';  -- used in no cyc function to replace ending id of column name with null  
type data_set is table of varchar2(200) INDEX BY PLS_INTEGER; -- all record storage
v_dataset data_set;
cursor parent_cons (c_owner in VARCHAR2,c_table in VARCHAR2)
is
select   a.table_name, upper (b.column_name) column_name,
                         b.position, a.constraint_name, a.owner,
                         a.delete_rule, a.r_owner
                    from (select ao.name table_name, au.name owner,
                                 bcn.name constraint_name,
                                 DECODE (ac.type#,
                                         4, DECODE (ac.refact,
                                                    1, 'CASCADE',
                                                    2, 'SET NULL',
                                                    'NO ACTION'
                                                   ),
                                         'IGNORE/NO ACTION'
                                        ) delete_rule,
                                 bo.name tn, bu.name r_owner
                            from sys.cdef$ bc,
                                 sys.con$ bcn,
                                 sys.obj$ bo,
                                 sys.user$ bu,
                                 sys.con$ brc,
                                 sys.user$ bru,
                                 sys.obj$ bro,
                                 sys.cdef$ ac,
                                 sys.con$ acn,
                                 sys.obj$ ao,
                                 sys.user$ au
                           where bc.con# = bcn.con#
                             and bc.obj# = bo.obj#
                             and bo.owner# = bu.user#
                             and bu.name = c_OWNER -- schema/owner name
                             and bo.name = c_TABLE --- table name
                             and bc.rcon# = brc.con#(+)
                             and brc.owner# = bru.user#(+)
                             and bc.robj# = bro.obj#(+)
                             and ac.con# = bc.rcon#
                             and ac.con# = acn.con#
                             and ao.obj# = ac.obj#
                             and ao.owner# = au.user#
                             and ac.type# in (2, 3)) a,
                         dba_cons_columns b
                   where b.table_name = a.tn
                     and b.constraint_name = a.constraint_name
                     and b.owner = a.r_owner;
cursor child_cons2(c_owner in VARCHAR2,c_table in VARCHAR2)
is
         select cc.column_name, cc.owner, cc.table_name,
                 mig_cc.column_name key_column_name
            from dba_cons_columns cc,
                 dba_constraints mig_c,
                 dba_constraints fk_c,
                 dba_cons_columns mig_cc
           where mig_c.constraint_type = 'P'
             and mig_c.table_name = c_table  --- TABLE NAME
             and mig_c.owner = c_owner  -- SCHEMA/ OWNER
             and fk_c.r_constraint_name = mig_c.constraint_name
             and fk_c.r_owner = mig_c.owner
             and cc.constraint_name = fk_c.constraint_name
             and cc.owner = fk_c.owner
             and mig_cc.constraint_name = mig_c.constraint_name
             and mig_cc.owner = mig_c.owner;
        function nocycles( f_partab_nm in varchar2,/* f_parown_nm in varchar2,*/ f_parcol_nm in varchar2, 
                           f_chtab_nm in varchar2, /*f_chown_nm in varchar2,*/ f_chcol_nm in varchar2 
                          --,f_cnt in number
                          ) 
        return Boolean as
        begin
        if f_partab_nm = f_chtab_nm then return false; end if;
        if f_chtab_nm = substr(f_parcol_nm,1,length(replace(f_parcol_nm,v_rep_val,''))) and 
        f_partab_nm = substr(f_chcol_nm,1,length(replace(f_chcol_nm,v_rep_val,''))) 
        then return false; end if;
        /*if (substr(f_chtab_nm,length(f_chtab_nm)-2,length(f_chtab_nm)) in ('CFG','GRP','DSP','SAC') or 
        substr(f_partab_nm,length(f_partab_nm)-2,length(f_partab_nm)) in ('CFG','GRP','DSP','SAC')) 
        then
        if ((f_chtab_nm = substr(f_parcol_nm,1,length(replace(f_parcol_nm,v_rep_val,''))) || '_CFG' and
            f_partab_nm = substr(f_chcol_nm,1,length(replace(f_chcol_nm,v_rep_val,''))) || '_CFG') 
        or
        ( f_chtab_nm = substr(f_parcol_nm,1,length(replace(f_parcol_nm,v_rep_val,''))) || '_CFG' and
            f_partab_nm = substr(f_chcol_nm,1,length(replace(f_chcol_nm,v_rep_val,''))))
        or
        ( f_chtab_nm = substr(f_parcol_nm,1,length(replace(f_parcol_nm,v_rep_val,''))) and
            f_partab_nm = substr(f_chcol_nm,1,length(replace(f_chcol_nm,v_rep_val,''))) || '_CFG' ) )
        then return false; end if;
        if ((f_chtab_nm = substr(f_parcol_nm,1,length(replace(f_parcol_nm,v_rep_val,''))) || '_GRP' and
            f_partab_nm = substr(f_chcol_nm,1,length(replace(f_chcol_nm,v_rep_val,''))) || '_GRP') 
        or
        ( f_chtab_nm = substr(f_parcol_nm,1,length(replace(f_parcol_nm,v_rep_val,''))) || '_GRP' and
            f_partab_nm = substr(f_chcol_nm,1,length(replace(f_chcol_nm,v_rep_val,''))))
        or
        ( f_chtab_nm = substr(f_parcol_nm,1,length(replace(f_parcol_nm,v_rep_val,''))) and
            f_partab_nm = substr(f_chcol_nm,1,length(replace(f_chcol_nm,v_rep_val,''))) || '_GRP' ) )
        then return false; end if;
                if ((f_chtab_nm = substr(f_parcol_nm,1,length(replace(f_parcol_nm,v_rep_val,''))) || '_DSP' and
            f_partab_nm = substr(f_chcol_nm,1,length(replace(f_chcol_nm,v_rep_val,''))) || '_DSP') 
        or
        ( f_chtab_nm = substr(f_parcol_nm,1,length(replace(f_parcol_nm,v_rep_val,''))) || '_DSP' and
            f_partab_nm = substr(f_chcol_nm,1,length(replace(f_chcol_nm,v_rep_val,''))))
        or
        ( f_chtab_nm = substr(f_parcol_nm,1,length(replace(f_parcol_nm,v_rep_val,''))) and
            f_partab_nm = substr(f_chcol_nm,1,length(replace(f_chcol_nm,v_rep_val,''))) || '_DSP' ) )
        then return false; end if;
                if ((f_chtab_nm = substr(f_parcol_nm,1,length(replace(f_parcol_nm,v_rep_val,''))) || '_SAC' and
            f_partab_nm = substr(f_chcol_nm,1,length(replace(f_chcol_nm,v_rep_val,''))) || '_SAC') 
        or
        ( f_chtab_nm = substr(f_parcol_nm,1,length(replace(f_parcol_nm,v_rep_val,''))) || '_SAC' and
            f_partab_nm = substr(f_chcol_nm,1,length(replace(f_chcol_nm,v_rep_val,''))))
        or
        ( f_chtab_nm = substr(f_parcol_nm,1,length(replace(f_parcol_nm,v_rep_val,''))) and
            f_partab_nm = substr(f_chcol_nm,1,length(replace(f_chcol_nm,v_rep_val,''))) || '_SAC' ) )
        then return false; end if;
        end if;*/
        return true; -- default return total cols in bfi schemas 
        end;--end nocycles;
        PROCEDURE E_ATTR(P_T_NM IN VARCHAR2, P_id IN NUMBER,p_cnt in number, p_dataset in out data_set) is
        BEGIN
        for rec in (
        select distinct id from base.entity
                where attr_typ = P_T_NM
                and attr_id =  P_id
        )
        loop
        v_index := v_index + 1;
        p_dataset(v_index) := upper('base.entity') || ',' || 'id' || ',' || rec.id || ',' ||p_cnt;
        end loop;
        END;
        procedure recurfind(p_table_nm in varchar2, p_own_nm in varchar2, p_col_nm in varchar2, p_id_num in number, p_cnt in number, p_dataset in out data_set) is
        v_bol boolean := TRUE;
        p_exe_str varchar2(5000) := '';
        type t_id_tab is table of base.person.id%type; -- for id bulk collect
        v_t_id t_id_tab;
        begin
        p_exe_str := 'select distinct id from '|| p_own_nm|| '.'||p_table_nm || 
        ' where ' || p_col_nm || ' = ' || p_id_num;
        --||' and rownum <= 100'; /* remove rownum =1 when returning into a table,  Limit collect to 100*/
            begin
            execute immediate p_exe_str bulk collect into v_t_id; --into new_id /*  UPDATE to return into table list then run for loop in if statement*/
            EXCEPTION
                when OTHERS then
                 DBMS_OUTPUT.PUT_LINE( sqlerrm ||' ' || p_cnt);
            end;
        if v_t_id.first is not null then
            For i in v_t_id.first .. v_t_id.last loop
                       v_index := v_index + 1;
                       p_dataset(v_index) := p_own_nm || '.' || p_table_nm || ',' || 'id' || ',' || v_t_id(i) || ',' ||p_cnt;
                       E_ATTR(p_table_nm, v_t_id(i),p_cnt+1, p_dataset);
            end loop;
        end if;
            for c2 in (select cc.column_name, cc.owner, cc.table_name,
                 mig_cc.column_name key_column_name
            from dba_cons_columns cc,
                 dba_constraints mig_c,
                 dba_constraints fk_c,
                 dba_cons_columns mig_cc
           where mig_c.constraint_type = 'P'
             and mig_c.table_name = p_table_nm  --- TABLE NAME
             and mig_c.owner = p_own_nm  -- SCHEMA/ OWNER
             and fk_c.r_constraint_name = mig_c.constraint_name
             and fk_c.r_owner = mig_c.owner
             and cc.constraint_name = fk_c.constraint_name
             and cc.owner = fk_c.owner
             and mig_cc.constraint_name = mig_c.constraint_name
             and mig_cc.owner = mig_c.owner ) loop   
             v_bol := nocycles(p_table_nm,/*p_own_nm,*/p_col_nm,
                                   c2.table_name, /*c2.owner,*/c2.column_name);
                 if v_t_id.first is not null then
                for i in v_t_id.first .. v_t_id.last loop
                    if v_t_id(i) is not null and p_cnt <= v_total_cyc and v_bol then -- check null id and cyc count and 
                        recurfind(c2.table_name, c2.owner,c2.column_name, v_t_id(i), p_cnt+1,p_dataset);
                    end if;
                end loop;
                end if;
            end loop;
        end;--end recurfind;
begin
select count(*) into v_total_cyc from all_tab_columns where owner like 'BASE%'; 
/*total column count for bfi schema's change to all_tables for table count*/
v_dataset(v_index) := v_owner || '.' || v_table || ',' || 'id' || ',' || v_id ||','|| 0;
E_ATTR(v_table, v_id,1, v_dataset);
for c1 in child_cons2(v_owner,V_TABLE) loop
recurfind(c1.table_name, c1.owner,c1.column_name, v_id,1, v_dataset);
end loop;

for i in 1 .. v_index loop
DBMS_OUTPUT.PUT_LINE( v_dataset(i));
end loop;
end;



    
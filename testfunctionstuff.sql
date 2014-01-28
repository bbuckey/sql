

declare
v_temp number := 0;
v_test varchar2(50) := 'NOT WORKING';
v_other number := 0;
FUNCTION NO_DATA_FOUD_CHECK(v_id number) return number as
v_aud_id number := 0;
begin
  Select id into v_aud_id from base.person where id = v_id;
  return v_aud_id;
  Exception
      When OTHERS THEN
          DBMS_OUTPUT.put_line('NO_DATA_FOUND ' || sqlERRM);
          raise;
         -- return null;
end;
procedure check_nested_actions(p_id in number, p_id_out in out number, otherstuff in out number, stuff in out varchar2) AS
begin

otherstuff := 123;

p_id_out := NO_DATA_FOUD_CHECK(p_oid);

stuff := 'WORKING';

DBMS_OUTPUT.put_line(to_char(nvl(p_id_out,999999)) || ' THIS IS THE VALUE');
exception
      When OTHERS
          Then DBMS_OUTPUT.put_line(stuff || ' ' || sqlerrm);
        --  RAISE;
end;
begin 

check_nested_actions(null,v_temp,v_other,v_test);

DBMS_OUTPUT.put_line(to_char(nvl(v_temp,99999)) || ' ' || to_char(v_other) || ' ' || v_test || ' and the result is ' );

exception
when OTHERS then 
DBMS_OUTPUT.put_line('This is the end results after everything happend ' || sqlerrm);
end;
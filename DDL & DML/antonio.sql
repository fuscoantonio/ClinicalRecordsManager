--create package
create or replace package pkg_log
is
  CONN         UTL_TCP.CONNECTION;

 

  procedure open_connection;  
  procedure close_connection;  
  procedure send_message( a_level       in varchar2,
                          a_text        in varchar2 );
end;
--create body of package
create or replace package body pkg_log
as
  procedure send_message( a_level       in varchar2,
                          a_text        in varchar2 )
  is
     L_TEXT  VARCHAR2(2000);  
      RETVAL       BINARY_INTEGER;
  begin
    -- L_TEXT := a_level||'\\'|| stk.caller(6)||'\\'||a_text;
    L_TEXT := a_level||':'||a_text; --a_level+' '+a_text;
    begin
      RETVAL := UTL_TCP.WRITE_LINE(CONN,L_TEXT);
      UTL_TCP.FLUSH(CONN);
    end;
    exception
      when others then
      begin
        open_connection;
        RETVAL := UTL_TCP.WRITE_LINE(CONN,L_TEXT);
        UTL_TCP.FLUSH(CONN);
      end;        
  end;
  
  procedure close_connection 
  is  
  begin
     UTL_TCP.CLOSE_CONNECTION(CONN);
  end;

  procedure open_connection 
  is
  begin
     CONN := UTL_TCP.OPEN_CONNECTION(
        REMOTE_HOST   => 'delphiapp.ddns.net',
        REMOTE_PORT   => 9898,
        TX_TIMEOUT    => 10
    );
  end;

end;

--delete package
drop package pkg_log;
--create ACL per Oracle 11
BEGIN
  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(acl         => 'dba.xml',
                                    description => 'xml',
                                    principal   => 'ANTONIO',
                                    is_grant    => true,
                                    privilege   => 'connect');
 
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(acl       => 'dba.xml',
                                       principal => 'ANTONIO',
                                       is_grant  => true,
                                       privilege => 'resolve');
 
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(acl  => 'dba.xml',
                                    host => 'delphiapp.ddns.net');
END;
/
COMMIT;
--delete ACL
BEGIN
  DBMS_NETWORK_ACL_ADMIN.drop_acl ( 
    acl         => 'dba.xml');

  COMMIT;
END; 

--create ACL per Oracle 18----
/*begin
DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
  host => '127.0.0.1',
  ace  =>  xs$ace_type(privilege_list => xs$name_list('connect', 'resolve'),
                       principal_name => 'G1',
                       principal_type => xs_acl.ptype_db));
end;
*/

--open connection to package
begin
    pkg_log.open_connection;
end;

--send message to pkg_log
begin
    pkg_log.send_message('warning', 'prova');
end;
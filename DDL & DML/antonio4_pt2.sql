create or replace type Unsent_Logs_T as object (
    
    id number(38),
    log_date date,
    log_timestamp timestamp,
    log_message varchar2(4000),
    
    constructor function Unsent_Logs_T (log_date date, log_timestamp timestamp, log_message nvarchar2)
    return self as result
) not final;

create sequence unsent_logs_seq;

create or replace type body Unsent_Logs_T as

    constructor function Unsent_Logs_T (log_date date, log_timestamp timestamp, log_message nvarchar2)
    return self as result
    is
    begin
        SELF.id := unsent_logs_seq.NEXTVAL;
        SELF.log_date := log_date;
        SELF.log_timestamp := log_timestamp;
        SELF.log_message := log_message;
        return;
    end;
end;

create table unsent_logs of unsent_logs_t;

create or replace package pkg_log
is
  CONN         UTL_TCP.CONNECTION;



    procedure open_connection;  
    procedure close_connection;  
    procedure send_message( a_level       in timestamp,
                              a_text        in varchar2 );
    procedure dump_unsentlogs;
    procedure dump_unsentlogs_bydate(l_date date);
end;


create or replace package body pkg_log
as
  procedure send_message( a_level       in timestamp,
                          a_text        in varchar2 )
  is
     L_TEXT  VARCHAR2(4000);  
      RETVAL       BINARY_INTEGER;
      unsent_log    Unsent_Logs_T;
  begin
    L_TEXT := a_level||' = '||a_text;
    begin
      RETVAL := UTL_TCP.WRITE_LINE(CONN,L_TEXT);
      UTL_TCP.FLUSH(CONN);
    exception
      when others then
      begin
        open_connection;
        RETVAL := UTL_TCP.WRITE_LINE(CONN,L_TEXT);
        UTL_TCP.FLUSH(CONN);
        exception
        when others then
            unsent_log := new unsent_logs_t(to_date(sysdate), systimestamp, L_TEXT);
            insert into unsent_logs values unsent_log;
        end;
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
        TX_TIMEOUT    => 5
    );
  end;

  procedure dump_unsentlogs
  is
    RETVAL BINARY_INTEGER;
  begin
    open_connection;
    FOR msg IN (SELECT id, log_timestamp, log_message FROM unsent_logs)
    LOOP 
        RETVAL := UTL_TCP.WRITE_LINE(CONN,msg.log_timestamp||' = '||msg.log_message);
        UTL_TCP.FLUSH(CONN);
        delete from unsent_logs where id = msg.id;
    END LOOP;
  end;

  procedure dump_unsentlogs_bydate(l_date date)
  is
    RETVAL BINARY_INTEGER;
  begin
    open_connection;
    FOR msg IN (SELECT id, log_timestamp, log_message FROM unsent_logs WHERE log_date = to_date(l_date))
    LOOP
        RETVAL := UTL_TCP.WRITE_LINE(CONN,msg.log_timestamp||' = '||msg.log_message);
        UTL_TCP.FLUSH(CONN);
        delete from unsent_logs where id = msg.id;
    END LOOP;
  end;

end;
create or replace type ini_file_t as object (

    id number,
    date_time timestamp,
    ini_line varchar2(4000),
    
    constructor function ini_file_t(date_time timestamp, ini_line varchar2) return self as result
    
) not final;

create or replace type body ini_file_t as

    constructor function ini_file_t(date_time timestamp, ini_line varchar2)
    return self as result
    is
    begin
        self.id := null;
        self.date_time := date_time;
        self.ini_line := ini_line;
        return;
    end;
    
end;

create table ini_logger of ini_file_t;
create table ini_client of ini_file_t;

create sequence ini_logger_seq;
create sequence ini_client_seq;

create or replace trigger ini_logger_trig
before insert on ini_logger
for each row
begin
    select ini_logger_seq.nextval
    into :new.id
    from dual;
end;

create or replace trigger ini_client_trig
before insert on ini_client
for each row
begin
    select ini_client_seq.nextval
    into :new.id
    from dual;
end;

--------ini_util head-------
create or replace package ini_util
is
  CONN UTL_TCP.CONNECTION;

    procedure open_connection;  
    procedure close_connection;  
    procedure upload_ini_logger(date_time in timestamp,
                             ini_line in varchar2);
    procedure upload_ini_client(date_time in timestamp,
                             ini_line in varchar2);
    procedure download_ini_logger;
    procedure download_ini_client;
    procedure delete_ini_logger;
    procedure delete_ini_client;
end;

--------ini_util body----------
create or replace package body ini_util
as
  procedure upload_ini_logger(date_time in timestamp,
                        ini_line in varchar2)
  is  
    ini_str Ini_File_T;
  begin
    ini_str := new ini_file_t(date_time, ini_line);
    insert into ini_logger values ini_str;
  end;
  
  
  procedure upload_ini_client(date_time in timestamp,
                        ini_line in varchar2)
  is  
    ini_str Ini_File_T;
  begin
    ini_str := new ini_file_t(date_time, ini_line);
    insert into ini_client values ini_str;
  end;
  
  
  procedure download_ini_logger
  is
    RETVAL BINARY_INTEGER;
  begin
    open_connection;
    FOR str IN (SELECT ini_line FROM ini_logger ORDER BY id ASC)
    LOOP
        RETVAL := UTL_TCP.WRITE_LINE(CONN,str.ini_line);
        UTL_TCP.FLUSH(CONN);
    END LOOP;
  end;
  
  
  procedure download_ini_client
  is
    RETVAL BINARY_INTEGER;
  begin
    open_connection;
    FOR str IN (SELECT ini_line FROM ini_client ORDER BY id ASC)
    LOOP
        RETVAL := UTL_TCP.WRITE_LINE(CONN,str.ini_line);
        UTL_TCP.FLUSH(CONN);
    END LOOP;
  end;
  
  
  procedure delete_ini_logger
  is
  begin
    delete from ini_logger;
  end;
  
  
  procedure delete_ini_client
  is
  begin
    delete from ini_client;
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

end;
create or replace trigger logoff_trigger
   BEFORE LOGOFF ON antonio.SCHEMA
   DECLARE
        id number;
   BEGIN
      SELECT USERLOG.NEXTVAL INTO id FROM dual;
       INSERT INTO USER_LOG VALUES ('logoff', CURRENT_TIMESTAMP, id, USER);
       pkg_log.send_message(systimestamp,'logoff antonio: ');
       pkg_log.close_connection;
       exception
       when others then
        null;
   END;


create or replace trigger logon_trigger
AFTER LOGON ON antonio.SCHEMA
DECLARE
    id number;
BEGIN
  SELECT USERLOG.NEXTVAL INTO id FROM dual;
   INSERT INTO USER_LOG VALUES ('logon', CURRENT_TIMESTAMP, id, USER);
   pkg_log.send_message(systimestamp,'logon antonio: ');
   exception
   when others then
    null;
END;

create table user_log (
    log_type char(6) not null,
    log_time timestamp not null,
    id number(38) primary key not null,
    user_name varchar2(250)
)


SELECT DISTINCT OBJECT_NAME   FROM USER_OBJECTS WHERE OBJECT_TYPE = 'TABLE'
create or replace  TYPE Soggetti_T AS OBJECT
(
    id NUMBER(38),
    identificativo_primario NVARCHAR2(100), -- cognonme, ragione sociale
    indirizzo_principale NVARCHAR2(100), -- residenza sede_legale
    città_principale NVARCHAR2(100),
    telefono VARCHAR2(15),
    email NVARCHAR2(100),
    codice_fiscale VARCHAR2(16),
    partita_iva VARCHAR2(11),
    parente_id NUMBER(38), -- relazione del soggetto capogruppo, familiare
    id_tipo NUMBER(38), -- tipo soggetto 
    
    MEMBER PROCEDURE dump_log,
    
    MEMBER FUNCTION str_log RETURN VARCHAR2
    
)NOT FINAL;

CREATE OR REPLACE TYPE BODY Soggetti_T AS
    
    MEMBER PROCEDURE dump_log
    IS
    BEGIN
        pkg_log.send_message(SYSTIMESTAMP, 'dump campi: id: '||SELF.id||' identificativo_primario: ' ||SELF.identificativo_primario||
                            ' indirizzo_principale: '||SELF.indirizzo_principale||' città_principale: '||SELF.città_principale||
                            ' telefono: '||SELF.telefono||' email: '||SELF.email||' codice_fiscale: '||SELF.codice_fiscale||
                            ' partita_iva: '||SELF.partita_iva||' parente_id: '||SELF.parente_id||' id_tipo: '||SELF.id_tipo);
    END;
    
    MEMBER FUNCTION str_log
    RETURN VARCHAR2
    IS
    BEGIN
        return 'id: '||SELF.id||' identificativo_primario: ' ||SELF.identificativo_primario||
                            ' indirizzo_principale: '||SELF.indirizzo_principale||' città_principale: '||SELF.città_principale||
                            ' telefono: '||SELF.telefono||' email: '||SELF.email||' codice_fiscale: '||SELF.codice_fiscale||
                            ' partita_iva: '||SELF.partita_iva||' parente_id: '||SELF.parente_id||' id_tipo: '||SELF.id_tipo;
    END;
END;
 
 
create or replace  TYPE Persone_T UNDER Soggetti_T
(
    nome NVARCHAR2(35),
    data_nascita DATE,
    peso NUMBER(38),
    
    OVERRIDING MEMBER PROCEDURE dump_log
    
)NOT FINAL;


CREATE OR REPLACE TYPE BODY Persone_T AS

    OVERRIDING MEMBER PROCEDURE dump_log
    IS
    BEGIN
        pkg_log.send_message(SYSTIMESTAMP, 'dump campi: '||(SELF as Soggetti_T).str_log||' nome: '||nome||' data_nascita: '||data_nascita||' peso: '||peso);
    END;
END;

create table persone of persone_t;

create sequence soggetti_id_seq;

CREATE OR REPLACE TRIGGER persone_before_insert_trig
BEFORE INSERT ON persone
FOR EACH ROW
BEGIN
    SELECT soggetti_id_seq.NEXTVAL
    INTO   :new.id
    FROM   dual;
END;
CREATE OR REPLACE TYPE Figura_t AS OBJECT
(
  x_a NUMBER(38),
  y_a NUMBER(38),

    CONSTRUCTOR FUNCTION Figura_t  (x_a NUMBER , y_a NUMBER)-- i parametri erano x e y anziché x_a e y_a
    RETURN SELF AS RESULT,

    MEMBER PROCEDURE init_p(x NUMBER , y NUMBER)
)NOT FINAL;

--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--

CREATE OR REPLACE TYPE BODY Figura_t AS
------------------------------------------------------------------
    CONSTRUCTOR FUNCTION Figura_t  (x_a NUMBER, y_a NUMBER)
    RETURN SELF AS RESULT
    IS
    BEGIN
        SELF.init_p(x_a,y_a);
    RETURN;
    END;
------------------------------------------------------------------
    MEMBER PROCEDURE init_p(x NUMBER, y NUMBER)
    IS
    BEGIN
        SELF.x_a:=x;
        SELF.y_a:=y;
    END;
END;

DECLARE
    fig Figura_t := new Figura_t(2,3);
BEGIN
    fig.init_p(1,1);
END;

--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--

CREATE OR REPLACE TYPE Cerchio_t UNDER Figura_t
(
    raggio_a NUMBER(38),
    CONSTRUCTOR FUNCTION Cerchio_t  ( x_a NUMBER , y_a NUMBER, raggio_a NUMBER)
  RETURN SELF AS RESULT,
  MEMBER PROCEDURE init_p( x NUMBER , y NUMBER, radius NUMBER)
) NOT FINAL;

--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--

CREATE OR REPLACE TYPE BODY Cerchio_t AS
    CONSTRUCTOR FUNCTION Cerchio_t  ( x_a NUMBER , y_a NUMBER, raggio_a NUMBER)
    RETURN SELF AS RESULT
    IS
    BEGIN
        SELF.init_p(x_a,y_a,raggio_a);
        return;
    END;
   MEMBER PROCEDURE init_p( x NUMBER , y NUMBER, radius NUMBER)
    IS
    BEGIN
        (SELF as Figura_t).init_p(x,y);
        SELF.raggio_a:=radius;
    END;
END;

--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--

CREATE TABLE cerchi_table OF Cerchio_t;

--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--.--

DECLARE
cer Cerchio_t:= new Cerchio_t(3,1,3);
BEGIN
    INSERT INTO cerchi_table VALUES cer;
END;



CREATE OR REPLACE TYPE Soggetti_T AS OBJECT
(
    id NUMBER(38),
    nome NVARCHAR2(35),
    cognome NVARCHAR2(35),
    indirizzo NVARCHAR2(100),
    telefono VARCHAR2(15),
    email NVARCHAR2(320),
    codice_fiscale VARCHAR2(16),
    partita_iva VARCHAR2(11),

    CONSTRUCTOR FUNCTION Soggetti_T (nome NVARCHAR2, cognome NVARCHAR2, indirizzo NVARCHAR2, telefono VARCHAR2, email NVARCHAR2,
                                   codice_fiscale VARCHAR2, partita_iva VARCHAR2)
    RETURN SELF AS RESULT,

    MEMBER PROCEDURE init(nome NVARCHAR2, cognome NVARCHAR2, indirizzo NVARCHAR2, telefono VARCHAR2, email NVARCHAR2,
                          codice_fiscale VARCHAR2, partita_iva VARCHAR2)
)NOT FINAL;

CREATE OR REPLACE TYPE BODY Soggetti_T AS
------------------------------------------------------------------
    CONSTRUCTOR FUNCTION Soggetti_T (nome NVARCHAR2, cognome NVARCHAR2, indirizzo NVARCHAR2, telefono VARCHAR2, email NVARCHAR2,
                                   codice_fiscale VARCHAR2, partita_iva VARCHAR2)
    RETURN SELF AS RESULT
    IS
    BEGIN
        SELF.init(nome, cognome, indirizzo, telefono, email, codice_fiscale, partita_iva);
    RETURN;
    END;
------------------------------------------------------------------
    MEMBER PROCEDURE init(nome NVARCHAR2, cognome NVARCHAR2, indirizzo NVARCHAR2, telefono VARCHAR2, email NVARCHAR2,
                          codice_fiscale VARCHAR2, partita_iva VARCHAR2)
    IS
    BEGIN
        SELF.nome := nome;
        SELF.cognome := cognome;
        SELF.indirizzo := indirizzo;
        SELF.telefono := telefono;
        SELF.email := email;
        SELF.codice_fiscale := codice_fiscale;
        SELF.partita_iva := partita_iva;
    END;
END;


-------------------
CREATE OR REPLACE TYPE Clienti_T UNDER Soggetti_T
(
    saldo NUMBER(38),
    sconto NUMBER(3),
    --numero_acquisti NUMBER(38),
    --primo_acquisto DATE,
    --ultimo_acquisto DATE,
    
    CONSTRUCTOR FUNCTION Clienti_T (nome NVARCHAR2, cognome NVARCHAR2, indirizzo NVARCHAR2, telefono VARCHAR2, email NVARCHAR2,
                                     codice_fiscale VARCHAR2, partita_iva VARCHAR2)
    RETURN SELF AS RESULT,
    MEMBER PROCEDURE init_c(nome NVARCHAR2, cognome NVARCHAR2, indirizzo NVARCHAR2, telefono VARCHAR2, email NVARCHAR2,
                          codice_fiscale VARCHAR2, partita_iva VARCHAR2)
) NOT FINAL;

CREATE OR REPLACE TYPE BODY Clienti_T AS
------------------------------------------------------------------
    CONSTRUCTOR FUNCTION Clienti_T (nome NVARCHAR2, cognome NVARCHAR2, indirizzo NVARCHAR2, telefono VARCHAR2, email NVARCHAR2,
                                    codice_fiscale VARCHAR2, partita_iva VARCHAR2)
    RETURN SELF AS RESULT
    IS
    BEGIN
        pkg_log.send_message(SYSTIMESTAMP||' creazione oggetto di tipo: ', 'Clienti');
        SELF.init_c(nome, cognome, indirizzo, telefono, email, codice_fiscale, partita_iva);
    RETURN;
    END;
------------------------------------------------------------------
    MEMBER PROCEDURE init_c(nome NVARCHAR2, cognome NVARCHAR2, indirizzo NVARCHAR2, telefono VARCHAR2, email NVARCHAR2,
                          codice_fiscale VARCHAR2, partita_iva VARCHAR2)
    IS
    BEGIN
        (SELF as Soggetti_T).init(nome, cognome, indirizzo, telefono, email, codice_fiscale, partita_iva);
        SELF.saldo := 0;
        SELF.sconto := 0;
        pkg_log.send_message(SYSTIMESTAMP||' ', 'inizializzazione campi completata');
    END;
END;

 create table clienti_table of clienti_t (
    id primary key,
    cognome not null,
    indirizzo not null,
    codice_fiscale not null unique,
    partita_iva unique)

----sequence per autoincrement id-------
CREATE SEQUENCE custid_seq;

CREATE OR REPLACE TRIGGER custid_trig
BEFORE INSERT ON clienti_table
FOR EACH ROW
WHEN (new.id IS NULL)
BEGIN
  SELECT custid_seq.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
----------------
declare
    cust clienti_t;
begin
    cust := new clienti_t('Giovanni', 'Verdi', 'Via Colle 1', '3217699065', 'giovanni.verdi@mail.it', 'GVNVRD76T13N156R', null);
    insert into clienti_table values cust;
end;

--------------------------------------------

CREATE OR REPLACE TYPE Fornitori_T UNDER Soggetti_T
(
    corriere NVARCHAR2(35),
    qta_minima_partita NUMBER(38),
    tempi_consegna_gg NUMBER(38),
    
    CONSTRUCTOR FUNCTION Fornitori_T (nome NVARCHAR2, cognome NVARCHAR2, indirizzo NVARCHAR2, telefono VARCHAR2, email NVARCHAR2,
                                     codice_fiscale VARCHAR2, partita_iva VARCHAR2, corriere NVARCHAR2, qta_minima_partita NUMBER)
    RETURN SELF AS RESULT,
    MEMBER PROCEDURE init_f(nome NVARCHAR2, cognome NVARCHAR2, indirizzo NVARCHAR2, telefono VARCHAR2, email NVARCHAR2,
                          codice_fiscale VARCHAR2, partita_iva VARCHAR2, corriere NVARCHAR2, qta_minima_partita NUMBER)
) NOT FINAL;
-----------------------------
CREATE OR REPLACE TYPE BODY Fornitori_T AS
------------------------------------------------------------------
    CONSTRUCTOR FUNCTION Fornitori_T (nome NVARCHAR2, cognome NVARCHAR2, indirizzo NVARCHAR2, telefono VARCHAR2, email NVARCHAR2,
                                    codice_fiscale VARCHAR2, partita_iva VARCHAR2, corriere NVARCHAR2, qta_minima_partita NUMBER)
    RETURN SELF AS RESULT
    IS
    BEGIN
        pkg_log.send_message(SYSTIMESTAMP||' creazione oggetto di tipo: ', 'Fornitori');
        SELF.init_f(nome, cognome, indirizzo, telefono, email, codice_fiscale, partita_iva, corriere, qta_minima_partita);
    RETURN;
    END;
------------------------------------------------------------------
    MEMBER PROCEDURE init_f(nome NVARCHAR2, cognome NVARCHAR2, indirizzo NVARCHAR2, telefono VARCHAR2, email NVARCHAR2,
                            codice_fiscale VARCHAR2, partita_iva VARCHAR2, corriere NVARCHAR2, qta_minima_partita NUMBER)
    IS
    BEGIN
        (SELF as Soggetti_T).init(nome, cognome, indirizzo, telefono, email, codice_fiscale, partita_iva);
        SELF.corriere := corriere;
        SELF.qta_minima_partita := qta_minima_partita;
        pkg_log.send_message(SYSTIMESTAMP||' ', 'inizializzazione campi completata');
    END;
END;


create table fornitori_table of fornitori_t (
    id primary key,
    cognome not null,
    indirizzo not null,
    codice_fiscale not null unique,
    partita_iva unique,
    corriere not null,
    qta_minima_partita not null)

 -------sequence per autoincrement id------------
CREATE SEQUENCE forn_id_seq;

CREATE OR REPLACE TRIGGER forn_id_trig
BEFORE INSERT ON fornitori_table
FOR EACH ROW
WHEN (new.id IS NULL)
BEGIN
  SELECT forn_id_seq.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
-----------------------------
declare
    forn fornitori_t;
begin
    forn := new fornitori_t(null, 'Azienda spa', 'Via Monte 24', '3457689009', 'info@azienda.it', '63748778743', '63748778743',
    'Bartolini', 10);
    insert into fornitori_table values forn;
end;
select * from fornitori_table
begin
pkg_log.open_connection;
end;
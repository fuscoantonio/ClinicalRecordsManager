CREATE OR REPLACE TYPE Soggetti_T AS OBJECT
(
    id NUMBER(38),
    nome NVARCHAR2(35),
    indirizzo NVARCHAR2(100),
    telefono VARCHAR2(15),
    email NVARCHAR2(320),
    partita_iva CHAR(11),
    is_cliente CHAR(2),
    is_fornitore CHAR(2),
    numero_ordini NUMBER(38),
    --città_principale

    CONSTRUCTOR FUNCTION Soggetti_T (nome NVARCHAR2, indirizzo NVARCHAR2, is_cliente CHAR,
                                    is_fornitore CHAR, partita_iva CHAR)
    RETURN SELF AS RESULT,

    MEMBER PROCEDURE init(nome NVARCHAR2, indirizzo NVARCHAR2, is_cliente CHAR, is_fornitore CHAR, partita_iva CHAR)
)NOT FINAL;

CREATE OR REPLACE TYPE BODY Soggetti_T AS
------------------------------------------------------------------
    CONSTRUCTOR FUNCTION Soggetti_T (nome NVARCHAR2, indirizzo NVARCHAR2, is_cliente CHAR, is_fornitore CHAR, partita_iva CHAR)
    RETURN SELF AS RESULT
    IS
    BEGIN
        SELF.init(nome, indirizzo, is_cliente, is_fornitore, partita_iva);
    RETURN;
    END;
------------------------------------------------------------------
    MEMBER PROCEDURE init(nome NVARCHAR2, indirizzo NVARCHAR2, is_cliente CHAR, is_fornitore CHAR, partita_iva CHAR)
    IS
    BEGIN
        SELF.nome := nome;
        SELF.indirizzo := indirizzo;
        SELF.is_cliente := is_cliente;
        SELF.is_fornitore := is_fornitore;
        SELF.partita_iva := partita_iva;
        SELF.numero_ordini := 0;
    END;
END;

------------------------------------------

CREATE OR REPLACE TYPE PersoneFisiche_T UNDER Soggetti_T
(
    cognome NVARCHAR2(35),
    codice_fiscale CHAR(16),
    
    CONSTRUCTOR FUNCTION PersoneFisiche_T (nome NVARCHAR2, cognome NVARCHAR2, indirizzo NVARCHAR2,
                                           codice_fiscale CHAR, is_cliente CHAR, is_fornitore CHAR, partita_iva CHAR)
    RETURN SELF AS RESULT,
    MEMBER PROCEDURE init (nome NVARCHAR2, cognome NVARCHAR2, indirizzo NVARCHAR2, codice_fiscale CHAR,
                            is_cliente CHAR, is_fornitore CHAR, partita_iva CHAR)
) NOT FINAL;

CREATE OR REPLACE TYPE BODY PersoneFisiche_T AS
------------------------------------------------------------------
    CONSTRUCTOR FUNCTION PersoneFisiche_T (nome NVARCHAR2, cognome NVARCHAR2, indirizzo NVARCHAR2,
                                        codice_fiscale CHAR, is_cliente CHAR, is_fornitore CHAR, partita_iva CHAR)
    RETURN SELF AS RESULT
    IS
    BEGIN
        pkg_log.send_message(SYSTIMESTAMP||' creazione oggetto di tipo: ', 'PersoneFisiche');
        SELF.init(nome, cognome, indirizzo, codice_fiscale, is_cliente, is_fornitore, partita_iva);
    RETURN;
    END;
------------------------------------------------------------------
    MEMBER PROCEDURE init (nome NVARCHAR2, cognome NVARCHAR2, indirizzo NVARCHAR2, codice_fiscale CHAR,
                          is_cliente CHAR, is_fornitore CHAR, partita_iva CHAR)
    IS
    BEGIN
        (SELF as Soggetti_T).init(nome, indirizzo, is_cliente, is_fornitore, partita_iva);
        SELF.cognome := cognome;
        SELF.codice_fiscale := codice_fiscale;
        pkg_log.send_message(SYSTIMESTAMP||' ', 'inizializzazione campi completata');
    END;
END;

-------tabella persone fisiche-----------
create table personefisiche_table of personefisiche_t (
    id primary key,
    nome not null,
    cognome not null,
    indirizzo not null,
    codice_fiscale not null unique,
    partita_iva unique,
    is_cliente not null,
    is_fornitore not null)

create index persone_id_index on personefisiche_table (id);

-------sequence per autoincrement persone e aziende--------
CREATE SEQUENCE soggetti_id_seq;

----trigger per autoincrement id-------
CREATE OR REPLACE TRIGGER persfisiche_id_trig
BEFORE INSERT ON personefisiche_table
FOR EACH ROW
WHEN (new.id IS NULL)
BEGIN
    SELECT soggetti_id_seq.NEXTVAL
    INTO   :new.id
    FROM   dual;
END;
--------------------------------


CREATE OR REPLACE TYPE Aziende_T UNDER Soggetti_T
(
    responsabile NVARCHAR2(71),
    
    CONSTRUCTOR FUNCTION Aziende_T (nome NVARCHAR2, indirizzo NVARCHAR2, is_cliente CHAR,
                                      is_fornitore CHAR, responsabile NVARCHAR2, partita_iva CHAR)
    RETURN SELF AS RESULT,
    MEMBER PROCEDURE init (nome NVARCHAR2, indirizzo NVARCHAR2, is_cliente CHAR, is_fornitore CHAR,
                            responsabile NVARCHAR2, partita_iva CHAR)
) NOT FINAL;
-----------------------------
CREATE OR REPLACE TYPE BODY Aziende_T AS
------------------------------------------------------------------
    CONSTRUCTOR FUNCTION Aziende_T (nome NVARCHAR2, indirizzo NVARCHAR2, is_cliente CHAR,
                                      is_fornitore CHAR, responsabile NVARCHAR2, partita_iva CHAR)
    RETURN SELF AS RESULT
    IS
    BEGIN
        pkg_log.send_message(SYSTIMESTAMP||' creazione oggetto di tipo: ', 'Aziende');
        SELF.init(nome, indirizzo, is_cliente, is_fornitore, responsabile, partita_iva);
    RETURN;
    END;
------------------------------------------------------------------
    MEMBER PROCEDURE init(nome NVARCHAR2, indirizzo NVARCHAR2, is_cliente CHAR, is_fornitore CHAR,
                          responsabile NVARCHAR2, partita_iva CHAR)
    IS
    BEGIN
        (SELF as Soggetti_T).init(nome, indirizzo, is_cliente, is_fornitore, partita_iva);
        SELF.responsabile := responsabile;
        pkg_log.send_message(SYSTIMESTAMP||' ', 'inizializzazione campi completata');
    END;
END;

-------tabella aziende-----------
create table aziende_table of aziende_t (
    id primary key,
    nome not null,
    indirizzo not null,
    partita_iva not null unique,
    responsabile not null,
    is_cliente not null,
    is_fornitore not null)
    
create index aziende_name_index on aziende_table (partita_iva);

----trigger per autoincrement id-------
CREATE OR REPLACE TRIGGER aziende_id_trig
BEFORE INSERT ON aziende_table
FOR EACH ROW
WHEN (new.id IS NULL)
BEGIN
    SELECT soggetti_id_seq.NEXTVAL
    INTO   :new.id
    FROM   dual;
END;
--------------ordini type------------------

CREATE OR REPLACE TYPE Ordini_T AS OBJECT
(
    id NUMBER(38),
    id_cliente NUMBER(38),
    data_ordine DATE,
    
    CONSTRUCTOR FUNCTION Ordini_T (id NUMBER, id_cliente NUMBER, data_ordine DATE)
    RETURN SELF AS RESULT,
    MEMBER PROCEDURE init (id NUMBER, id_cliente NUMBER, data_ordine DATE)
) NOT FINAL;
-----------------

CREATE OR REPLACE TYPE BODY Ordini_T AS
------------------------------------------------------------------
    CONSTRUCTOR FUNCTION Ordini_T (id NUMBER, id_cliente NUMBER, data_ordine DATE)
    RETURN SELF AS RESULT
    IS
    BEGIN
        pkg_log.send_message(SYSTIMESTAMP||' creazione oggetto di tipo: ', 'Ordini');
        SELF.init(id, id_cliente, data_ordine);
    RETURN;
    END;
------------------------------------------------------------------
    MEMBER PROCEDURE init(id NUMBER, id_cliente NUMBER, data_ordine DATE)
    IS
    BEGIN
        SELF.id := id;
        SELF.id_cliente := id_cliente;
        SELF.data_ordine := data_ordine;
        pkg_log.send_message(SYSTIMESTAMP||' ', 'inizializzazione campi completata');
    END;
END;

----------tabella ordini-----------
create table ordini_table of ordini_t (
    id primary key,
    id_cliente not null,
    data_ordine not null)
    
----sequence per autoincrement id-------
CREATE SEQUENCE ordinid_seq;

CREATE OR REPLACE TRIGGER ordinid_trig
BEFORE INSERT ON ordini_table
FOR EACH ROW
WHEN (new.id IS NULL)
BEGIN
    SELECT ordinid_seq.NEXTVAL
    INTO   :new.id
    FROM   dual;
END;

--------trigger incremento numero ordini---------

CREATE OR REPLACE TRIGGER num_ordini_trig
  AFTER INSERT ON ordini_table
  FOR EACH ROW
BEGIN
    UPDATE personefisiche_table
       SET numero_ordini = numero_ordini + 1
     WHERE id = :new.id_cliente;
     
     UPDATE aziende_table
       SET numero_ordini = numero_ordini + 1
     WHERE id = :new.id_cliente;
END;

--------trigger riduzione numero ordini---------
/*
CREATE OR REPLACE TRIGGER num_ordini_trig
  AFTER DELETE ON ordini_table
  FOR EACH ROW
BEGIN
    UPDATE personefisiche_table
       SET numero_ordini = numero_ordini - 1
     WHERE id = :new.id_cliente;
END;
*/





















---------trigger id_cliente-------------
CREATE OR REPLACE TRIGGER id_cliente_trig
BEFORE INSERT ON ordini_table
FOR EACH ROW
DECLARE
    id_check boolean;
BEGIN
    id_check := false;
    
    --ciclo su subquery da cui ricava un id da aziende_table uguale a quello id_cliente inserito
    FOR c IN (SELECT id FROM aziende_table WHERE id = :new.id_cliente)
    LOOP 
        --se l'id ricavato dalla subquery è uguale a quello inserito, id_check diventa true e interrompe il ciclo
        if (c.id = :new.id_cliente) then
            id_check := true;
            exit;
        end if;
    END LOOP;
    
    --se id_check è ancora false, controlla in personefisiche_table
    if (not id_check) then
        FOR c IN (SELECT id FROM personefisiche_table WHERE id = :new.id_cliente)
        LOOP
            if (c.id = :new.id_cliente) then
                id_check := true;
                exit;
            end if;
        END LOOP;
    end if;
    
    --se id_check è ancora false, lancia un'eccezione e impedisce l'inserimento dell'id_cliente
    if (not id_check) then
        raise_application_error(-20001, 'ID non associato a un Soggetto');
    end if;
END;

--.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-
CREATE OR REPLACE TRIGGER id_cliente_trig2
BEFORE INSERT ON ordini_table
FOR EACH ROW
DECLARE
    id_check NUMBER;
BEGIN
    BEGIN
        SELECT id
        INTO id_check
        FROM personefisiche_table
        WHERE id = :new.id_cliente;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;
    
    if (id_check is null) then
    BEGIN
        SELECT id
        INTO id_check
        FROM aziende_table
        WHERE id = :new.id_cliente;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            raise_application_error(-20001, 'ID non associato a un Soggetto');
    END;
    end if;
END;

--------query vista info cliente--------
create view Dettaglio_Clienti as
select CONCAT(cust.nome||' ', cust.cognome) as cliente, cust.numero_ordini, MIN(ord.data_ordine) as primo_ordine,
MAX(ord.data_ordine) as ultimo_ordine
from personefisiche_table cust
inner join ordini_table ord
    on cust.id = ord.id_cliente
group by ord.id_cliente, cust.numero_ordini, cust.nome, cust.cognome;

-----------RUOLI-----------

create table ruoli (
    id int primary key not null,
    ruolo varchar2(30) not null)
    
create table ruolo_soggetti (
    id_soggetto int not null,
    id_ruolo int not null,
    constraint PK_ruolo primary key(id_soggetto, id_ruolo),
    constraint FK_ruolo foreign key (id_ruolo) references Ruoli(id))
    
--------trigger id_soggetto ruolo--------
CREATE OR REPLACE TRIGGER ruolo_sogg_trig
BEFORE INSERT ON ruolo_soggetti
FOR EACH ROW
DECLARE
    id_check NUMBER;
BEGIN
    BEGIN
        SELECT id
        INTO id_check
        FROM personefisiche_table
        WHERE id = :new.id_soggetto;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;
    
    if (id_check is null) then
    BEGIN
        SELECT id
        INTO id_check
        FROM aziende_table
        WHERE id = :new.id_soggetto;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            raise_application_error(-20001, 'ID non associato a un Soggetto');
    END;
    end if;
END;

------------------------------------

create table relazione_soggetti (
    id_soggetto int not null,
    nome_soggetto nvarchar2(35),
    id_soggetto2 int not null,
    nome_soggetto2 nvarchar2(35),
    id_ruolo int not null,
    constraint PK_relazione primary key (id_soggetto, id_soggetto2, id_ruolo))
    
--------trigger relazione soggetti----------

CREATE OR REPLACE TRIGGER rel_sogg_trig
BEFORE INSERT ON relazione_soggetti
FOR EACH ROW
DECLARE
    sogg_check boolean;
    sogg2_check boolean;
BEGIN
    sogg_check := false;
    sogg2_check := false;

    FOR c IN (SELECT id, nome FROM aziende_table WHERE id = :new.id_soggetto or id = :new.id_soggetto2)
    LOOP 
    if (not sogg_check or not sogg2_check) then
        if (c.id = :new.id_soggetto) then
            sogg_check := true;
            :new.nome_soggetto := c.nome;
        elsif (c.id = :new.id_soggetto2) then
            sogg2_check := true;
            :new.nome_soggetto2 := c.nome;
        end if;
    end if;
    END LOOP;
    
    if (not sogg_check or not sogg2_check) then
        FOR c IN (SELECT id, nome FROM personefisiche_table WHERE id = :new.id_soggetto or id = :new.id_soggetto2)
        LOOP 
        if (not sogg_check or not sogg2_check) then
            if (c.id = :new.id_soggetto) then
                sogg_check := true;
                :new.nome_soggetto := c.nome;
            elsif (c.id = :new.id_soggetto2) then
                sogg2_check := true;
                :new.nome_soggetto2 := c.nome;
            end if;
        end if;
        END LOOP;
    end if;
    
    if (not sogg_check and not sogg2_check) then
        raise_application_error(-20001, 'id_soggetto e id_soggetto2 non associati a un Soggetto');
    elsif (not sogg_check) then
        raise_application_error(-20001, 'id_soggetto non associato a un Soggetto');
    elsif (not sogg2_check) then
        raise_application_error(-20001, 'id_soggetto2 non associato a un Soggetto');
    end if;
END;

create view relazione_soggetti_ruoli as
select re.id_soggetto, re.nome_soggetto, re.id_soggetto2, re.nome_soggetto2, ruo.ruolo
from relazione_soggetti re
inner join ruoli ruo
    on re.id_ruolo = ruo.id;
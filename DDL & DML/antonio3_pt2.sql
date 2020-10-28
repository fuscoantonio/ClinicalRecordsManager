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
    str_error VARCHAR2(100);
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
        BEGIN
            str_error := 'ID: '||new.id_cliente||' non associato a un Soggetto';
            pkg_log.send_message('error: ', str_error);
            raise_application_error(-20001, str_error);
        END;
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
-------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------PARTIE 01--------------------------------------------------------------
-- 1. Créer un compte utilisateur Master avec tous les privilèges

create user Master identified by psw;
grant all privileges to Master;

-------------------------------------------------------------------------------------------------------------------------------
-- 2. Créer les tables

CREATE TABLE Wilaya (
    CodeWilaya number(10),
    NomWilaya varchar(10),
    constraint pk_wilaya PRIMARY KEY (codeWilaya)
);

CREATE TABLE Ville(
    CodeVille number(10),
    NomVille varchar(10),
    CodeWilaya number(10),
    constraint pk_ville PRIMARY KEY (CodeVille),
    constraint fk_wilaya FOREIGN KEY(CodeWilaya) references Wilaya(CodeWilaya)
);

CREATE TABLE Client(
    NumClient number(10),
    NomClient varchar(10),
    SexeClient varchar(1),
    codeVille number(10),
    constraint pk_client PRIMARY KEY (NumClient),
    constraint fk_ville FOREIGN KEY (CodeVille) references Ville(CodeVille),
    constraint checkSexeClient Check (sexeClient in ('F','H'))
);

CREATE TABLE TypeLigne(
    CodeTypeLigne number(10),
    TypeLigne varchar(10),
    constraint pk_typeLigne PRIMARY KEY (CodeTypeLigne)
);

CREATE TABLE Ligne(
    NumeroLigne number(10),
    NumClient number(10),
    CodeTypeLigne number(10),
    constraint pk_ligne PRIMARY KEY(NumeroLigne),
    constraint fk_client FOREIGN KEY (NumClient) references Client(NumClient),
    constraint fk_typeLigne FOREIGN KEY (CodeTypeLigne) references TypeLigne(CodeTypeLigne)
);

CREATE TABLE Destinataire(
    CodeOperateurDstinataire number(10),
    NomOperateurDstinataire varchar(50),
    constraint pk_destinataire PRIMARY KEY (CodeOperateurDstinataire)
);

CREATE TABLE TypeAppel(
    CodeTypeAppel number(10),
    TypeAppel varchar(20),
    constraint pk_typeTable PRIMARY KEY (CodeTypeAppel)
);

CREATE TABLE Appel(
    CodeAppel number(10),
    DureeAppel number(10),
    DateaAppel Date,
    NumeroLigne number(10),
    CodeOperateurDstinataire number(10),
    CodeTypeAppel number(10),
    constraint pk_codeAppel PRIMARY KEY(CodeAppel),
    constraint fk_ligne FOREIGN KEY (NumeroLigne) references Ligne (NumeroLigne),
    constraint fk_destinataire FOREIGN KEY (CodeOperateurDstinataire) references Destinataire (CodeOperateurDstinataire),
    constraint fk_codeTypeAppel FOREIGN KEY (CodeTypeAppel) references TypeAppel (CodeTypeAppel)
);
-------------------------------------------------------------------------------------------------------------------------------
--3. Remplir les tables

DECLARE
    Wilaya char(10);
    CodeW number;

    begin
        for CodeW in 1..58 loop
            SELECT dbms_random.string('U', 8) into Wilaya from dual;
            INSERT INTO Wilaya VALUES(codeW, Wilaya);
        end loop;
        commit;
    end;
    /

DECLARE
    Ville char(10);
    CodeW number;
    CodeV number;

    begin
        for CodeV in 1..547 loop
            SELECT dbms_random.string('U', 8) into Ville from dual;
            SELECT floor(dbms_random.value(1, 58.9)) into CodeW from dual;
            INSERT INTO Ville VALUES(codeV, Ville, codeW);
        end loop;
        commit;
    end;
    /

CREATE TABLE SEXE(
IDSEXE number(1),
SEXE varchar(1),
constraint pk_sexe PRIMARY KEY (IDSEXE)
);
INSERT INTO SEXE VALUES(1, 'F');
INSERT INTO SEXE VALUES(2, 'H');

DECLARE
    Client char(10);
    CodeV number;
    NumClient number;
    SexeClient varchar(1);

    begin
        for NumClient in 1.. loop
            SELECT dbms_random.string('U', 10) into Client from dual;
            SELECT floor(dbms_random.value(1, 547.9)) into CodeV from dual;
            Select SEXE into SexeClient from SEXE where IDSEXE = (SELECT TRUNC(DBMS_RANDOM.value(1,2.9)) from dual);
            INSERT INTO Client VALUES(NumClient, Client, SexeClient, codeV);
        end loop;
        commit;
    end;
    /


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------PARTIE 02---------------------------------------------------------------------

--1.  Remplir la table TypeAppel

INSERT INTO TypeAppel VALUES(1, 'Nationale');
INSERT INTO TypeAppel VALUES(2, 'Internationale');

--2.  Remplir la table TypeLigne

DECLARE
    TypeL char(10);
    CodeTL number;

    begin
        for CodeTL in 1..10 loop
            SELECT dbms_random.string('U', 10) into TypeL from dual;
            INSERT INTO TypeLigne VALUES(CodeTL, TypeL);
        end loop;
        commit;
    end;
    /

PL/SQL procedure successfully completed.

-- Remplir la table Ligne

DECLARE

    numLigne number;
    NumClient number;
    CodeTypeLigne number;

    begin
        for numLigne in 1..1500255 loop
            SELECT floor(dbms_random.value(1, 1065566.9)) into numClient from dual;
            SELECT floor(dbms_random.value(1, 10.9)) into CodeTypeLigne from dual;
            INSERT INTO Ligne VALUES(numLigne, NumClient, CodeTypeLigne);
        end loop;
        commit;
    end;
    /

-- Remplir la table Destinataire

DECLARE

    codeOD number;
    nomOD char(10);
    
    begin
        for codeOD in 1..522 loop
            SELECT dbms_random.string('U', 10) into nomOD from dual;
            INSERT INTO Destinataire VALUES(codeOD, nomOD);
        end loop;
        commit;
    end;
    /

-- Remplir la table Appel

DECLARE
    CodeApp number;
    Duree number;
    DateApp date;
    codeTA number;
    NumL number;
    CodeOD number;
BEGIN
    FOR CodeApp IN 1.. 3500220 LOOP
        SELECT floor(dbms_random.value(1, 60.9)) into Duree from dual;
        SELECT TO_DATE(trunc(dbms_random.value(to_char(date '2020-01-01','J'), to_char(date '2021-12-31','J'))),'J') into DateApp from dual;
        SELECT floor(dbms_random.value(1,2.9)) into codeTA from dual;
        SELECT floor(dbms_random.value(1,1500255.9)) into NumL from dual;
        SELECT floor(dbms_random.value(1,522.9)) into codeOD from dual;
        INSERT INTO Appel VALUES (CodeApp, Duree, DateApp, NumL, codeOD, CodeTA);
    END LOOP;
    COMMIT;
    END;
    /

-------------------------------------------------------------------------------------------------------------------------------

-- 4. 

---- a. Quel est le nombre d’appel effectués de chaque wilaya entre (01/01/2021, et 30/01/2021)?

SELECT w.CodeWilaya, count(a.CodeAppel) AS NOMBRE_APPEL
FROM Wilaya w, Ville v, Client c, Ligne l, Appel a
WHERE w.CodeWilaya = v.CodeWilaya AND v.CodeVille = c.CodeVille 
AND C.NumClient = l.NumClient AND l.NumeroLigne = a.NumeroLigne
AND TO_DATE(DateaAppel) BETWEEN (TO_DATE('01-01-2021', 'dd/mm/yyyy')) AND (TO_DATE('30-01-2021', 'dd/mm/yyyy'))
GROUP BY w.CodeWilaya
Order by w.CodeWilaya;

--- b. Quel est le nombre d’appel effectués par type d’appel par année?

SELECT CodeTypeAppel, EXTRACT(YEAR FROM DateaAppel) AS YEAR, count(*) AS mombre_Appel 
FROM Appel 
GROUP BY CodeTypeAppel, EXTRACT(YEAR FROM DateaAppel)
ORDER BY EXTRACT(YEAR FROM DateaAppel), CodeTypeAppel;

--c.1. Quelle est la wilaya dont le nombre d’appels est maximal en 2020?

SELECT w.CodeWilaya, count(a.CodeAppel) AS MAX_NBR_APPEL
FROM Wilaya w, Ville v, Client c, Ligne l, Appel a
WHERE w.CodeWilaya = v.CodeWilaya AND v.CodeVille = c.CodeVille 
AND C.NumClient = l.NumClient AND l.NumeroLigne = a.NumeroLigne
AND EXTRACT(YEAR FROM a.DateaAppel) = 2020
GROUP BY w.CodeWilaya
Order by count(a.CodeAppel) desc
FETCH FIRST 1 ROWS ONLY;

--c.2. Quelle est la wilaya dont le nombre d’appels est maximal en 2021?

SELECT w.CodeWilaya, count(a.CodeAppel) AS MAX_NBR_APPEL
FROM Wilaya w, Ville v, Client c, Ligne l, Appel a
WHERE w.CodeWilaya = v.CodeWilaya AND v.CodeVille = c.CodeVille 
AND C.NumClient = l.NumClient AND l.NumeroLigne = a.NumeroLigne
AND EXTRACT(YEAR FROM a.DateaAppel) = 2021
GROUP BY w.CodeWilaya
Order by count(a.CodeAppel) desc
FETCH FIRST 1 ROWS ONLY;
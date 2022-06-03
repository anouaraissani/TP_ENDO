--------------------------------------------------- TP3 ENDO ---------------------------------------------------
--Créer un nouvel utilisateur

create user TP3ENDO identified by psw;
grant all privileges to TP3ENDO;
connect TP3ENDO/ psw;

--Créer le schéma (tables + contraintes)

CREATE TABLE DClient (
        CodeClient NUMBER(10),
        NomClient VARCHAR(10),
        SexeClient VARCHAR(1),
        CodeVille VARCHAR(10), 
        NomVille VARCHAR(10), 
        CodeWilaya VARCHAR(10), 
        NomWilaya VARCHAR(10),
        CONSTRAINT pk_DClient PRIMARY KEY (CodeClient)
);
CREATE TABLE DTypeLigne (
    CodeTypeLigne NUMBER(10), 
    TypeLigne VARCHAR(10),
    CONSTRAINT pf_DTypeLigne PRIMARY KEY (CodeTypeLigne)
);
CREATE TABLE DTypeAppel (
    CodeTypeAppel NUMBER(10), 
    TypeAppel VARCHAR(20),
    CONSTRAINT pk_DTypeAppel PRIMARY KEY (CodeTypeAppel)
);
CREATE TABLE DDestinataire (
    CodeOperateurDestinataire NUMBER(10), 
    NomOperateurDestinataire VARCHAR(50),
    CONSTRAINT pk_DDestinataire PRIMARY KEY (CodeOperateurDestinataire)
);
CREATE TABLE DTemps (
    CodeTemps NUMBER(10), 
    Jour VARCHAR(10), 
    LibJour VARCHAR(10), 
    Mois VARCHAR(7), 
    Libmois VARCHAR(10), 
    Annee VARCHAR(4),
    CONSTRAINT pk_DTemps PRIMARY KEY (CodeTemps)
);
CREATE TABLE FAppel (
    CodeClient NUMBER(10), 
    CodeTypeLigne NUMBER(10), 
    CodeTypeAppel NUMBER(10), 
    CodeOperateurDestinataire NUMBER(10), 
    CodeTemps NUMBER(10), 
    NBAppels NUMBER, 
    Duree NUMBER,
    CONSTRAINT fk_DClient FOREIGN KEY (CodeClient) REFERENCES DClient (CodeClient),
    CONSTRAINT fk_DTypeLigne FOREIGN KEY (CodeTypeLigne) REFERENCES DTypeLigne (CodeTypeLigne),
    CONSTRAINT fk_DTypeAppel FOREIGN KEY (CodeTypeAppel) REFERENCES DTypeAppel (CodeTypeAppel),
    CONSTRAINT fk_DDestinataire FOREIGN KEY (CodeOperateurDestinataire) REFERENCES DDestinataire (CodeOperateurDestinataire),
    CONSTRAINT fk_DTemps FOREIGN KEY (CodeTemps) REFERENCES DTemps (CodeTemps),
    CONSTRAINT pk_FAppel PRIMARY KEY (CodeClient, CodeTypeLigne, CodeTypeAppel, CodeOperateurDestinataire, CodeTemps)
);

--Remplir les tables

------- Remplir la table DClient

begin
for i in
( SELECT c.NumClient, c.NomClient, c.SexeClient, v.CodeVille, v.NomVille, w.CodeWilaya, w.NomWilaya  
FROM master.Client c, master.Ville v, master.Wilaya w
WHERE c.CodeVille = v.CodeVille 
AND v.CodeWilaya = w.CodeWilaya) loop
insert into DClient values(i.NumClient, i.NomClient, i.SexeClient, i.CodeVille, i.NomVille, i.CodeWilaya, i.NomWilaya);
end loop;
commit ;
end ;
/

------- Remplir la table DTypeLigne

begin
for i in
( SELECT CodeTypeLigne, TypeLigne 
FROM master.TypeLigne) loop
insert into DTypeLigne values(i.CodeTypeLigne, i.TypeLigne);
end loop;
commit ;
end ;
/

------- Remplir la table DTypeAppel

begin
for i in
( SELECT CodeTypeAppel, TypeAppel
FROM master.TypeAppel) loop
insert into DTypeAppel values(i.CodeTypeAppel, i.TypeAppel);
end loop;
commit ;
end ;
/

------- Remplir la table DDestinataire

begin
for i in
( SELECT CodeOperateurDstinataire, NomOperateurDstinataire
FROM master.Destinataire) loop
insert into DDestinataire values(i.CodeOperateurDstinataire, i.NomOperateurDstinataire);
end loop;
commit ;
end ;
/

--Creer une séquence pour la clé primaire du DTemps

CREATE SEQUENCE seq
MINVALUE 1
MAXVALUE 100000
START WITH 1
INCREMENT BY 1;

------- Remplir la table DTemps

BEGIN
For I in (SELECT distinct
TO_CHAR(DateAppel,'DD/MM/YYYY') as jour,
TO_CHAR(DateAppel,'DAY') as libjour, 
TO_CHAR(DateAppel,'MM/YYYY') as Mois, 
TO_CHAR(DateAppel,'MONTH') as Libmois, 
TO_CHAR(DateAppel,'YYYY') as Annee
FROM master.Appel)LOOP
Insert into Dtemps values (seq.nextval, i.jour, i.libjour, i.Mois, i.Libmois, i.Annee) ;
END LOOP;
Commit ;
end ;
/

------- Remplir la table FAppel

begin
for i in
( SELECT DISTINCT c.NumClient , l.CodeTypeLigne, a.CodeTypeAppel, a.CodeOperateurDstinataire, t.CodeTemps,
count(*) as NBAppels, SUM(a.DureeAppel) as Duree
FROM master.Client c, master.Ligne l,master.Appel a, DTemps t
WHERE  c.NumClient = l.NumClient
AND l.NumeroLigne = a.NumeroLigne
AND t.Jour = TO_CHAR(a.DateAppel,'DD/MM/YYYY')
GROUP BY c.NumClient, l.CodeTypeLigne, a.CodeTypeAppel, a.CodeOperateurDstinataire, t.CodeTemps)
LOOP
insert into FAppel values(i.NumClient, i.CodeTypeLigne, i.CodeTypeAppel, i.CodeOperateurDstinataire, i.CodeTemps, i.NBAppels, i.Duree);
end loop;
commit ;
end ;
/

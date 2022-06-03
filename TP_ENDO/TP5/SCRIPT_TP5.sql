--1
--connecter
connect TP3ENDO/ psw;
--
SET TIMING ON
SET AUTOTRACE ON EXPLAIN
--
SELECT COUNT(*) FROM DClient WHERE SexeClient = 'H';
-------------------------------------------------------
--2
CREATE INDEX SexeClient_index
ON DClient (SexeClient);
---index(DClient SexeClient_index)
-------------------------------------------------------
--3
alter system flush shared_pool;
alter system flush buffer_cache;
--
SELECT COUNT(*) FROM DClient WHERE SexeClient = 'H';
-------------------------------------------------------
--4
DROP INDEX SexeClient_index;
--
CREATE BITMAP INDEX SexeClient_index
ON DClient (SexeClient);
-------------------------------------------------------
--5
alter system flush shared_pool;
alter system flush buffer_cache;
--
SELECT COUNT(*) FROM DClient WHERE SexeClient = 'H';
-------------------------------------------------------
--6
DROP INDEX SexeClient_index;
-------------------------------------------------------
--7
SELECT SUM(a.NBAppels)
FROM FAppel a, DDestinataire d
WHERE a.CodeOperateurDestinataire = d.CodeOperateurDestinataire
AND d.NomOperateurDestinataire = 'Mobilis';
-------------------------------------------------------
--8
CREATE BITMAP INDEX NomOpDest_index
ON FAppel(DDestinataire.NomOperateurDestinataire)
FROM DDestinataire, FAppel
WHERE FAppel.CodeOperateurDestinataire = DDestinataire.CodeOperateurDestinataire;
-------------------------------------------------------
--9
alter system flush shared_pool;
alter system flush buffer_cache;
--
SELECT COUNT(a.CodeOperateurDestinataire)
FROM FAppel a, DDestinataire d
WHERE a.CodeOperateurDestinataire = d.CodeOperateurDestinataire
AND d.NomOperateurDestinataire = 'Mobilis';
-------------------------------------------------------
--10
SELECT COUNT(a.CodeTypeAppel) AS nbr_appel_international
FROM FAppel a, DTypeAppel t
WHERE a.CodeTypeAppel = t.CodeTypeAppel
AND t.TypeAppel = 'Internationale';
-------------------------------------------------------
--11
CREATE BITMAP INDEX NbrAppInter_index
ON FAppel(DTypeAppel.TypeAppel)
FROM DTypeAppel, FAppel
WHERE FAppel.CodeTypeAppel = DTypeAppel.CodeTypeAppel;
-------------------------------------------------------
--12
alter system flush shared_pool;
alter system flush buffer_cache;
--
SELECT COUNT(a.CodeTypeAppel) AS nbr_appel_international
FROM FAppel a, DTypeAppel t
WHERE a.CodeTypeAppel = t.CodeTypeAppel
AND t.TypeAppel = 'Internationale';
-------------------------------------------------------
--13
CREATE TABLE FAppel2 (
    CodeClient NUMBER(10), 
    CodeTypeLigne NUMBER(10), 
    CodeTypeAppel NUMBER(10), 
    CodeOperateurDestinataire NUMBER(10), 
    CodeTemps NUMBER(10), 
    NBAppels NUMBER, 
    Duree NUMBER,
    CONSTRAINT fk_DClient2 FOREIGN KEY (CodeClient) REFERENCES DClient (CodeClient),
    CONSTRAINT fk_DTypeLigne2 FOREIGN KEY (CodeTypeLigne) REFERENCES DTypeLigne (CodeTypeLigne),
    CONSTRAINT fk_DTypeAppel2 FOREIGN KEY (CodeTypeAppel) REFERENCES DTypeAppel (CodeTypeAppel),
    CONSTRAINT fk_DDestinataire2 FOREIGN KEY (CodeOperateurDestinataire) REFERENCES DDestinataire (CodeOperateurDestinataire),
    CONSTRAINT fk_DTemps2 FOREIGN KEY (CodeTemps) REFERENCES DTemps (CodeTemps),
    CONSTRAINT pk_FAppel2 PRIMARY KEY (CodeClient, CodeTypeLigne, CodeTypeAppel, CodeOperateurDestinataire, CodeTemps)
)
PARTITION BY LIST (CodeTypeLigne)
    (PARTITION partition1 VALUES (1, 3, 6),
    PARTITION partition2 VALUES (2, 7, 8),
    PARTITION partition3 VALUES (4, 5),
    PARTITION partition4 VALUES (9, 10)
);
-------------------------------------------------------
--14
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
insert into FAppel2 values(i.NumClient, i.CodeTypeLigne, i.CodeTypeAppel, i.CodeOperateurDstinataire, i.CodeTemps, i.NBAppels, i.Duree);
end loop;
commit ;
end ;
/
-------------------------------------------------------
--15
alter system flush shared_pool;
alter system flush buffer_cache;
--
SELECT COUNT(CodeTypeLigne)FROM FAppel  WHERE CodeTypeLigne = 8 ;
-------------------------------------------------------
--16
COUNT(CodeTypeLigne)FROM FAppel2  WHERE CodeTypeLigne = 8 ;
-------------------------------------------------------
--17
--On supprime les index existant
drop index NOMOPDEST_INDEX;
drop index NBRAPPINTER_INDEX;
--On crée un index sur l'attribut "CodeTypeLigne"
create index CodeTypeLigne_index on FAppel(CodeTypeLigne);
--On modifie la table FAppel
Alter TABLE FAppel MODIFY PARTITION BY LIST (CodeTypeLigne)
    (PARTITION partition1 VALUES (1, 3, 6),
    PARTITION partition2 VALUES (2, 7, 8),
    PARTITION partition3 VALUES (4, 5),
    PARTITION partition4 VALUES (9, 10)
) ONLINE;
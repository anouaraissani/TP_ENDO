SET TIMING ON
SET AUTOTRACE ON EXPLAIN

--1
SELECT t.Mois, c.NomWilaya, ta.TypeAppel, sum(a.NBAppels) as NBAppels
FROM FAppel a,DTypeAppel ta,DTemps t, DClient c
WHERE a.CodeTemps = t.CodeTemps
AND a.CodeClient = c.CodeClient
AND a.CodeTypeAppel = ta.CodeTypeAppel
GROUP BY t.Mois, c.NomWilaya, ta.TypeAppel
ORDER BY t.Mois, c.NomWilaya, ta.TypeAppel;

alter system flush shared_pool;
alter system flush buffer_cache;

--2
SELECT t.Mois, c.NomWilaya, ta.TypeAppel, sum(a.NBAppels) as NBAppels
FROM FAppel a,DTypeAppel ta,DTemps t, DClient c
WHERE a.CodeTemps = t.CodeTemps
AND a.CodeClient = c.CodeClient
AND a.CodeTypeAppel = ta.CodeTypeAppel
GROUP BY ROLLUP (t.Mois, c.NomWilaya, ta.TypeAppel)
ORDER BY t.Mois, c.NomWilaya, ta.TypeAppel;

alter system flush shared_pool;
alter system flush buffer_cache;

--3
SELECT t.Mois, c.NomWilaya, ta.TypeAppel, sum(a.NBAppels) as NBAppels
FROM FAppel a,DTypeAppel ta,DTemps t, DClient c
WHERE a.CodeTemps = t.CodeTemps
AND a.CodeClient = c.CodeClient
AND a.CodeTypeAppel = ta.CodeTypeAppel
GROUP BY CUBE (t.Mois, c.NomWilaya, ta.TypeAppel)
ORDER BY t.Mois, c.NomWilaya, ta.TypeAppel;

alter system flush shared_pool;
alter system flush buffer_cache;

--4
SELECT t.Mois, c.NomWilaya, ta.TypeAppel, sum(a.NBAppels) as NbrAppelM,
GROUPING_ID(t.Mois, c.NomWilaya, ta.TypeAppel) as GID
FROM FAppel a,DTypeAppel ta,DTemps t, DClient c
WHERE a.CodeTemps = t.CodeTemps
AND a.CodeClient = c.CodeClient
AND a.CodeTypeAppel = ta.CodeTypeAppel
GROUP BY CUBE (t.Mois, c.NomWilaya, ta.TypeAppel)
ORDER BY t.Mois, c.NomWilaya, ta.TypeAppel;

alter system flush shared_pool;
alter system flush buffer_cache;

--5

SELECT t.Annee, c.NomWilaya, sum(a.NBAppels) as NbrAppelM,
Rank() over (ORDER BY sum(a.NBAppels) desc) as classement,
Dense_Rank() over (ORDER BY sum(a.NBAppels) desc) as classement_Dense
FROM FAppel a,DTemps t, DClient c
WHERE a.CodeTemps = t.CodeTemps
AND a.CodeClient = c.CodeClient
GROUP BY t.Annee, c.NomWilaya
ORDER BY t.Annee, c.NomWilaya;

alter system flush shared_pool;
alter system flush buffer_cache;

--6

SELECT t.Annee, c.NomWilaya, sum(a.NBAppels) as NbrAppelM,
Cume_Dist() over (Partition by(t.Annee) ORDER by sum(a.NBAppels) desc) as PC
FROM FAppel a,DTemps t, DClient c
WHERE a.CodeTemps = t.CodeTemps
AND a.CodeClient = c.CodeClient
GROUP BY t.Annee, c.NomWilaya
ORDER BY t.Annee;

alter system flush shared_pool;
alter system flush buffer_cache;

--7
SELECT c.NomWilaya, SUM(a.Duree) as SommeDuree,
NTile(4) over (ORDER BY SUM(a.Duree) desc) as DC
FROM FAppel a, DClient c
WHERE a.CodeClient = c.CodeClient
GROUP BY  c.NomWilaya
ORDER BY c.NomWilaya;

alter system flush shared_pool;
alter system flush buffer_cache;


--8
SELECT t.Mois as Mois, SUM(a.NBAppels) as NBAppels,
AVG(SUM(a.NBAppels)) over (Order by t.Mois Rows 2 preceding) as MOY_NBAppels_3_Mois
FROM FAppel a, DTemps t
WHERE a.CodeTemps = t.CodeTemps
GROUP BY t.Mois;

alter system flush shared_pool;
alter system flush buffer_cache;


--9
SELECT c.NomWilaya as Wilaya, t.Annee as Annee, SUM(a.NBAppels) as NBAppels,
Ratio_to_Report (SUM(a.NBAppels)) over() as Ratio_to_Report
FROM FAPPEL a, DClient c, DTemps t
WHERE a.CodeClient = c.CodeClient
AND a.CodeTemps = t.CodeTemps
GROUP BY c.NomWilaya, t.Annee
ORDER BY c.NomWilaya, t.Annee;

alter system flush shared_pool;
alter system flush buffer_cache;


--10
SELECT t.Annee, d.NomOperateurDestinataire, SUM(a.NBAppels) as NBAppelsD,
MAX(SUM(a.NBAppels))  over (Partition by t.Annee) as Max_Produit_NBAppels
FROM FAppel a, DTemps t, DDestinataire d
WHERE a.CodeTemps = t.CodeTemps
AND a.CodeOperateurDestinataire = d.CodeOperateurDestinataire
GROUP BY t.Annee, d.NomOperateurDestinataire;

SELECT t.Annee, d.NomOperateurDestinataire, NBAppelsD
FROM (SELECT t.Annee, d.NomOperateurDestinataire, SUM(a.NBAppels) as NBAppelsD,
MAX(SUM(a.NBAppels))  over (Partition by t.Annee) as Max_Produit_NBAppels
FROM FAppel a, DTemps t, DDestinataire d
WHERE a.CodeTemps = t.CodeTemps
AND a.CodeOperateurDestinataire = d.CodeOperateurDestinataire
GROUP BY t.Annee, d.NomOperateurDestinataire)
FROM FAppel a, DTemps t, DDestinataire d
WHERE NBAppelsD = Max_Produit_NBAppels;

alter system flush shared_pool;
alter system flush buffer_cache;


--11

------------VUE 
CREATE MATERIALIZED VIEW VMDest 
BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND 
ENABLE QUERY REWRITE AS 
SELECT t.Mois, c.NomWilaya, ta.TypeAppel, sum(a.NBAppels) as NBAppels
FROM FAppel a,DTypeAppel ta,DTemps t, DClient c
WHERE a.CodeTemps = t.CodeTemps
AND a.CodeClient = c.CodeClient
AND a.CodeTypeAppel = ta.CodeTypeAppel
GROUP BY CUBE (t.Mois, c.NomWilaya, ta.TypeAppel);

------------ execution de la requete 
SELECT t.Mois, c.NomWilaya, ta.TypeAppel, sum(a.NBAppels) as NBAppels
FROM FAppel a,DTypeAppel ta,DTemps t, DClient c
WHERE a.CodeTemps = t.CodeTemps
AND a.CodeClient = c.CodeClient
AND a.CodeTypeAppel = ta.CodeTypeAppel
GROUP BY CUBE (t.Mois, c.NomWilaya, ta.TypeAppel)
ORDER BY t.Mois, c.NomWilaya, ta.TypeAppel;


------------INDEX
CREATE BITMAP INDEX R3_index1 
ON FAppel(DTypeAppel.TypeAppel) 
FROM DTypeAppel, FAppel
WHERE FAppel.CodeTypeAppel = DTypeAppel.CodeTypeAppel;

CREATE BITMAP INDEX R3_index2 
ON FAppel(DTemps.Mois) 
FROM DTemps, FAppel
WHERE FAppel.CodeTemps = DTemps.CodeTemps;

CREATE BITMAP INDEX R3_index3 
ON FAppel(DClient.NomWilaya) 
FROM DClient, FAppel
WHERE FAppel.CodeClient = DClient.CodeClient;

------------ execution de la requete 
SELECT t.Mois, c.NomWilaya, ta.TypeAppel, sum(a.NBAppels) as NBAppels
FROM FAppel a,DTypeAppel ta,DTemps t, DClient c
WHERE a.CodeTemps = t.CodeTemps
AND a.CodeClient = c.CodeClient
AND a.CodeTypeAppel = ta.CodeTypeAppel
GROUP BY CUBE (t.Mois, c.NomWilaya, ta.TypeAppel)
ORDER BY t.Mois, c.NomWilaya, ta.TypeAppel;




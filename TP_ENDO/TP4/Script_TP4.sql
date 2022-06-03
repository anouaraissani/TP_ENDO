--1
SET TIMING ON
SET AUTOTRACE ON EXPLAIN

alter system flush shared_pool;
alter system flush buffer_cache;
-----------------------------------------
-----------------------------------------
SELECT COUNT(*) from DDestinataire;
SELECT * from DDestinataire;

UPDATE DDestinataire set NomOperateurDestinataire = 'Mobilis' WHERE CodeOperateurDestinataire = 200;
SELECT COUNT(NBAppels) 
FROM FAppel a, DDestinataire d 
WHERE a.CodeOperateurDestinataire = d.CodeOperateurDestinataire
AND NomOperateurDestinataire = 'Mobilis';

--2
CREATE MATERIALIZED VIEW VMDest 
BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND 
ENABLE QUERY REWRITE AS 
SELECT d.CodeOperateurDestinataire AS CodeOp,
d.NomOperateurDestinataire AS NomOp, SUM(a.NBAppels) AS NBAppels, 
SUM(a.Duree) AS DureeGlobale 
FROM FAppel a, DDestinataire d 
WHERE d.CodeOperateurDestinataire = a.CodeOperateurDestinataire
GROUP BY d.CodeOperateurDestinataire, d.NomOperateurDestinataire;


--3
SELECT COUNT(NBAppels) 
FROM FAppel a, DDestinataire d 
WHERE a.CodeOperateurDestinataire = d.CodeOperateurDestinataire
AND NomOperateurDestinataire = 'Mobilis';

--4
CREATE MATERIALIZED VIEW VMNBMensuel 
BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND 
ENABLE QUERY REWRITE AS 
SELECT t.Mois AS Mois, SUM(NBAppels) AS NBAppels
FROM DTemps t, FAppel a 
WHERE T.CodeTemps = a.NBAppels
GROUP BY t.Mois;

--5
SELECT t.Annee AS Annee,  SUM(a.NBAppels) AS Nombre_Appel_Annuels
FROM DTemps t, FAppel a
WHERE t.CodeTemps = a.CodeTemps
GROUP BY t.Annee;


--6
CREATE DIMENSION DClient_dim
   LEVEL Client   IS (DClient.CodeClient)
   LEVEL Ville    IS (DClient.CodeVille)
   LEVEL Wilaya   IS (DClient.CodeWilaya)
   HIERARCHY hiar (
      Client  CHILD OF
      Ville   CHILD OF 
      Wilaya 
      )         
   ATTRIBUTE Client DETERMINES (DClient.NomClient, DClient.SexeClient) 
   ATTRIBUTE Ville DETERMINES (DClient.NomVille)
   ATTRIBUTE Wilaya DETERMINES (DClient.NomWilaya);
--
--
CREATE DIMENSION DTypeLigne_dim
   LEVEL TypeLigne IS (DTypeLigne.CodeTypeLigne)        
   ATTRIBUTE TypeLigne DETERMINES (DTypeLigne.TypeLigne);
--
--
CREATE DIMENSION DTypeAppel_dim
   LEVEL TypeLigne  IS (DTypeAppel.CodeTypeAppel)        
   ATTRIBUTE TypeLigne DETERMINES (DTypeAppel.TypeAppel);
--
--
CREATE DIMENSION DDestinataire_dim
   LEVEL Destinataire  IS (DDestinataire.CodeOperateurDestinataire)        
   ATTRIBUTE  Destinataire DETERMINES (DDestinataire.NomOperateurDestinataire);
--
--
CREATE DIMENSION DTemps_dim
   LEVEL DTemps IS (DTemps.CodeTemps)        
   ATTRIBUTE  DTemps DETERMINES (DTemps.Jour, DTemps.LibJour, DTemps.Mois, DTemps.Libmois, DTemps.Annee);


--7
Alter session set query_rewrite_integrity=trusted

--8
SELECT t.Annee AS Annee,  SUM(a.NBAppels) AS Nombre_Appel_Annuels
FROM DTemps t, FAppel a
WHERE t.CodeTemps = a.CodeTemps
GROUP BY t.Annee;
----------------------------------------------------------------------
Elapsed: 00:00:00.69
--La Création des méta données de toutes les dimensions aide à reduire le temps d'éxecution des requêtes qui affiches les données
--de la table de fait relie au ces dimensions 


--9
CREATE MATERIALIZED VIEW VMNBVille 
BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND 
ENABLE QUERY REWRITE AS 
SELECT c.CodeVille, c.NomVille, sum(a.NBAppels)
FROM FAppel a, DClient c
WHERE a.CodeClient = c.CodeClient
GROUP BY c.CodeVille, c.NomVille;

--10
alter system flush shared_pool;
alter system flush buffer_cache;

SELECT c.CodeWilaya, c.NomWilaya, sum(a.NBAppels)
FROM FAppel a, DClient c
WHERE a.CodeClient = c.CodeClient
GROUP BY c.CodeWilaya, c.NomWilaya;
-----------------------------------
Elapsed: 00:00:00.27

--12
DROP DIMENSION DClient_dim;

alter system flush shared_pool;
alter system flush buffer_cache;

SELECT c.CodeWilaya, c.NomWilaya, sum(a.NBAppels)
FROM FAppel a, DClient c
WHERE a.CodeClient = c.CodeClient
GROUP BY c.CodeWilaya, c.NomWilaya;



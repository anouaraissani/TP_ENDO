
--1.
CREATE MATERIALIZED VIEW VM1
BUILD IMMEDIATE 
REFRESH COMPLETE ON DEMAND
AS SELECT CodeAppel
FROM Appel
 WHERE EXTRACT(YEAR FROM DateAppel) = 2021
AND EXTRACT(MONTH FROM DateAppel) = 6;

--2.
CREATE MATERIALIZED VIEW 
LOG ON Appel ;

CREATE MATERIALIZED VIEW VM2
BUILD IMMEDIATE 
REFRESH FAST ON DEMAND
AS SELECT *
FROM Appel WHERE EXTRACT(YEAR FROM DateAppel) = 2021
AND EXTRACT(MONTH FROM DateAppel) = 6;

--3. 
--INSERTION:
INSERT INTO APPEL VALUES(3500221, 20, to_date('2021-03-17','yyyy-mm-dd'), 15, 300, 2);
EXECUTE DBMS_MVIEW.REFRESH('VM1');
EXECUTE DBMS_MVIEW.REFRESH('VM2');
------------------------------------------------------------------
--Modification:
UPDATE APPEL SET DureeAppel = 30 WHERE CodeAppel = 3500221;
EXECUTE DBMS_MVIEW.REFRESH('VM1');
EXECUTE DBMS_MVIEW.REFRESH('VM2');
------------------------------------------------------------------
--Suppression:
DELETE FROM APPEL WHERE CodeAppel = 3500221;
EXECUTE DBMS_MVIEW.REFRESH('VM1');
EXECUTE DBMS_MVIEW.REFRESH('VM2');

--4.
SET TIMING ON
SET AUTOTRACE ON EXPLAIN

--5.
alter system flush shared_pool;
alter system flush buffer_cache;
---------------------------------
SELECT c.NumClient AS CodeCl, c.NomClient AS NomCl
FROM Client c, Ligne l, Appel a, TypeAppel t
WHERE t.TypeAppel = 'Internationale'
AND t.CodeTypeAppel = a.CodeTypeAppel
AND a.NumeroLigne = l.NumeroLigne
AND l.NumClient = c.NumClient;

--7.
CREATE MATERIALIZED VIEW VM3
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE AS
SELECT c.NumClient AS CodeCl, c.NomClient AS NomCl, 
t.CodeTypeAppel AS CodeTypeAppel, t.TypeAppel AS TypeAppel
FROM Client c, Ligne l, Appel a, TypeAppel t
WHERE t.CodeTypeAppel = a.CodeTypeAppel
AND a.NumeroLigne = l.NumeroLigne
AND l.NumClient = c.NumClient;

--8.
alter system flush shared_pool;
alter system flush buffer_cache;
---------------------------------
SELECT c.NumClient AS CodeCl, c.NomClient AS NomCl
FROM Client c, Ligne l, Appel a, TypeAppel t
WHERE t.TypeAppel = 'Internationale'
AND t.CodeTypeAppel = a.CodeTypeAppel
AND a.NumeroLigne = l.NumeroLigne
AND l.NumClient = c.NumClient;

--9.

SELECT COUNT(*) AS NBApp, EXTRACT(MONTH FROM DateAppel) AS Mois, EXTRACT(YEAR FROM DateAppel) AS Annee
FROM Appel
GROUP BY EXTRACT(MONTH FROM DateAppel), EXTRACT(YEAR FROM DateAppel);
--ORDER BY EXTRACT(MONTH FROM DateAppel), EXTRACT(YEAR FROM DateAppel)

--11.
CREATE MATERIALIZED VIEW VM4
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE AS
SELECT COUNT(*) AS NBApp, EXTRACT(MONTH FROM DateAppel) AS Mois, EXTRACT(YEAR FROM DateAppel) AS Annee
FROM Appel
GROUP BY EXTRACT(MONTH FROM DateAppel), EXTRACT(YEAR FROM DateAppel);

--12.
alter system flush shared_pool;
alter system flush buffer_cache;
--------------------------------
SELECT COUNT(*) AS NBApp, EXTRACT(MONTH FROM DateAppel) AS Mois, EXTRACT(YEAR FROM DateAppel) AS Annee
FROM Appel
GROUP BY EXTRACT(MONTH FROM DateAppel), EXTRACT(YEAR FROM DateAppel);

--13.
DECLARE
    CodeApp number;
    Duree number;
    DateApp date;
    codeTA number;
    NumL number;
    CodeOD number;
BEGIN
    FOR CodeApp IN 3500221 .. 4000000 LOOP
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
--------------------------------

EXECUTE DBMS_MVIEW.REFRESH('VM4');
--------------------------------
alter system flush shared_pool;
alter system flush buffer_cache;

SELECT COUNT(*) AS NBApp, EXTRACT(MONTH FROM DateAppel) AS Mois, EXTRACT(YEAR FROM DateAppel) AS Annee
FROM Appel
GROUP BY EXTRACT(MONTH FROM DateAppel), EXTRACT(YEAR FROM DateAppel);
--------------------------------

DROP MATERIALIZED VIEW VM4;
-------------------------------

alter system flush shared_pool;
alter system flush buffer_cache;
------------------------------

SELECT COUNT(*) AS NBApp, EXTRACT(MONTH FROM DateAppel) AS Mois, EXTRACT(YEAR FROM DateAppel) AS Annee
FROM Appel
GROUP BY EXTRACT(MONTH FROM DateAppel), EXTRACT(YEAR FROM DateAppel);
--------------------------------
--------------------------------

CREATE MATERIALIZED VIEW VM4
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE AS
SELECT COUNT(*) AS NBApp, EXTRACT(MONTH FROM DateAppel) AS Mois, EXTRACT(YEAR FROM DateAppel) AS Annee
FROM Appel
GROUP BY EXTRACT(MONTH FROM DateAppel), EXTRACT(YEAR FROM DateAppel);
---------------------------------
DECLARE
    CodeApp number;
    Duree number;
    DateApp date;
    codeTA number;
    NumL number;
    CodeOD number;
BEGIN
    FOR CodeApp IN 4000001 .. 4500000 LOOP
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

--------------------------------
EXECUTE DBMS_MVIEW.REFRESH('VM4');
--------------------------------
alter system flush shared_pool;
alter system flush buffer_cache;
--------------------------------
SELECT COUNT(*) AS NBApp, EXTRACT(MONTH FROM DateAppel) AS Mois, EXTRACT(YEAR FROM DateAppel) AS Annee
FROM Appel
GROUP BY EXTRACT(MONTH FROM DateAppel), EXTRACT(YEAR FROM DateAppel);
--------------------------------

DROP MATERIALIZED VIEW VM4;
-------------------------------

alter system flush shared_pool;
alter system flush buffer_cache;
------------------------------

SELECT COUNT(*) AS NBApp, EXTRACT(MONTH FROM DateAppel) AS Mois, EXTRACT(YEAR FROM DateAppel) AS Annee
FROM Appel
GROUP BY EXTRACT(MONTH FROM DateAppel), EXTRACT(YEAR FROM DateAppel);
--------------------------------
--------------------------------
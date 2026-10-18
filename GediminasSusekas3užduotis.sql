
1. TELE2 teikiamos papildomos paslaugos ir jų kainos

SELECT
    pp.papildomosPaslaugosPavadinimas AS [Paslaugos pavadinimas],
    opp.kaina AS [Kaina]
FROM dbo.Operatorius AS o
INNER JOIN dbo.OperatoriausPapildomaPaslauga AS opp
    ON opp.operatoriausID = o.operatoriausID
INNER JOIN dbo.PapildomaPaslauga AS pp
    ON pp.papildomosPaslaugosID = opp.papildomosPaslaugosID
WHERE o.operatoriausPavadinimas = 'TELE2'
ORDER BY pp.papildomosPaslaugosPavadinimas;

2. Visų operatorių siūlomos papildomos paslaugos

SELECT
    o.operatoriausPavadinimas AS [Operatorius],
    pp.papildomosPaslaugosPavadinimas AS [Paslaugos pavadinimas],
    opp.kaina AS [Kaina]
FROM dbo.Operatorius AS o
INNER JOIN dbo.OperatoriausPapildomaPaslauga AS opp
    ON opp.operatoriausID = o.operatoriausID
INNER JOIN dbo.PapildomaPaslauga AS pp
    ON pp.papildomosPaslaugosID = opp.papildomosPaslaugosID
ORDER BY
    o.operatoriausPavadinimas,
    pp.papildomosPaslaugosPavadinimas;
    
3. Kiekvienai zonai priklausančių valstybių skaičius

SELECT
    z.zonosPavadinimas AS [Zona],
    COUNT(s.saliesKodas) AS [Valstybių skaičius]
FROM dbo.Zona AS z
LEFT JOIN dbo.Salis AS s
    ON s.zonosID = z.zonosID
GROUP BY
    z.zonosID,
    z.zonosPavadinimas
ORDER BY z.zonosID;

4. Operatorius, siūlantis brangiausius skambučius į Meksiką

SELECT TOP (1) WITH TIES
    o.operatoriausPavadinimas AS [Operatorius]
FROM dbo.PaslaugosKainaZonoje AS pkz
INNER JOIN dbo.Operatorius AS o
    ON o.operatoriausID = pkz.operatoriausID
WHERE pkz.paslaugosID = 4
  AND EXISTS (
      SELECT 1
      FROM dbo.Salis AS s
      WHERE s.zonosID = pkz.zonosID
        AND s.saliesPavadinimas = 'Meksika'
  )
ORDER BY pkz.kaina DESC;

5. Į mokėjimo planą neįtrauktas interneto planas, kurio 1 MB kaina mažiausia

SELECT TOP (1) WITH TIES
    o.operatoriausPavadinimas AS [Operatorius],
    ip.intPlanoPavadinimas AS [Interneto planas],
    ip.kaina / NULLIF(ip.kiekisMB, 0) AS [1 MB kaina]
FROM dbo.InternetoPlanas AS ip
INNER JOIN dbo.Operatorius AS o
    ON o.operatoriausID = ip.operatoriausID
WHERE ip.kiekisMB > 0
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Planas AS p
      WHERE p.internetoPlanoID = ip.internetoPlanoID
  )
ORDER BY ip.kaina / NULLIF(ip.kiekisMB, 0);

6. Abonentų pasiskirstymas tarp operatorių procentais
    
SELECT
    o.operatoriausPavadinimas AS [Operatorius],
    CAST(
        100.0 * COUNT(a.abonentoID)
        / NULLIF(
            (SELECT COUNT(*) FROM dbo.Abonentas),
            0
        )
        AS decimal(6, 2)
    ) AS [Abonentų dalis, %]
FROM dbo.Operatorius AS o
LEFT JOIN dbo.Planas AS p
    ON p.operatoriausID = o.operatoriausID
LEFT JOIN dbo.Abonentas AS a
    ON a.planoID = p.planoID
GROUP BY
    o.operatoriausID,
    o.operatoriausPavadinimas
ORDER BY [Abonentų dalis, %] DESC;

7. Trys populiariausi planai, įtraukiant vienodą abonentų skaičių turinčius planus*

SELECT
    t.planoPavadinimas AS [Plano pavadinimas],
    t.abonentuKiekis AS [Abonentų kiekis]
FROM (
    SELECT
        p.planoID,
        p.planoPavadinimas,
        COUNT(*) AS abonentuKiekis,
        DENSE_RANK() OVER (
            ORDER BY COUNT(*) DESC
        ) AS vieta
    FROM dbo.Planas AS p
    INNER JOIN dbo.Abonentas AS a
        ON a.planoID = p.planoID
    GROUP BY
        p.planoID,
        p.planoPavadinimas
) AS t
WHERE t.vieta <= 3
ORDER BY
    t.abonentuKiekis DESC,
    t.planoPavadinimas;

8. Dešimties atsitiktinių abonentų informacija

SELECT TOP (10)
    asm.vardas + ' ' + asm.pavarde AS [Pilnas vardas],
    m.miestoPavadinimas AS [Miestas],
    a.numeris AS [Numeris],
    a.sutartiesPradzia AS [Sutarties pradžia],
    a.sutartiesPabaiga AS [Sutarties pabaiga],
    o.operatoriausPavadinimas AS [Operatorius],
    p.planoPavadinimas AS [Planas],
    CASE WHEN EXISTS (
        SELECT 1
        FROM dbo.UzsakytasInternetoPlanas AS ip
        WHERE ip.abonentoID = a.abonentoID
    ) THEN N'Taip' ELSE N'Ne' END AS [Papildomas interneto planas],
    CASE WHEN EXISTS (
        SELECT 1
        FROM dbo.UzsakytaPapildomaPaslauga AS pp
        WHERE pp.abonentoID = a.abonentoID
    ) THEN N'Taip' ELSE N'Ne' END AS [Papildomos paslaugos]
FROM dbo.Abonentas AS a
JOIN dbo.Asmuo AS asm ON asm.asmensID = a.asmensID
JOIN dbo.Miestas AS m ON m.miestoID = asm.miestoID
JOIN dbo.Planas AS p ON p.planoID = a.planoID
JOIN dbo.Operatorius AS o ON o.operatoriausID = p.operatoriausID
ORDER BY NEWID();

9. TOP 5 abonentai pagal skambučių Lietuvos teritorijoje kiekį 2025 m. spalį
      surikiuotas kainos mažėjimo tvarka 

SELECT TOP (5)
    a.abonentoID AS [Abonento ID],
    asm.vardas + ' ' + asm.pavarde AS [Pilnas vardas],
    a.numeris AS [Numeris],
    COUNT(*) AS [Skambučių kiekis]
FROM dbo.RysysP2P AS r
INNER JOIN dbo.Abonentas AS a
    ON a.abonentoID = r.abonentoID
INNER JOIN dbo.Asmuo AS asm
    ON asm.asmensID = a.asmensID
WHERE r.paslaugosID = 1
  AND r.rysioInicializavimoVieta IS NULL
  AND r.adresatoSalis IS NULL
  AND r.rysioPradzia >= '20251001'
  AND r.rysioPradzia < '20251101'
GROUP BY
    a.abonentoID,
    asm.vardas,
    asm.pavarde,
    a.numeris
ORDER BY
    COUNT(*) DESC,
    a.abonentoID;

10. Populiariausia užsienio šalis pagal skambučių į ją kiekį

SELECT TOP (1) WITH TIES
    s.saliesPavadinimas AS [Šalis],
    COUNT(*) AS [Skambučių kiekis]
FROM dbo.RysysP2P AS r
INNER JOIN dbo.Salis AS s
    ON s.saliesKodas = r.adresatoSalis
WHERE r.paslaugosID = 4
GROUP BY s.saliesPavadinimas
ORDER BY COUNT(*) DESC;

1. Lentelėje Miestas esančių įrašų kiekis

	SELECT COUNT(*) AS MiestuKiekis
	FROM dbo.Miestas;

2. Planai, į kurių komplektaciją įtrauktas tam tikras interneto planas.
2.1 Susirandam visus planų ID

	SELECT 
		internetoPlanoID,
		intPlanoPavadinimas
	FROM InternetoPlanas;
2.1 Pasirenkam interneto plana su ID
	SELECT
    		p.planoPavadinimas,
    		p.kaina,
    		ip.intPlanoPavadinimas,
    		ip.kiekisMB,
    		ip.kaina AS internetoPlanoKaina,
    		o.operatoriausPavadinimas
	FROM Planas p, InternetoPlanas ip, Operatorius o
	WHERE p.internetoPlanoID = ip.internetoPlanoID
  		AND ip.operatoriausID = o.operatoriausID
  		AND ip.internetoPlanoID = 2;
2.2 Tokiu planu nera pasitikrinam ar uzklausa tesingai veikia ivesdami visus planus 
	SELECT
    		p.planoPavadinimas,
    		p.kaina,
    		ip.intPlanoPavadinimas,
    		ip.kiekisMB,
    		ip.kaina AS internetoPlanoKaina,
    		o.operatoriausPavadinimas
	FROM Planas p, InternetoPlanas ip, Operatorius o
	WHERE p.internetoPlanoID = ip.internetoPlanoID
  		AND ip.operatoriausID = o.operatoriausID
2.3 Matome kad 11,12,13,14,15,16 interneto planas yra itrauktas i mobiliu paslaugu planus

3. Operatoriai ir jų planai, kuriuose yra bent 100 nemokamų
minučių pokalbiams Lietuvos tinkle.

	SELECT DISTINCT
   		o.operatoriausPavadinimas,
    		p.planoPavadinimas,
    		p.kaina,
		p.planoID
	FROM Operatorius o, Planas p, PlanoRinkinys pr, Paslauga ps, Lengvata l
	WHERE o.operatoriausID = p.operatoriausID
  		AND p.planoID = pr.planoID
  		AND pr.paslaugosID = ps.paslaugosID
  		AND pr.rinkinioID = l.rinkinioID
  		AND l.kiekis >= 100
  		AND l.kaina = 0
  		AND ps.paslaugosPavadinimas = 'Skambučiai į Lietuvos tinklus, Eur/min.';

		arba

		AND ps.paslaugosPavadinimas LIKE '%Skamb%Lietuv%'


4. Naudotojų kiekis kiekviename mieste

	SELECT
    		m.miestoPavadinimas,
    		COUNT(a.asmensID) AS NaudotojuKiekis
	FROM Miestas m
	LEFT JOIN Asmuo a
    		ON m.miestoID = a.miestoID
	GROUP BY m.miestoPavadinimas;

5. Miestai, kuriuose nėra nė vieno naudotojo

	SELECT
    		m.miestoPavadinimas,
    		COUNT(a.asmensID) AS NaudotojuKiekis
	FROM Miestas m
	LEFT JOIN Asmuo a
    		ON m.miestoID = a.miestoID
	GROUP BY m.miestoPavadinimas
	HAVING COUNT(a.asmensID) = 0;

6. Vidutinis naudotojų kiekis mieste:
      6.1 neįtraukiant miestų be naudotojų;

	SELECT
    		1.0 * COUNT(a.asmensID) / COUNT(DISTINCT m.miestoID)
        		AS VidutinisNaudotojuKiekis
	FROM Miestas m, Asmuo a
	WHERE m.miestoID = a.miestoID;

      6.2 įtraukiant miestus be naudotojų.

	SELECT
    		1.0 * COUNT(a.asmensID) / COUNT(DISTINCT m.miestoID)
        		AS VidutinisNaudotojuKiekis
	FROM Miestas m
	LEFT JOIN Asmuo a
    		ON m.miestoID = a.miestoID;


7. Operatorius(-iai), siūlantis(-ys) didžiausią planų kiekį

	SELECT TOP 1 WITH TIES
    		o.operatoriausPavadinimas,
    		COUNT(p.planoID) AS PlanuKiekis
	FROM Operatorius o, Planas p
	WHERE o.operatoriausID = p.operatoriausID
	GROUP BY o.operatoriausID, o.operatoriausPavadinimas
	ORDER BY COUNT(p.planoID) DESC;

8. Asmenys, užsisakę bet kokį planą 2013-01-03 - 2013-01-10 laikotarpiu

	SELECT
    		a.vardas,
    		a.pavarde,
    		p.planoPavadinimas,
    		ab.sutartiesPradzia
	FROM Asmuo a, Abonentas ab, Planas p
	WHERE a.asmensID = ab.asmensID
  		AND ab.planoID = p.planoID
  		AND ab.sutartiesPradzia >= '20130103'
  		AND ab.sutartiesPradzia < '20130111'
	ORDER BY ab.sutartiesPradzia;

8.1 Tokiu asmenu nerasta tikrinam kokios datos yra

	SELECT
    		MIN(sutartiesPradzia) AS PirmaData,
    		MAX(sutartiesPradzia) AS PaskutineData
	FROM Abonentas;

	arba

	SELECT
    		a.vardas,
    		a.pavarde,
    		p.planoPavadinimas,
    		ab.sutartiesPradzia
	FROM Asmuo a, Abonentas ab, Planas p
	WHERE a.asmensID = ab.asmensID
  		AND ab.planoID = p.planoID
	ORDER BY ab.sutartiesPradzia;

8.2 pakoreguojam pirma uzklausa su realiom datom kad patikrinti veikima

	SELECT
    		a.vardas,
    		a.pavarde,
    		p.planoPavadinimas,
    		ab.sutartiesPradzia
	FROM Asmuo a, Abonentas ab, Planas p
	WHERE a.asmensID = ab.asmensID
  		AND ab.planoID = p.planoID
  		AND ab.sutartiesPradzia >= '20250103'
  		AND ab.sutartiesPradzia < '20250111'
	ORDER BY ab.sutartiesPradzia;

9. Kiekvieno operatoriaus siūlomų planų kainų vidurkis,
      surikiuotas kainos mažėjimo tvarka

	SELECT
    		o.operatoriausPavadinimas,
    		AVG(p.kaina) AS VidutineKaina
	FROM Operatorius o, Planas p
	WHERE o.operatoriausID = p.operatoriausID
	GROUP BY o.operatoriausPavadinimas
	ORDER BY VidutineKaina DESC;

10. Kiek papildomų paslaugų teikia kiekvienas operatorius

	SELECT
    		o.operatoriausPavadinimas,
    		COUNT(opp.papildomosPaslaugosID) AS PaslauguKiekis
	FROM Operatorius o, OperatoriausPapildomaPaslauga opp
	WHERE o.operatoriausID = opp.operatoriausID
	GROUP BY o.operatoriausPavadinimas;


1. Lentelėje Abonentas pridėkite papildomą atributą "nuolaida" Decimal(3,2) tipo NOT NULL Default 0,00 reikšmė.

ALTER TABLE dbo.Abonentas
ADD nuolaida DECIMAL(3,2) NOT NULL
    CONSTRAINT DF_Abonentas_nuolaida DEFAULT (0.00);
    
## Patikrinimas ##
    
SELECT
    COLUMN_NAME AS stulpelis,
    DATA_TYPE AS duomenuTipas,
    NUMERIC_PRECISION AS visiSkaitmenys,
    NUMERIC_SCALE AS skaitmenysPoKablelio,
    IS_NULLABLE AS leidziaNULL,
    COLUMN_DEFAULT AS numatytojiReiksme
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'Abonentas'
  AND COLUMN_NAME = 'nuolaida';
  
  ##
  
SELECT abonentoID, nuolaida
FROM dbo.Abonentas;

2. Lentelėje Asmuo pridėkite atributą "elPastas" varchar(50) tipo NULL reikšmė.

ALTER TABLE dbo.Asmuo
ADD elPastas VARCHAR(50) NULL;

## Patikrinimas ##

SELECT
    COLUMN_NAME AS stulpelis,
    DATA_TYPE AS duomenuTipas,
    CHARACTER_MAXIMUM_LENGTH AS maksimalusIlgis,
    IS_NULLABLE AS leidziaNULL
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'Asmuo'
  AND COLUMN_NAME = 'elPastas';
    
3. Sukurkite lentelę Domenas su atributais "domenoID" int tipo, "pavadinimas" varchar(15) tipo. Atributas "domenoID" turi turėti IDENTITY parametrą. 

CREATE TABLE dbo.Domenas
(
    domenoID INT IDENTITY(1,1) PRIMARY KEY,
    pavadinimas VARCHAR(15)
);

## Patikrinimas ##

SELECT
    c.name AS stulpelis,
    t.name AS duomenuTipas,
    c.max_length AS ilgisBaitais,
    c.is_identity AS yraIDENTITY
FROM sys.columns AS c
JOIN sys.types AS t
    ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.Domenas');

4. Į lentelę Domenas įveskite įrašus: "gmail.com", "yahoo.com", "hotmail.com", "eif.viko.lt".

INSERT INTO dbo.Domenas (pavadinimas)
VALUES
    ('gmail.com'),
    ('yahoo.com'),
    ('hotmail.com'),
    ('eif.viko.lt');
    
## Patikrinimas ##

SELECT domenoID, pavadinimas
FROM dbo.Domenas
ORDER BY domenoID;

5. Atnaujinkite lentelės Asmuo įrašus įvedant el pašto adresą. Kiekvienam asmeniui el. pašto adresas formuojamas taip: vardas.pavarde@domenas. domenas atsitiktinai parenkamas iš lentelės Domenas. 

UPDATE a
SET elPastas = LOWER(
    CONCAT(
        a.vardas,
        '.',
        a.pavarde,
        '@',
        (
            SELECT TOP (1) d.pavadinimas
            FROM dbo.Domenas AS d
            ORDER BY CHECKSUM(NEWID(), a.asmensID, d.domenoID)
        )
    )
)
FROM dbo.Asmuo AS a;

## Patikrinimas ##

SELECT asmensID, vardas, pavarde, elPastas
FROM dbo.Asmuo;

6. Sukurkite lentelę Mob_telefonas su atributais "mobTelID" int tipo, "gamintojas" varchar(15) tipo, "modelis" varchar(30) tipo, "kaina" float tipo, "kaina/men" float tipo. 
    
CREATE TABLE dbo.Mob_telefonas
(
    mobTelID INT IDENTITY(1,1) PRIMARY KEY,
    gamintojas VARCHAR(15),
    modelis VARCHAR(30),
    kaina FLOAT,
    [kaina/men] FLOAT
);

## Patikrinimas ##

SELECT
    COLUMN_NAME AS stulpelis,
    DATA_TYPE AS duomenuTipas,
    CHARACTER_MAXIMUM_LENGTH AS maksimalusTekstoIlgis
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'Mob_telefonas'
ORDER BY ORDINAL_POSITION;

7. Lentelėje Abonentas pridėkite papildomą atributą "mobTelID" int tipo. Atminkite, jog ne visi abonentai kartu su planu įsigyja mobilųjį telefoną. 

ALTER TABLE dbo.Abonentas
ADD mobTelID INT NULL;

## Patikrinimas ##

SELECT
    COLUMN_NAME AS stulpelis,
    DATA_TYPE AS duomenuTipas,
    IS_NULLABLE AS leidziaNULL
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'Abonentas'
  AND COLUMN_NAME = 'mobTelID';

8. Sukurkite išorinio rakto sąryšį tarp lentelės Abonento atributo "mobTelID" ir lentelės Mob_Telefonas atributo "mobTelID". 

ALTER TABLE dbo.Abonentas
ADD CONSTRAINT FK_Abonentas_Mob_telefonas
FOREIGN KEY (mobTelID)
REFERENCES dbo.Mob_telefonas (mobTelID);

## Patikrinimas ##

SELECT
    fk.name AS rysioPavadinimas,
    OBJECT_NAME(fkc.parent_object_id) AS lentele,
    COL_NAME(
        fkc.parent_object_id,
        fkc.parent_column_id
    ) AS stulpelis,
    OBJECT_NAME(fkc.referenced_object_id) AS susietaLentele,
    COL_NAME(
        fkc.referenced_object_id,
        fkc.referenced_column_id
    ) AS susietasStulpelis,
    fk.is_disabled AS isjungtas,
    fk.is_not_trusted AS nepatikrintas
FROM sys.foreign_keys AS fk
JOIN sys.foreign_key_columns AS fkc
    ON fk.object_id = fkc.constraint_object_id
WHERE fk.parent_object_id = OBJECT_ID('dbo.Abonentas')
  AND fk.name = 'FK_Abonentas_Mob_telefonas';
  
9. Lentelę Mob_telefonas užpildykite duomenimis iš .txt failo. Failas yra čia. Naudokite BULK INSERT komandą. 

BULK INSERT dbo.Mob_telefonas
FROM 'D:\Studijoms\Treti metai\Duomenu baziu valdymas\mobilieji-telefonai.txt'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);

## Patikrinimas ##

SELECT *
FROM dbo.Mob_telefonas;


10. Atnaujinkite lentelės Abonentas įrašus įvedant atributo "mobTelID" reikšmes. Mobilųjį telefoną pasirinko tie abonentai, kurių sutarties pabaigos data yra neapibrėžta. Kiekvienam abonentui parenkamas atsitiktinis mobilusis telefonas. 

UPDATE a
SET mobTelID =
(
    SELECT TOP (1) m.mobTelID
    FROM dbo.Mob_telefonas AS m
    ORDER BY CHECKSUM(NEWID(), a.abonentoID, m.mobTelID)
)
FROM dbo.Abonentas AS a
WHERE a.sutartiesPabaiga IS NULL;

## Patikrinimas ##

SELECT
    a.abonentoID,
    a.sutartiesPabaiga,
    a.mobTelID,
    m.gamintojas,
    m.modelis
FROM dbo.Abonentas AS a
LEFT JOIN dbo.Mob_telefonas AS m
    ON a.mobTelID = m.mobTelID
ORDER BY a.abonentoID




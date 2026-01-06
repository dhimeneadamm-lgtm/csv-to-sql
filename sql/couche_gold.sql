USE PachaDataFormationDM
GO

-- D'abord, vérifions la structure des tables
PRINT '=== VÉRIFICATION DE LA STRUCTURE DES TABLES ==='
GO

-- Vérifier les colonnes de DimContact
PRINT 'Colonnes de DimContact:'
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'DimContact'
ORDER BY ORDINAL_POSITION;
GO

-- Vérifier les colonnes de DimSession
PRINT 'Colonnes de DimSession:'
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'DimSession'
ORDER BY ORDINAL_POSITION;
GO

-- Vérifier les colonnes de DimInscription
PRINT 'Colonnes de DimInscription:'
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'DimInscription'
ORDER BY ORDINAL_POSITION;
GO

PRINT '=== COUCHE GOLD - VERSION CORRIGÉE ==='
PRINT 'Transformation vers le schéma en étoile...'
GO

-- =============================================
-- 1. D'ABORD, CRÉER LES TABLES SI ELLES N'EXISTENT PAS
-- =============================================

-- Vérifier et créer DimContact si nécessaire
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'DimContact')
BEGIN
    CREATE TABLE [dbo].[DimContact] (
        [DimContactSk] bigint IDENTITY(1,1) PRIMARY KEY,
        [ContactId] int NOT NULL,
        [Nom] varchar(50) NOT NULL,
        [Prenom] varchar(50) NULL,
        [Email] varchar(150) NULL,
        [Sexe] char(1) NOT NULL DEFAULT ('?'),
        [Ville] varchar(255) NULL,
        [CodeDepartement] char(2) NULL,
        [NomDepartement] varchar(50) NULL,
        [CodePays] char(2) NULL,
        [NomPaysFrancais] varchar(50) NULL,
        [NomPaysAnglais] varchar(50) NULL,
        [SocieteId] int NULL,
        [NomSociete] varchar(60) NULL
    );
    PRINT 'Table DimContact créée.';
END
GO

-- Vérifier et créer DimSession si nécessaire
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'DimSession')
BEGIN
    CREATE TABLE [dbo].[DimSession] (
        [DimSessionSk] bigint IDENTITY(1,1) PRIMARY KEY,
        [SessionId] int NOT NULL,
        [LangueLocal] varchar(50) NOT NULL,
        [LangueFrancais] varchar(50) NOT NULL,
        [DateDebut] date NOT NULL,
        [Categorie] char(2) NOT NULL,
        [Domaine] char(2) NOT NULL,
        [Prix] decimal(8,2) NOT NULL,
        [Note] tinyint NOT NULL DEFAULT (0),
        [Duree] tinyint NOT NULL,
        [FormateurId] int NULL,
        [NomFormateur] varchar(101) NOT NULL DEFAULT ('N/A'),
        [SocieteFormateurId] int NULL,
        [NomSocieteFormateur] varchar(50) NOT NULL DEFAULT ('N/A'),
        [NomVilleSocieteFormateur] varchar(255) NOT NULL DEFAULT ('N/A'),
        [NomSalleFormation] varchar(20) NOT NULL DEFAULT ('N/A'),
        [NomLieuFormation] varchar(30) NOT NULL DEFAULT ('N/A'),
        [NomVilleFormation] varchar(20) NOT NULL DEFAULT ('N/A')
    );
    PRINT 'Table DimSession créée.';
END
GO

-- Vérifier et créer DimInscription si nécessaire
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'DimInscription')
BEGIN
    CREATE TABLE [dbo].[DimInscription] (
        [DimInscriptionSk] bigint IDENTITY(1,1) PRIMARY KEY,
        [InscriptionId] int NOT NULL,
        [ReferenceCommande] varchar(100) NULL
    );
    PRINT 'Table DimInscription créée.';
END
GO

-- Vérifier et créer FactInscription si nécessaire
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'FactInscription')
BEGIN
    CREATE TABLE [dbo].[FactInscription] (
        [FactInscriptionSk] bigint IDENTITY(1,1) PRIMARY KEY,
        [DimInscriptionSk] bigint NOT NULL,
        [DimSessionSk] bigint NOT NULL,
        [DateSession] date NOT NULL,
        [DimContactSk] bigint NOT NULL,
        [MontantHT] decimal(7, 2) NOT NULL DEFAULT (0),
        [DateFacture] date NOT NULL,
        CONSTRAINT FK_FactInscription_DimInscription FOREIGN KEY (DimInscriptionSk) 
            REFERENCES [dbo].[DimInscription] (DimInscriptionSk),
        CONSTRAINT FK_FactInscription_DimSession FOREIGN KEY (DimSessionSk) 
            REFERENCES [dbo].[DimSession] (DimSessionSk),
        CONSTRAINT FK_FactInscription_DimContact FOREIGN KEY (DimContactSk) 
            REFERENCES [dbo].[DimContact] (DimContactSk)
    );
    PRINT 'Table FactInscription créée.';
END
GO

-- =============================================
-- 2. VIDER LES TABLES D'ABORD (si nécessaire)
-- =============================================
PRINT 'Vidage des tables existantes...'
GO

-- Désactiver les contraintes
ALTER TABLE [dbo].[FactInscription] NOCHECK CONSTRAINT ALL;

-- Vider dans le bon ordre
DELETE FROM [dbo].[FactInscription];
DELETE FROM [dbo].[DimInscription];
DELETE FROM [dbo].[DimSession];
DELETE FROM [dbo].[DimContact];

-- Réactiver les contraintes
ALTER TABLE [dbo].[FactInscription] CHECK CONSTRAINT ALL;

PRINT 'Tables vidées.';
GO

-- =============================================
-- 3. PEUPLER LES TABLES SANS LA COLONNE EstActif
-- =============================================

-- Peupler DimContact depuis Silver (SANS EstActif)
PRINT 'Peuplement de DimContact...'
GO

INSERT INTO [dbo].[DimContact] (
    [ContactId],
    [Nom],
    [Prenom],
    [Email],
    [Sexe],
    [Ville],
    [CodeDepartement],
    [NomDepartement],
    [CodePays],
    [NomPaysFrancais],
    [NomPaysAnglais],
    [SocieteId],
    [NomSociete]
)
SELECT DISTINCT
    sc.ContactId,
    sc.Nom,
    sc.Prenom,
    sc.Email,
    sc.Sexe,
    sc.Ville,
    sc.CodeDepartement,
    sc.NomDepartement,
    sc.CodePays,
    sc.NomPaysFrancais,
    sc.NomPaysAnglais,
    sc.SocieteId,
    sc.NomSociete
FROM [vSilverContact] sc
WHERE NOT EXISTS (
    SELECT 1 FROM [dbo].[DimContact] dc 
    WHERE dc.ContactId = sc.ContactId  -- RETIRÉ: AND dc.EstActif = 1
)
GO

-- Afficher les résultats
DECLARE @RowCountContact INT, @TotalCountContact INT;
SELECT @RowCountContact = @@ROWCOUNT;
SELECT @TotalCountContact = COUNT(*) FROM [dbo].[DimContact];

PRINT 'DimContact: ' + CAST(@RowCountContact AS VARCHAR(10)) + ' lignes insérées';
PRINT 'Total DimContact: ' + CAST(@TotalCountContact AS VARCHAR(10));
GO

-- Peupler DimSession depuis Silver (SANS EstActif)
PRINT 'Peuplement de DimSession...'
GO

INSERT INTO [dbo].[DimSession] (
    [SessionId],
    [LangueLocal],
    [LangueFrancais],
    [DateDebut],
    [Categorie],
    [Domaine],
    [Prix],
    [Note],
    [Duree],
    [FormateurId],
    [NomFormateur],
    [SocieteFormateurId],
    [NomSocieteFormateur],
    [NomVilleSocieteFormateur],
    [NomSalleFormation],
    [NomLieuFormation],
    [NomVilleFormation]
)
SELECT DISTINCT
    ss.SessionId,
    ss.LangueLocal,
    ss.LangueFrancais,
    ss.DateDebut,
    ss.Categorie,
    ss.Domaine,
    ss.Prix,
    ss.Note,
    ss.Duree,
    ss.FormateurId,
    ss.NomFormateur,
    ss.SocieteFormateurId,
    ss.NomSocieteFormateur,
    ss.NomVilleSocieteFormateur,
    ss.NomSalleFormation,
    ss.NomLieuFormation,
    ss.NomVilleFormation
FROM [vSilverSession] ss
WHERE NOT EXISTS (
    SELECT 1 FROM [dbo].[DimSession] ds 
    WHERE ds.SessionId = ss.SessionId  -- RETIRÉ: AND ds.EstActif = 1
)
GO

DECLARE @RowCountSession INT, @TotalCountSession INT;
SELECT @RowCountSession = @@ROWCOUNT;
SELECT @TotalCountSession = COUNT(*) FROM [dbo].[DimSession];

PRINT 'DimSession: ' + CAST(@RowCountSession AS VARCHAR(10)) + ' lignes insérées';
PRINT 'Total DimSession: ' + CAST(@TotalCountSession AS VARCHAR(10));
GO

-- Peupler DimInscription depuis Silver (SANS EstActif)
PRINT 'Peuplement de DimInscription...'
GO

INSERT INTO [dbo].[DimInscription] (
    [InscriptionId],
    [ReferenceCommande]
)
SELECT DISTINCT
    si.InscriptionId,
    si.ReferenceCommande
FROM [vSilverInscription] si
WHERE NOT EXISTS (
    SELECT 1 FROM [dbo].[DimInscription] di 
    WHERE di.InscriptionId = si.InscriptionId  -- RETIRÉ: AND di.EstActif = 1
)
GO

DECLARE @RowCountInscription INT, @TotalCountInscription INT;
SELECT @RowCountInscription = @@ROWCOUNT;
SELECT @TotalCountInscription = COUNT(*) FROM [dbo].[DimInscription];

PRINT 'DimInscription: ' + CAST(@RowCountInscription AS VARCHAR(10)) + ' lignes insérées';
PRINT 'Total DimInscription: ' + CAST(@TotalCountInscription AS VARCHAR(10));
GO

-- =============================================
-- 4. PEUPLER FactInscription (CORRIGÉ)
-- =============================================
PRINT 'Peuplement de FactInscription...'
GO

-- Vérifier d'abord si la vue vSilverInscription existe
IF OBJECT_ID('vSilverInscription', 'V') IS NOT NULL
BEGIN
    -- Vérifier les colonnes de la vue
    PRINT 'Colonnes disponibles dans vSilverInscription:';
    SELECT COLUMN_NAME, DATA_TYPE 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'vSilverInscription'
    ORDER BY ORDINAL_POSITION;
    
    -- Insertion corrigée (nombre de colonnes correspondant)
    INSERT INTO [dbo].[FactInscription] (
        [DimInscriptionSk],
        [DimSessionSk],
        [DateSession],
        [DimContactSk],
        [MontantHT],
        [DateFacture]
    )
    SELECT 
        di.DimInscriptionSk,
        ds.DimSessionSk,
        si.DateSession,
        dc.DimContactSk,
        si.MontantHT,
        si.DateFacture
        -- RETIRÉ: si.MontantTTC,
        -- RETIRÉ: si.TauxTVA,
        -- RETIRÉ: si.Remise,
        -- RETIRÉ: si.Present,
        -- RETIRÉ: si.DateCreation
    FROM [vSilverInscription] si
    INNER JOIN [dbo].[DimInscription] di ON si.InscriptionId = di.InscriptionId
    INNER JOIN [dbo].[DimSession] ds ON si.SessionId = ds.SessionId
    INNER JOIN [dbo].[DimContact] dc ON si.ContactId = dc.ContactId
    WHERE NOT EXISTS (
        SELECT 1 FROM [dbo].[FactInscription] fi
        WHERE fi.DimInscriptionSk = di.DimInscriptionSk
          AND fi.DimSessionSk = ds.DimSessionSk
          AND fi.DimContactSk = dc.DimContactSk
    );
END
ELSE
BEGIN
    PRINT 'ATTENTION: La vue vSilverInscription n''existe pas!';
    PRINT 'Création d''une vue temporaire pour test...';
    
    -- Créer une vue temporaire si elle n'existe pas
    IF OBJECT_ID('tempdb..#TempInscription', 'U') IS NOT NULL
        DROP TABLE #TempInscription;
    
    CREATE TABLE #TempInscription (
        InscriptionId INT,
        SessionId INT,
        ContactId INT,
        DateSession DATE,
        MontantHT DECIMAL(10,2),
        DateFacture DATE,
        ReferenceCommande VARCHAR(100)
    );
    
    -- Insérer des données de test
    INSERT INTO #TempInscription VALUES
    (1, 1, 1, '2024-01-15', 1000.00, '2024-01-20', 'CMD-001'),
    (2, 1, 2, '2024-01-15', 1200.00, '2024-01-21', 'CMD-002');
    
    -- Utiliser la table temporaire
    INSERT INTO [dbo].[FactInscription] (
        [DimInscriptionSk],
        [DimSessionSk],
        [DateSession],
        [DimContactSk],
        [MontantHT],
        [DateFacture]
    )
    SELECT 
        di.DimInscriptionSk,
        ds.DimSessionSk,
        ti.DateSession,
        dc.DimContactSk,
        ti.MontantHT,
        ti.DateFacture
    FROM #TempInscription ti
    INNER JOIN [dbo].[DimInscription] di ON ti.InscriptionId = di.InscriptionId
    INNER JOIN [dbo].[DimSession] ds ON ti.SessionId = ds.SessionId
    INNER JOIN [dbo].[DimContact] dc ON ti.ContactId = dc.ContactId;
END
GO

DECLARE @RowCountFact INT, @TotalCountFact INT;
SELECT @RowCountFact = @@ROWCOUNT;
SELECT @TotalCountFact = COUNT(*) FROM [dbo].[FactInscription];

PRINT 'FactInscription: ' + CAST(@RowCountFact AS VARCHAR(10)) + ' lignes insérées';
PRINT 'Total FactInscription: ' + CAST(@TotalCountFact AS VARCHAR(10));
GO

-- =============================================
-- 5. RÉSUMÉ DE LA COUCHE GOLD (CORRIGÉ)
-- =============================================
PRINT ''
PRINT '=== RÉSUMÉ DE LA COUCHE GOLD ==='
GO

SELECT 
    'DimContact' AS TableName,
    COUNT(*) AS [RowCount]
FROM [dbo].[DimContact]
-- RETIRÉ: WHERE EstActif = 1
UNION ALL
SELECT 
    'DimSession' AS TableName,
    COUNT(*) AS [RowCount]
FROM [dbo].[DimSession]
-- RETIRÉ: WHERE EstActif = 1
UNION ALL
SELECT 
    'DimInscription' AS TableName,
    COUNT(*) AS [RowCount]
FROM [dbo].[DimInscription]
-- RETIRÉ: WHERE EstActif = 1
UNION ALL
SELECT 
    'FactInscription' AS TableName,
    COUNT(*) AS [RowCount]
FROM [dbo].[FactInscription]
ORDER BY TableName;
GO

-- =============================================
-- 6. EXEMPLE DE REQUÊTE ANALYTIQUE (CORRIGÉ)
-- =============================================
PRINT ''
PRINT '=== EXEMPLE DE REQUÊTE ANALYTIQUE ==='
PRINT 'Nombre d''inscriptions par contact:'
GO

SELECT TOP 10
    dc.Nom + ' ' + ISNULL(dc.Prenom, '') AS Contact,
    dc.NomSociete,
    COUNT(*) AS NbInscriptions,
    SUM(fi.MontantHT) AS TotalMontantHT
FROM [dbo].[FactInscription] fi
INNER JOIN [dbo].[DimContact] dc ON fi.DimContactSk = dc.DimContactSk
-- RETIRÉ: WHERE dc.EstActif = 1
GROUP BY dc.Nom, dc.Prenom, dc.NomSociete
ORDER BY NbInscriptions DESC;
GO

PRINT 'Couche Gold prête. Le schéma en étoile est opérationnel pour l''analyse décisionnelle.'
GO

-- =============================================
-- 7. AFFICHER LA STRUCTURE DES TABLES
-- =============================================
PRINT ''
PRINT '=== STRUCTURE DES TABLES ===';
PRINT '';

-- Utiliser une approche dynamique pour afficher les colonnes
DECLARE @TableName NVARCHAR(100);
DECLARE @ColumnList NVARCHAR(MAX);

-- DimContact
SET @TableName = 'DimContact';
SET @ColumnList = '';

SELECT @ColumnList = @ColumnList + '  ' + COLUMN_NAME + CHAR(10)
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = @TableName
ORDER BY ORDINAL_POSITION;

PRINT '# ' + @TableName;
PRINT '- ' + REPLACE(@ColumnList, CHAR(10), CHAR(10) + '  ');

-- DimInscription
SET @TableName = 'DimInscription';
SET @ColumnList = '';

SELECT @ColumnList = @ColumnList + '  ' + COLUMN_NAME + CHAR(10)
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = @TableName
ORDER BY ORDINAL_POSITION;

PRINT '# ' + @TableName;
PRINT '- ' + REPLACE(@ColumnList, CHAR(10), CHAR(10) + '  ');

-- DimSession
SET @TableName = 'DimSession';
SET @ColumnList = '';

SELECT @ColumnList = @ColumnList + '  ' + COLUMN_NAME + CHAR(10)
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = @TableName
ORDER BY ORDINAL_POSITION;

PRINT '# ' + @TableName;
PRINT '- ' + REPLACE(@ColumnList, CHAR(10), CHAR(10) + '  ');

-- FactInscription
SET @TableName = 'FactInscription';
SET @ColumnList = '';

SELECT @ColumnList = @ColumnList + '  ' + COLUMN_NAME + CHAR(10)
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = @TableName
ORDER BY ORDINAL_POSITION;

PRINT '# ' + @TableName;
PRINT '- ' + REPLACE(@ColumnList, CHAR(10), CHAR(10) + '  ');

GO

-- ============================================
-- SCRIPT COMPLET DE CRÉATION ET CHARGEMENT
-- ============================================

USE [master]
GO

-- 1. Créer la base de données
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'PachaDataFormationDM')
BEGIN
    CREATE DATABASE [PachaDataFormationDM];
    PRINT 'Base de données PachaDataFormationDM créée.';
END
ELSE
BEGIN
    PRINT 'Base de données PachaDataFormationDM existe déjà.';
END
GO

USE [PachaDataFormationDM];
GO

-- 2. Supprimer les tables si elles existent
IF OBJECT_ID('dbo.FactInscription', 'U') IS NOT NULL
    DROP TABLE dbo.FactInscription;
GO

IF OBJECT_ID('dbo.DimInscription', 'U') IS NOT NULL
    DROP TABLE dbo.DimInscription;
GO

IF OBJECT_ID('dbo.DimSession', 'U') IS NOT NULL
    DROP TABLE dbo.DimSession;
GO

IF OBJECT_ID('dbo.DimContact', 'U') IS NOT NULL
    DROP TABLE dbo.DimContact;
GO

-- 3. Créer les tables avec la bonne structure
CREATE TABLE dbo.DimContact (
    DimContactSk bigint IDENTITY(1,1) PRIMARY KEY,
    ContactId int NOT NULL,
    Nom varchar(50) NOT NULL,
    Prenom varchar(50) NULL,
    Email varchar(150) NULL,
    Sexe char(1) NOT NULL DEFAULT ('?'),
    Ville varchar(255) NULL,
    CodeDepartement char(2) NULL,
    NomDepartement varchar(50) NULL,
    CodePays char(2) NULL,
    NomPaysFrancais varchar(50) NULL,
    NomPaysAnglais varchar(50) NULL,
    SocieteId int NULL,
    NomSociete varchar(60) NULL
);
GO

CREATE TABLE dbo.DimSession (
    DimSessionSk bigint IDENTITY(1,1) PRIMARY KEY,
    SessionId int NOT NULL,
    LangueLocal varchar(50) NOT NULL,
    LangueFrancais varchar(50) NOT NULL,
    DateDebut date NOT NULL,
    Categorie char(2) NOT NULL,
    Domaine char(2) NOT NULL,
    Prix decimal(8,2) NOT NULL,
    Note tinyint NOT NULL DEFAULT (0),
    Duree tinyint NOT NULL,
    FormateurId int NULL,
    NomFormateur varchar(101) NULL,  -- Rendue NULLABLE
    SocieteFormateurId int NULL,
    NomSocieteFormateur varchar(50) NULL,
    NomVilleSocieteFormateur varchar(255) NULL,
    NomSalleFormation varchar(20) NULL,
    NomLieuFormation varchar(30) NULL,
    NomVilleFormation varchar(20) NULL
);
GO

CREATE TABLE dbo.DimInscription (
    DimInscriptionSk bigint IDENTITY(1,1) PRIMARY KEY,
    InscriptionId int NOT NULL,
    ReferenceCommande varchar(100) NULL
);
GO

CREATE TABLE dbo.FactInscription (
    FactInscriptionSk bigint IDENTITY(1,1) PRIMARY KEY,
    DimInscriptionSk bigint NOT NULL,
    DimSessionSk bigint NOT NULL,
    DateSession date NOT NULL,
    DimContactSk bigint NOT NULL,
    MontantHT decimal(7, 2) NOT NULL DEFAULT (0),
    DateFacture date NOT NULL,
    CONSTRAINT FK_FactInscription_DimInscription FOREIGN KEY (DimInscriptionSk) 
        REFERENCES dbo.DimInscription (DimInscriptionSk),
    CONSTRAINT FK_FactInscription_DimSession FOREIGN KEY (DimSessionSk) 
        REFERENCES dbo.DimSession (DimSessionSk),
    CONSTRAINT FK_FactInscription_DimContact FOREIGN KEY (DimContactSk) 
        REFERENCES dbo.DimContact (DimContactSk)
);
GO

-- 4. Créer des données de test COMPLÈTES
PRINT '=== CHARGEMENT DES DONNÉES DE TEST ===';

-- 4.1. Charger DimContact
PRINT 'Chargement de DimContact...';
INSERT INTO dbo.DimContact (ContactId, Nom, Prenom, Email, Sexe, Ville, CodeDepartement, NomDepartement, CodePays, NomPaysFrancais, NomPaysAnglais, SocieteId, NomSociete)
VALUES
(1, 'Dupont', 'Jean', 'jean.dupont@email.com', 'M', 'Paris', '75', 'Paris', 'FR', 'France', 'France', 1, 'Entreprise A'),
(2, 'Martin', 'Marie', 'marie.martin@email.com', 'F', 'Lyon', '69', 'Rhône', 'FR', 'France', 'France', 2, 'Entreprise B'),
(3, 'Durand', 'Pierre', 'pierre.durand@email.com', 'M', 'Marseille', '13', 'Bouches-du-Rhône', 'FR', 'France', 'France', 3, 'Entreprise C'),
(4, 'Leroy', 'Sophie', 'sophie.leroy@email.com', 'F', 'Toulouse', '31', 'Haute-Garonne', 'FR', 'France', 'France', 1, 'Entreprise A'),
(5, 'Moreau', 'Thomas', 'thomas.moreau@email.com', 'M', 'Nice', '06', 'Alpes-Maritimes', 'FR', 'France', 'France', 2, 'Entreprise B'),
(6, 'Simon', 'Julie', 'julie.simon@email.com', 'F', 'Nantes', '44', 'Loire-Atlantique', 'FR', 'France', 'France', 3, 'Entreprise C'),
(7, 'Laurent', 'Paul', 'paul.laurent@email.com', 'M', 'Strasbourg', '67', 'Bas-Rhin', 'FR', 'France', 'France', 4, 'Entreprise D'),
(8, 'Michel', 'Claire', 'claire.michel@email.com', 'F', 'Bordeaux', '33', 'Gironde', 'FR', 'France', 'France', 4, 'Entreprise D'),
(9, 'Bernard', 'Luc', 'luc.bernard@email.com', 'M', 'Lille', '59', 'Nord', 'FR', 'France', 'France', 5, 'Entreprise E'),
(10, 'Petit', 'Anna', 'anna.petit@email.com', 'F', 'Rennes', '35', 'Ille-et-Vilaine', 'FR', 'France', 'France', 5, 'Entreprise E');
PRINT 'DimContact : ' + CAST(@@ROWCOUNT AS VARCHAR) + ' lignes insérées';

-- 4.2. Charger DimSession
PRINT 'Chargement de DimSession...';
INSERT INTO dbo.DimSession (SessionId, LangueLocal, LangueFrancais, DateDebut, Categorie, Domaine, Prix, Note, Duree, FormateurId, NomFormateur, SocieteFormateurId, NomSocieteFormateur, NomVilleSocieteFormateur, NomSalleFormation, NomLieuFormation, NomVilleFormation)
VALUES
(1, 'Python Fundamentals', 'Python Fondamentaux', '2024-01-15', 'DV', 'PR', 1000.00, 4, 3, 101, 'Formateur A', 201, 'Academy Plus', 'Paris', 'Salle 101', 'Centre Formation', 'Paris'),
(2, 'SQL Advanced', 'SQL Avancé', '2024-01-20', 'DV', 'DA', 1200.00, 5, 2, 102, 'Formateur B', 202, 'Data Masters', 'Lyon', 'Salle 102', 'Campus Numérique', 'Lyon'),
(3, 'Data Analysis', 'Analyse de Données', '2024-01-25', 'AN', 'DA', 1500.00, 4, 3, 103, 'Formateur C', 203, 'Analytics Pro', 'Marseille', 'Salle 201', 'Institut Data', 'Marseille'),
(4, 'Power BI Master', 'Power BI Maîtrise', '2024-02-01', 'BI', 'VI', 1800.00, 5, 4, 104, 'Formateur D', 204, 'Visual BI', 'Toulouse', 'Salle 301', 'Centre BI', 'Toulouse'),
(5, 'Machine Learning', 'Apprentissage Automatique', '2024-02-10', 'ML', 'IA', 2000.00, 4, 5, 105, 'Formateur E', 205, 'AI Academy', 'Nice', 'Lab IA', 'Pôle Innovation', 'Nice'),
(6, 'Big Data', 'Données Massives', '2024-02-15', 'BD', 'DA', 2200.00, 4, 4, 106, 'Formateur F', 206, 'Big Data Corp', 'Nantes', 'Salle Data', 'Campus Tech', 'Nantes'),
(7, 'Data Science', 'Science des Données', '2024-02-20', 'DS', 'AN', 2500.00, 5, 5, 107, 'Formateur G', 207, 'Science Data', 'Strasbourg', 'Amphi A', 'Université', 'Strasbourg'),
(8, 'Tableau Expert', 'Tableau Expert', '2024-02-25', 'VI', 'BI', 1600.00, 4, 3, 108, 'Formateur H', 208, 'Viz Experts', 'Bordeaux', 'Salle Viz', 'Centre Visual', 'Bordeaux'),
(9, 'Excel Advanced', 'Excel Avancé', '2024-03-01', 'AN', 'PR', 900.00, 4, 2, 109, 'Formateur I', 209, 'Office Masters', 'Lille', 'Salle Excel', 'Centre Formation', 'Lille'),
(10, 'Cloud Data', 'Données Cloud', '2024-03-05', 'CL', 'DV', 1900.00, 5, 3, 110, 'Formateur J', 210, 'Cloud Academy', 'Rennes', 'Salle Cloud', 'Pôle Cloud', 'Rennes'),
(11, 'Data Engineering', 'Ingénierie des Données', '2024-03-10', 'DE', 'DV', 2100.00, 4, 4, 111, 'Formateur K', 211, 'Engineering Data', 'Paris', 'Lab Engineering', 'Centre Tech', 'Paris'),
(12, 'Business Intelligence', 'Intelligence d''Affaires', '2024-03-15', 'BI', 'MA', 1700.00, 5, 3, 112, 'Formateur L', 212, 'BI Solutions', 'Lyon', 'Salle BI', 'Business Center', 'Lyon');
PRINT 'DimSession : ' + CAST(@@ROWCOUNT AS VARCHAR) + ' lignes insérées';

-- 4.3. Charger DimInscription
PRINT 'Chargement de DimInscription...';
INSERT INTO dbo.DimInscription (InscriptionId, ReferenceCommande)
VALUES
(1001, 'CMD-2024-001'),
(1002, 'CMD-2024-002'),
(1003, 'CMD-2024-003'),
(1004, 'CMD-2024-004'),
(1005, 'CMD-2024-005'),
(1006, 'CMD-2024-006'),
(1007, 'CMD-2024-007'),
(1008, 'CMD-2024-008'),
(1009, 'CMD-2024-009'),
(1010, 'CMD-2024-010'),
(1011, 'CMD-2024-011'),
(1012, 'CMD-2024-012'),
(1013, 'CMD-2024-013'),
(1014, 'CMD-2024-014'),
(1015, 'CMD-2024-015'),
(1016, 'CMD-2024-016'),
(1017, 'CMD-2024-017'),
(1018, 'CMD-2024-018'),
(1019, 'CMD-2024-019'),
(1020, 'CMD-2024-020');
PRINT 'DimInscription : ' + CAST(@@ROWCOUNT AS VARCHAR) + ' lignes insérées';

-- 4.4. Charger FactInscription
PRINT 'Chargement de FactInscription...';

-- Fonction pour générer des données aléatoires mais cohérentes
DECLARE @InscriptionCounter INT = 1;
DECLARE @ContactId INT, @SessionId INT, @MontantHT DECIMAL(7,2), @DateFacture DATE;

WHILE @InscriptionCounter <= 50  -- Créer 50 inscriptions
BEGIN
    -- Sélectionner aléatoirement un contact (1-10)
    SET @ContactId = ((@InscriptionCounter - 1) % 10) + 1;
    
    -- Sélectionner aléatoirement une session (1-12)
    SET @SessionId = ((@InscriptionCounter - 1) % 12) + 1;
    
    -- Calculer un montant basé sur la session
    SET @MontantHT = (SELECT Prix FROM dbo.DimSession WHERE SessionId = @SessionId);
    
    -- Appliquer une remise aléatoire
    SET @MontantHT = @MontantHT * (0.8 + (RAND() * 0.4));  -- Entre 80% et 120% du prix
    
    -- Date de facture = Date début + 5-15 jours
    SET @DateFacture = DATEADD(DAY, 5 + (CAST(RAND() * 10 AS INT)), 
        (SELECT DateDebut FROM dbo.DimSession WHERE SessionId = @SessionId));
    
    -- Insérer l'inscription
    INSERT INTO dbo.FactInscription (DimInscriptionSk, DimSessionSk, DateSession, DimContactSk, MontantHT, DateFacture)
    SELECT 
        di.DimInscriptionSk,
        ds.DimSessionSk,
        ds.DateDebut,
        dc.DimContactSk,
        ROUND(@MontantHT, 2),
        @DateFacture
    FROM dbo.DimInscription di
    CROSS JOIN dbo.DimSession ds
    CROSS JOIN dbo.DimContact dc
    WHERE di.InscriptionId = 1000 + @InscriptionCounter
        AND ds.SessionId = @SessionId
        AND dc.ContactId = @ContactId;
    
    SET @InscriptionCounter = @InscriptionCounter + 1;
END;

PRINT 'FactInscription : 50 lignes insérées';
GO

-- 5. Vérification finale
PRINT '';
PRINT '=== VÉRIFICATION FINALE ===';

SELECT 
    'DimContact' AS TableName,
    COUNT(*) AS RowCount
FROM dbo.DimContact
UNION ALL
SELECT 
    'DimSession',
    COUNT(*)
FROM dbo.DimSession
UNION ALL
SELECT 
    'DimInscription',
    COUNT(*)
FROM dbo.DimInscription
UNION ALL
SELECT 
    'FactInscription',
    COUNT(*)
FROM dbo.FactInscription
ORDER BY TableName;
GO

-- 6. Créer des vues pour faciliter l'accès
PRINT '';
PRINT '=== CRÉATION DES VUES POUR VS CODE ===';

-- Vue pour les contacts
IF OBJECT_ID('dbo.vContacts', 'V') IS NOT NULL
    DROP VIEW dbo.vContacts;
GO

CREATE VIEW dbo.vContacts AS
SELECT 
    DimContactSk,
    ContactId,
    Nom,
    Prenom,
    Email,
    Sexe,
    Ville,
    CodeDepartement,
    NomDepartement,
    CodePays,
    NomPaysFrancais,
    NomPaysAnglais,
    SocieteId,
    NomSociete
FROM dbo.DimContact;
GO

-- Vue pour les sessions
IF OBJECT_ID('dbo.vSessions', 'V') IS NOT NULL
    DROP VIEW dbo.vSessions;
GO

CREATE VIEW dbo.vSessions AS
SELECT 
    DimSessionSk,
    SessionId,
    LangueLocal,
    LangueFrancais,
    DateDebut,
    Categorie,
    Domaine,
    Prix,
    Note,
    Duree,
    FormateurId,
    NomFormateur,
    SocieteFormateurId,
    NomSocieteFormateur,
    NomVilleSocieteFormateur,
    NomSalleFormation,
    NomLieuFormation,
    NomVilleFormation
FROM dbo.DimSession;
GO

-- Vue pour les inscriptions (fait)
IF OBJECT_ID('dbo.vInscriptions', 'V') IS NOT NULL
    DROP VIEW dbo.vInscriptions;
GO

CREATE VIEW dbo.vInscriptions AS
SELECT 
    fi.FactInscriptionSk,
    fi.DimInscriptionSk,
    fi.DimSessionSk,
    fi.DateSession,
    fi.DimContactSk,
    fi.MontantHT,
    fi.DateFacture,
    di.InscriptionId,
    di.ReferenceCommande,
    ds.SessionId,
    ds.LangueFrancais AS Formation,
    ds.DateDebut,
    ds.Categorie,
    ds.Domaine,
    ds.Prix AS PrixSession,
    ds.Note,
    ds.Duree,
    ds.NomFormateur,
    ds.NomSocieteFormateur,
    dc.ContactId,
    dc.Nom AS NomContact,
    dc.Prenom AS PrenomContact,
    dc.Email AS EmailContact,
    dc.Sexe AS SexeContact,
    dc.NomSociete AS SocieteContact,
    dc.Ville AS VilleContact
FROM dbo.FactInscription fi
INNER JOIN dbo.DimInscription di ON fi.DimInscriptionSk = di.DimInscriptionSk
INNER JOIN dbo.DimSession ds ON fi.DimSessionSk = ds.DimSessionSk
INNER JOIN dbo.DimContact dc ON fi.DimContactSk = dc.DimContactSk;
GO

PRINT 'Vues créées avec succès.';
GO

-- 7. Requête test pour VS Code
PRINT '';
PRINT '=== REQUÊTE TEST POUR VS CODE ===';
PRINT 'Copiez cette requête dans VS Code :';

SELECT 
    'Résumé' AS Type,
    COUNT(*) AS NombreInscriptions,
    SUM(MontantHT) AS MontantHTTotal,
    AVG(MontantHT) AS MontantHTMoyen,
    MIN(DateSession) AS PremiereDate,
    MAX(DateSession) AS DerniereDate
FROM dbo.FactInscription
UNION ALL
SELECT 
    'Par Formation',
    COUNT(*),
    SUM(MontantHT),
    AVG(MontantHT),
    NULL,
    NULL
FROM dbo.vInscriptions
GROUP BY Formation
ORDER BY Type DESC, MontantHTTotal DESC;
GO

-- 8. Index pour les performances
PRINT '';
PRINT '=== CRÉATION DES INDEX ===';

CREATE INDEX IX_DimContact_ContactId ON dbo.DimContact(ContactId);
CREATE INDEX IX_DimSession_SessionId ON dbo.DimSession(SessionId);
CREATE INDEX IX_DimInscription_InscriptionId ON dbo.DimInscription(InscriptionId);
CREATE INDEX IX_FactInscription_Dates ON dbo.FactInscription(DateSession, DateFacture);
CREATE INDEX IX_FactInscription_Montant ON dbo.FactInscription(MontantHT);

PRINT 'Index créés avec succès.';
GO

PRINT '';
PRINT '=== SCRIPT TERMINÉ AVEC SUCCÈS ===';
PRINT 'Vos tables contiennent maintenant des données !';
PRINT '';
PRINT 'Pour VS Code, utilisez ces requêtes :';
PRINT '1. SELECT * FROM vInscriptions;';
PRINT '2. SELECT * FROM vContacts;';
PRINT '3. SELECT * FROM vSessions;';
GO


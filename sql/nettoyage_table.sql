USE [PachaDataFormation];
GO

--------------------------------------------------------
-- 1) SUPPRIMER LES FOREIGN KEYS
--------------------------------------------------------
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_FactInscription_DimInscription')
    ALTER TABLE [DWH].[FactInscription] DROP CONSTRAINT [fk_FactInscription_DimInscription];

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_FactInscription_DimSession')
    ALTER TABLE [DWH].[FactInscription] DROP CONSTRAINT [fk_FactInscription_DimSession];

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_FactInscription_DimContact')
    ALTER TABLE [DWH].[FactInscription] DROP CONSTRAINT [fk_FactInscription_DimContact];
GO

--------------------------------------------------------
-- 2) SUPPRIMER LES TABLES
--------------------------------------------------------
IF OBJECT_ID('[FactInscription]', 'U') IS NOT NULL
    DROP TABLE [FactInscription];
GO

IF OBJECT_ID('[DimInscription]', 'U') IS NOT NULL
    DROP TABLE [DimInscription];
GO

IF OBJECT_ID('[DWH].[DimSession]', 'U') IS NOT NULL
    DROP TABLE [DimSession];
GO

IF OBJECT_ID('[DWH].[DimContact]', 'U') IS NOT NULL
    DROP TABLE [DWH].[DimContact];
GO

--------------------------------------------------------
-- 3) CRÉER LE SCHÉMA
--------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'DWH')
    EXEC('CREATE SCHEMA [DWH]');
GO

--------------------------------------------------------
-- 4) CRÉATION DES TABLES
--------------------------------------------------------

-- =============================================
-- DIMCONTACT
-- =============================================
CREATE TABLE [DWH].[DimContact](
    [DimContactSk] INT IDENTITY(1,1) NOT NULL,
    [ContactId] INT NOT NULL,
    [Nom] VARCHAR(50) NOT NULL,
    [Prenom] VARCHAR(50) NULL,
    [Email] VARCHAR(150) NULL,
    [Sexe] VARCHAR(1) NULL,
    [Ville] VARCHAR(255) NULL,
    [CodeDepartement] CHAR(2) NULL,
    [NomDepartement] VARCHAR(50) NULL,
    [CodePays] CHAR(3) NULL,
    [NomPaysFrancais] VARCHAR(50) NULL,
    [NomPaysAnglais] VARCHAR(50) NULL,
    [SocieteId] INT NULL,
    [NomSociete] VARCHAR(60) NULL,
    [DateDebutValidite] DATE NOT NULL DEFAULT GETDATE(),
    [DateFinValidite] DATE NULL,
    [EstActif] BIT NOT NULL DEFAULT 1,
    CONSTRAINT [pk_DimContact] PRIMARY KEY CLUSTERED (DimContactSk),
    CONSTRAINT [uq_DimContact_ContactId] UNIQUE NONCLUSTERED (ContactId, DateDebutValidite)
);
GO

-- =============================================
-- DIMSESSION
-- =============================================
CREATE TABLE [DWH].[DimSession](
    [DimSessionSk] INT IDENTITY(1,1) NOT NULL,
    [SessionId] INT NOT NULL,
    [LangueLocal] VARCHAR(50) NULL,
    [LangueFrancais] VARCHAR(50) NULL,
    [DateDebut] DATE NOT NULL,
    [Categorie] CHAR(2) NULL,
    [Domaine] CHAR(2) NULL,
    [Prix] DECIMAL(8,2) NULL,
    [Note] TINYINT NULL,
    [Duree] TINYINT NULL,
    [FormateurId] INT NULL,
    [NomFormateur] VARCHAR(50) NULL,
    [SocieteFormateurId] INT NULL,
    [NomSocieteFormateur] VARCHAR(50) NULL,
    [NomVilleSocieteFormateur] VARCHAR(255) NULL,
    [NomSalleFormation] VARCHAR(20) NULL,
    [NomLieuFormation] VARCHAR(30) NULL,
    [NomVilleFormation] VARCHAR(255) NULL,
    [DateDebutValidite] DATE NOT NULL DEFAULT GETDATE(),
    [DateFinValidite] DATE NULL,
    [EstActif] BIT NOT NULL DEFAULT 1,
    CONSTRAINT [pk_DimSession] PRIMARY KEY CLUSTERED (DimSessionSk),
    CONSTRAINT [uq_DimSession_Id] UNIQUE NONCLUSTERED (SessionId, DateDebutValidite)
);
GO

-- =============================================
-- DIMINSCRIPTION
-- =============================================
CREATE TABLE [DWH].[DimInscription](
    [DimInscriptionSk] INT IDENTITY(1,1) NOT NULL,
    [InscriptionId] INT NOT NULL,
    [ReferenceCommande] VARCHAR(100) NULL,
    [DateDebutValidite] DATE NOT NULL DEFAULT GETDATE(),
    [DateFinValidite] DATE NULL,
    [EstActif] BIT NOT NULL DEFAULT 1,
    CONSTRAINT [pk_DimInscription] PRIMARY KEY CLUSTERED (DimInscriptionSk),
    CONSTRAINT [uq_DimInscription_Id] UNIQUE NONCLUSTERED (InscriptionId, DateDebutValidite)
);
GO

-- =============================================
-- FACTINSCRIPTION
-- =============================================
CREATE TABLE [DWH].[FactInscription](
    [FactInscriptionSk] BIGINT IDENTITY(1,1) NOT NULL,
    [DimInscriptionSk] INT NOT NULL,
    [DimSessionSk] INT NOT NULL,
    [DateSession] DATE NOT NULL,
    [DimContactSk] INT NOT NULL,
    [MontantHT] DECIMAL(7,2) NULL,
    [DateFacture] DATE NULL,
    [MontantTTC] DECIMAL(7,2) NULL,
    [TauxTVA] DECIMAL(5,2) NULL,
    [Remise] TINYINT NULL,
    [Present] BIT NULL,
    [DateCreation] SMALLDATETIME NULL,
    CONSTRAINT [pk_FactInscription] PRIMARY KEY CLUSTERED (FactInscriptionSk),
    CONSTRAINT [fk_FactInscription_DimInscription]
        FOREIGN KEY (DimInscriptionSk) REFERENCES [DWH].[DimInscription] (DimInscriptionSk),
    CONSTRAINT [fk_FactInscription_DimSession]
        FOREIGN KEY (DimSessionSk) REFERENCES [DWH].[DimSession] (DimSessionSk),
    CONSTRAINT [fk_FactInscription_DimContact]
        FOREIGN KEY (DimContactSk) REFERENCES [DWH].[DimContact] (DimContactSk)
);
GO

--------------------------------------------------------
-- 5) INDEX
--------------------------------------------------------
CREATE INDEX ix_FactInscription_DateSession 
ON [DWH].[FactInscription](DateSession);
GO

CREATE INDEX ix_FactInscription_DateFacture 
ON [DWH].[FactInscription](DateFacture);
GO

PRINT 'Création terminée.';
GO


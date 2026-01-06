-- =============================================
-- Script: 04_Create_Star_Schema.sql
-- Description: Création du schéma en étoile (Star Schema)
-- Dimensions: DimContact, DimSession, DimInscription
-- Fait: FactInscription
-- =============================================

USE PachaDataFormationDM
GO


PRINT '========================================'
PRINT 'CRÉATION DU SCHÉMA EN ÉTOILE'
PRINT '========================================'
PRINT ''

-- =============================================
-- ÉTAPE 1: Supprimer les tables dans le bon ordre
-- =============================================
PRINT 'Suppression des tables existantes...'

-- Supprimer d'abord la table de FAITS (qui a des FK vers les dimensions)
IF OBJECT_ID('[FactInscription]', 'U') IS NOT NULL
BEGIN
    DROP TABLE [FactInscription]
    PRINT '✓ FactInscription supprimée'
END

-- Maintenant supprimer les DIMENSIONS
IF OBJECT_ID('[DimInscription]', 'U') IS NOT NULL
BEGIN
    DROP TABLE [DimInscription]
    PRINT '✓ DimInscription supprimée'
END

IF OBJECT_ID('[DimSession]', 'U') IS NOT NULL
BEGIN
    DROP TABLE [DimSession]
    PRINT '✓ DimSession supprimée'
END

IF OBJECT_ID('[DimContact]', 'U') IS NOT NULL
BEGIN
    DROP TABLE [DimContact]
    PRINT '✓ DimContact supprimée'
END

PRINT ''
GO

-- =============================================
-- ÉTAPE 2: Dimension DimContact
-- =============================================
PRINT 'Création de DimContact...'

CREATE TABLE [DimContact](
    [DimContactSk] [int] IDENTITY(1,1) NOT NULL,
    [ContactId] [int] NOT NULL,
    [Nom] [varchar](50) NOT NULL,
    [Prenom] [varchar](50) NULL,
    [Email] [varchar](150) NULL,
    [Sexe] [varchar](10) NULL,
    [Ville] [varchar](255) NULL,
    [CodeDepartement] [char](2) NULL,
    [NomDepartement] [varchar](50) NULL,
    [CodePays] [char](3) NULL,
    [NomPaysFrancais] [varchar](50) NULL,
    [NomPaysAnglais] [varchar](50) NULL,
    [SocieteId] [int] NULL,
    [NomSociete] [varchar](60) NULL,
    [DateDebutValidite] [date] NOT NULL DEFAULT GETDATE(),
    [DateFinValidite] [date] NULL,
    [EstActif] [bit] NOT NULL DEFAULT 1,
    CONSTRAINT [pk_DimContact] PRIMARY KEY CLUSTERED ([DimContactSk] ASC),
    CONSTRAINT [uq_DimContact_ContactId] UNIQUE NONCLUSTERED ([ContactId] ASC, [DateDebutValidite] ASC)
)

PRINT '✓ DimContact créée'
PRINT ''
GO

-- =============================================
-- ÉTAPE 3: Dimension DimSession
-- =============================================
PRINT 'Création de DimSession...'

CREATE TABLE [DimSession](
    [DimSessionSk] [int] IDENTITY(1,1) NOT NULL,
    [SessionId] [int] NOT NULL,
    [LangueLocal] [varchar](50) NULL,
    [LangueFrancais] [varchar](50) NULL,
    [DateDebut] [date] NOT NULL,
    [Categorie] [char](2) NULL,
    [Domaine] [char](2) NULL,
    [Prix] [decimal](8, 2) NULL,
    [Note] [tinyint] NULL,
    [Duree] [tinyint] NULL,
    [FormateurId] [int] NULL,
    [NomFormateur] [varchar](50) NULL,
    [SocieteFormateurId] [int] NULL,
    [NomSocieteFormateur] [varchar](50) NULL,
    [NomVilleSocieteFormateur] [varchar](255) NULL,
    [NomSalleFormation] [varchar](20) NULL,
    [NomLieuFormation] [varchar](30) NULL,
    [NomVilleFormation] [varchar](255) NULL,
    [DateDebutValidite] [date] NOT NULL DEFAULT GETDATE(),
    [DateFinValidite] [date] NULL,
    [EstActif] [bit] NOT NULL DEFAULT 1,
    CONSTRAINT [pk_DimSession] PRIMARY KEY CLUSTERED ([DimSessionSk] ASC),
    CONSTRAINT [uq_DimSession_SessionId] UNIQUE NONCLUSTERED ([SessionId] ASC, [DateDebutValidite] ASC)
)

PRINT '✓ DimSession créée'
PRINT ''
GO

-- =============================================
-- ÉTAPE 4: Dimension DimInscription
-- =============================================
PRINT 'Création de DimInscription...'

CREATE TABLE [DimInscription](
    [DimInscriptionSk] [int] IDENTITY(1,1) NOT NULL,
    [InscriptionId] [int] NOT NULL,
    [ReferenceCommande] [varchar](100) NULL,
    [DateDebutValidite] [date] NOT NULL DEFAULT GETDATE(),
    [DateFinValidite] [date] NULL,
    [EstActif] [bit] NOT NULL DEFAULT 1,
    CONSTRAINT [pk_DimInscription] PRIMARY KEY CLUSTERED ([DimInscriptionSk] ASC),
    CONSTRAINT [uq_DimInscription_InscriptionId] UNIQUE NONCLUSTERED ([InscriptionId] ASC, [DateDebutValidite] ASC)
)

PRINT '✓ DimInscription créée'
PRINT ''
GO

-- =============================================
-- ÉTAPE 5: Fait FactInscription
-- =============================================
PRINT 'Création de FactInscription...'

CREATE TABLE [FactInscription](
    [FactInscriptionSk] [bigint] IDENTITY(1,1) NOT NULL,
    [DimInscriptionSk] [int] NOT NULL,
    [DimSessionSk] [int] NOT NULL,
    [DateSession] [date] NOT NULL,
    [DimContactSk] [int] NOT NULL,
    [MontantHT] [decimal](7, 2) NULL,
    [DateFacture] [date] NULL,
    [MontantTTC] [decimal](7, 2) NULL,
    [TauxTVA] [decimal](5, 2) NULL,
    [Remise] [tinyint] NULL,
    [Present] [bit] NULL,
    [DateCreation] [smalldatetime] NULL,
    CONSTRAINT [pk_FactInscription] PRIMARY KEY CLUSTERED ([FactInscriptionSk] ASC),
    CONSTRAINT [fk_FactInscription_DimInscription] FOREIGN KEY([DimInscriptionSk])
        REFERENCES [DimInscription] ([DimInscriptionSk]),
    CONSTRAINT [fk_FactInscription_DimSession] FOREIGN KEY([DimSessionSk])
        REFERENCES [DimSession] ([DimSessionSk]),
    CONSTRAINT [fk_FactInscription_DimContact] FOREIGN KEY([DimContactSk])
        REFERENCES [DimContact] ([DimContactSk])
)

PRINT '✓ FactInscription créée'
PRINT ''
GO

-- =============================================
-- ÉTAPE 6: Créer les index pour performance
-- =============================================
PRINT 'Création des index...'

CREATE NONCLUSTERED INDEX [ix_FactInscription_DateSession] 
ON [FactInscription] ([DateSession] ASC)

CREATE NONCLUSTERED INDEX [ix_FactInscription_DateFacture] 
ON [FactInscription] ([DateFacture] ASC)

CREATE NONCLUSTERED INDEX [ix_FactInscription_DimInscriptionSk] 
ON [FactInscription] ([DimInscriptionSk] ASC)

CREATE NONCLUSTERED INDEX [ix_FactInscription_DimSessionSk] 
ON [FactInscription] ([DimSessionSk] ASC)

CREATE NONCLUSTERED INDEX [ix_FactInscription_DimContactSk] 
ON [FactInscription] ([DimContactSk] ASC)

PRINT '✓ Index créés'
PRINT ''
GO

-- =============================================
-- RÉSUMÉ
-- =============================================
PRINT ''
PRINT '========================================'
PRINT '=== RÉSUMÉ DU SCHÉMA EN ÉTOILE ==='
PRINT '========================================'
PRINT ''
PRINT 'Tables créées:'
PRINT '  • DWH.DimContact'
PRINT '  • DWH.DimSession'
PRINT '  • DWH.DimInscription'
PRINT '  • DWH.FactInscription'
PRINT ''
PRINT 'Index créés: 5'
PRINT ''
PRINT '✓✓✓ Schéma en étoile créé avec succès! ✓✓✓'
PRINT '========================================'
GO
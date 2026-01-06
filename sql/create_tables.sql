-- =============================================
-- Script: ddl_tables.sql
-- Description: Création du modèle relationnel initial
-- Tables: Contact, Session, Inscription, Facture, etc.
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Contact')
    EXEC('CREATE SCHEMA [Contact]')
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Stage')
    EXEC('CREATE SCHEMA [Stage]')
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Inscription')
    EXEC('CREATE SCHEMA [Inscription]')
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Formateur')
    EXEC('CREATE SCHEMA [Formateur]')
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Reference')
    EXEC('CREATE SCHEMA [Reference]')
GO

-- =============================================
-- Table: Contact.Societe
-- =============================================
IF OBJECT_ID('[Contact].[Societe]', 'U') IS NOT NULL
    DROP TABLE [Contact].[Societe]
GO
CREATE TABLE [Contact].[Societe](
	[SocieteId] [int] IDENTITY(1,1) NOT NULL,
	[Nom] [varchar](60) NOT NULL,
	[NumeroTVA] [varchar](30) NULL,
	[TypeRelance] [smallint] NOT NULL,
	[FacturationAvantInscription] [bit] NOT NULL,
	[Telephone2] [varchar](30) NULL,
	[Telephone1] [varchar](30) NULL,
	[Remise] [tinyint] NOT NULL,
 CONSTRAINT [pk_Societe] PRIMARY KEY CLUSTERED 
(
	[SocieteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_Societe_Nom] UNIQUE NONCLUSTERED 
(
	[Nom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- =============================================
-- Table: Contact.Contact
-- =============================================
IF OBJECT_ID('[Contact].[Contact]', 'U') IS NOT NULL
    DROP TABLE [Contact].[Contact]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contact].[Contact](
	[ContactId] [int] IDENTITY(1,1) NOT NULL,
	[Titre] [varchar](3) NULL,
	[Nom] [varchar](50) NOT NULL,
	[Prenom] [varchar](50) NULL,
	[Email] [varchar](150) NULL,
	[Telephone] [varchar](15) NULL,
	[Telecopie] [varchar](15) NULL,
	[Sexe] [varchar](1) NULL,
	[Portable] [varchar](15) NULL,
	[AdressePostaleId] [int] NOT NULL,
	[SocieteId] [int] NULL,
 CONSTRAINT [pk_Contact] PRIMARY KEY CLUSTERED 
(
	[ContactId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- =============================================
-- Table: Stage.Stage
-- =============================================
IF OBJECT_ID('[Stage].[Stage]', 'U') IS NOT NULL
    DROP TABLE [Stage].[Stage]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Stage].[Stage](
	[StageId] [int] IDENTITY(1,1) NOT NULL,
	[Categorie] [char](2) NOT NULL,
	[Domaine] [char](2) NOT NULL,
	[DateCreation] [smalldatetime] NOT NULL,
	[DateAnnulation] [date] NULL,
	[CommentairesPlanification] [varchar](2000) NULL,
	[CommentairesProduction] [varchar](2000) NULL,
	[Duree] [tinyint] NOT NULL,
	[NombreStagiairesMaximum] [tinyint] NOT NULL,
 CONSTRAINT [pk_Stage] PRIMARY KEY CLUSTERED 
(
	[StageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- =============================================
-- Table: Stage.Langue
-- =============================================
IF OBJECT_ID('[Stage].[Langue]', 'U') IS NOT NULL
    DROP TABLE [Stage].[Langue]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Stage].[Langue](
	[LangueCd] [char](2) NOT NULL,
	[NomLocal] [varchar](50) NOT NULL,
	[NomFrancais] [varchar](50) NOT NULL,
 CONSTRAINT [pk_Langue] PRIMARY KEY CLUSTERED 
(
	[LangueCd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_Langue_NomFrancais] UNIQUE NONCLUSTERED 
(
	[NomFrancais] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_Langue_NomLocal] UNIQUE NONCLUSTERED 
(
	[NomLocal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- =============================================
-- Table: Stage.Session
-- =============================================
IF OBJECT_ID('[Stage].[Session]', 'U') IS NOT NULL
    DROP TABLE [Stage].[Session]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Stage].[Session](
	[SessionId] [int] IDENTITY(1,1) NOT NULL,
	[StageId] [int] NOT NULL,
	[LangueCd] [char](2) NOT NULL,
	[SalleFormationId] [int] NULL,
	[DateDebut] [date] NOT NULL,
	[Prix] [decimal](8, 2) NULL,
	[Note] [tinyint] NULL,
	[Statut] [char](10) NULL,
	[DateCreation] [date] NOT NULL,
	[Duree] [tinyint] NULL,
	[IntraEntrerprise] [bit] NOT NULL,
	[Remarques] [varchar](1500) NULL,
	[FormateurId] [int] NULL,
 CONSTRAINT [pk_SessionStage] PRIMARY KEY CLUSTERED 
(
	[SessionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_SessionStage_CodeDateLieu] UNIQUE NONCLUSTERED 
(
	[DateDebut] ASC,
	[SalleFormationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


-- =============================================
-- Table: Inscription.Inscription
-- =============================================
IF OBJECT_ID('[Inscription].[Inscription]', 'U') IS NOT NULL
    DROP TABLE [Inscription].[Inscription]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inscription].[Inscription](
	[InscriptionId] [int] IDENTITY(1,1) NOT NULL,
	[SessionId] [int] NOT NULL,
	[DecideurInscriptionId] [int] NULL,
	[ContactId] [int] NULL,
	[DateAnnulation] [date] NULL,
	[Remise] [tinyint] NOT NULL,
	[Present] [bit] NOT NULL,
	[DateCreation] [smalldatetime] NOT NULL,
	[ReferenceCommande] [varchar](100) NULL,
	[ConventionEnvoyee] [bit] NOT NULL,
	[ConvocationEnvoyee] [bit] NOT NULL,
	[ListeAttente] [bit] NOT NULL,
	[FeuilleEmargement] [varchar](1000) NULL,
 CONSTRAINT [pk_Inscription] PRIMARY KEY CLUSTERED 
(
	[InscriptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- =============================================
-- Table: Inscription.Facture
-- =============================================
IF OBJECT_ID('[Inscription].[Facture]', 'U') IS NOT NULL
    DROP TABLE [Inscription].[Facture]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inscription].[Facture](
	[FactureCd] [varchar](50) NOT NULL,
	[CodeRemise] [char](2) NULL,
	[Remise] [decimal](10, 7) NULL,
	[DateCreation] [smalldatetime] NOT NULL,
	[DateFacture] [date] NULL,
	[Relance] [tinyint] NOT NULL,
	[DateRelance] [date] NULL,
	[PART] [decimal](7, 4) NULL,
	[ReferenceCommande] [varchar](100) NULL,
	[MontantHT] [decimal](7, 2) NOT NULL,
	[MontantTTC] [decimal](7, 2) NOT NULL,
	[TauxTVA] [decimal](5, 2) NOT NULL,
 CONSTRAINT [pk_Facture] PRIMARY KEY CLUSTERED 
(
	[FactureCd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
-- =============================================
-- Table: Inscription.InscriptionFacture
-- =============================================
IF OBJECT_ID('[Inscription].[InscriptionFacture]', 'U') IS NOT NULL
    DROP TABLE [Inscription].[InscriptionFacture]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inscription].[InscriptionFacture](
	[InscriptionId] [int] NOT NULL,
	[FactureCd] [varchar](50) NOT NULL,
 CONSTRAINT [pk_InscriptionFacture] PRIMARY KEY CLUSTERED 
(
	[InscriptionId] ASC,
	[FactureCd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- =============================================
-- Table: Formateur.Formateur
-- =============================================
IF OBJECT_ID('[Formateur].[Formateur]', 'U') IS NOT NULL
    DROP TABLE [Formateur].[Formateur]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Formateur].[Formateur](
	[FormateurId] [int] IDENTITY(1,1) NOT NULL,
	[NoSecuriteSociale] [varchar](18) NULL,
	[Statut] [char](1) NULL,
	[Commentaires] [varchar](1000) NULL,
	[NePasContacter] [bit] NOT NULL,
	[CV] [bit] NULL,
	[CreationDate] [date] NOT NULL,
	[CreationUser] [varchar](128) NOT NULL,
	[ContactId] [int] NOT NULL,
	[SocieteFormateurId] [int] NOT NULL,
 CONSTRAINT [pk$Formateur] PRIMARY KEY CLUSTERED 
(
	[FormateurId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_Formateur_ContactId] UNIQUE NONCLUSTERED 
(
	[ContactId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- =============================================
-- Table: Formateur.SocieteFormateur
-- =============================================
IF OBJECT_ID('[Formateur].[SocieteFormateur]', 'U') IS NOT NULL
    DROP TABLE [Formateur].[SocieteFormateur]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Formateur].[SocieteFormateur](
	[SocieteFormateurId] [int] IDENTITY(1,1) NOT NULL,
	[Nom] [varchar](50) NOT NULL,
	[AdresseFormateurId] [int] NOT NULL,
	[TelephoneSociete] [varchar](30) NULL,
	[TelephoneAdministratif] [varchar](30) NULL,
	[Fax] [varchar](30) NULL,
	[Contact] [varchar](150) NULL,
	[Commentaires] [varchar](1000) NULL,
	[Statut] [char](1) NULL,
	[EmailContact] [varchar](150) NULL,
 CONSTRAINT [pk$SocieteFormateur] PRIMARY KEY CLUSTERED 
(
	[SocieteFormateurId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Nom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

-- Ajouter la clé étrangère pour Formateur.SocieteFormateurId
ALTER TABLE [Formateur].[Formateur]
ADD CONSTRAINT [fk_Formateur_SocieteFormateur] 
FOREIGN KEY([SocieteFormateurId])
REFERENCES [Formateur].[SocieteFormateur] ([SocieteFormateurId])
GO

-- Ajouter la clé étrangère pour Session.FormateurId
ALTER TABLE [Stage].[Session]
ADD CONSTRAINT [fk_Session_Formateur] 
FOREIGN KEY([FormateurId])
REFERENCES [Formateur].[Formateur] ([FormateurId])
GO

PRINT 'Modèle relationnel initial créé avec succès.'
GO

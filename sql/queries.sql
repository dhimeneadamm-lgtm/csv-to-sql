-----------------------------------------------------
-- Test de l'importation csv
-----------------------------------------------------
SELECT 
    'Contact.Societe' AS TableName, COUNT(*) AS Total FROM [Contact].[Societe]
UNION ALL SELECT 'Contact.Contact', COUNT(*) FROM [Contact].[Contact]
UNION ALL SELECT 'Stage.Langue', COUNT(*) FROM [Stage].[Langue]
UNION ALL SELECT 'Stage.Stage', COUNT(*) FROM [Stage].[Stage]
UNION ALL SELECT 'Stage.Session', COUNT(*) FROM [Stage].[Session]
UNION ALL SELECT 'Formateur.SocieteFormateur', COUNT(*) FROM [Formateur].[SocieteFormateur]
UNION ALL SELECT 'Formateur.Formateur', COUNT(*) FROM [Formateur].[Formateur]
UNION ALL SELECT 'Inscription.Inscription', COUNT(*) FROM [Inscription].[Inscription]
UNION ALL SELECT 'Inscription.Facture', COUNT(*) FROM [Inscription].[Facture]
UNION ALL SELECT 'Inscription.InscriptionFacture', COUNT(*) FROM [Inscription].[InscriptionFacture];

PRINT 'Import terminé !';

-- Afficher un �chantillon des donn�es Silver
PRINT ''
PRINT '=== �CHANTILLON DES DONN�ES SILVER ==='
SELECT TOP 5 * FROM [vSilverContact]
GO

SELECT TOP 5 * FROM [vSilverSession]
GO

SELECT TOP 5 * FROM [vSilverInscription]
GO


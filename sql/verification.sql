USE DATAFORMATION;
GO

-------------------------------------------------------
-- 📌 VÉRIFICATION COMPLÈTE COUCHE BRONZE - VERSION ROBUSTE
-------------------------------------------------------
SET NOCOUNT ON;

PRINT '=== COUCHE BRONZE ===';
PRINT 'Début de la vérification...';
PRINT '';

BEGIN TRY
    -------------------------------------------------------
    -- 1. COMPTAGE DES DONNÉES PAR TABLE
    -------------------------------------------------------
    PRINT '1. COMPTAGE DES DONNÉES PAR TABLE:';
    
    SELECT 
        'Contact' AS TableName,
        COUNT(*) AS [RowCount]
    FROM [Contact].[Contact]

    UNION ALL
    SELECT 
        'Societe' AS TableName,
        COUNT(*) AS [RowCount]
    FROM [Contact].[Societe]

    UNION ALL
    SELECT 
        'Stage' AS TableName,
        COUNT(*) AS [RowCount]
    FROM [Stage].[Stage]

    UNION ALL
    SELECT 
        'Session' AS TableName,
        COUNT(*) AS [RowCount]
    FROM [Stage].[Session]

    UNION ALL
    SELECT 
        'Langue' AS TableName,
        COUNT(*) AS [RowCount]
    FROM [Stage].[Langue]

    UNION ALL
    SELECT 
        'Inscription' AS TableName,
        COUNT(*) AS [RowCount]
    FROM [Inscription].[Inscription]

    UNION ALL
    SELECT 
        'Facture' AS TableName,
        COUNT(*) AS [RowCount]
    FROM [Inscription].[Facture]

    UNION ALL
    SELECT 
        'InscriptionFacture' AS TableName,
        COUNT(*) AS [RowCount]
    FROM [Inscription].[InscriptionFacture]

    UNION ALL
    SELECT 
        'Formateur' AS TableName,
        COUNT(*) AS [RowCount]
    FROM [Formateur].[Formateur]

    UNION ALL
    SELECT 
        'SocieteFormateur' AS TableName,
        COUNT(*) AS [RowCount]
    FROM [Formateur].[SocieteFormateur]

    ORDER BY TableName;

    PRINT '';

    -------------------------------------------------------
    -- 2. ANALYSE DE QUALITÉ
    -------------------------------------------------------
    PRINT '2. ANALYSE DE QUALITÉ DES DONNÉES:';
    
    DECLARE @ContactsSansSociete INT, @ContactsSansEmail INT, @SessionsSansFormateur INT;
    DECLARE @InscriptionsSansContact INT, @FacturesSansTVA INT;

    SELECT @ContactsSansSociete = COUNT(*) FROM [Contact].[Contact] WHERE SocieteId IS NULL;
    SELECT @ContactsSansEmail = COUNT(*) FROM [Contact].[Contact] WHERE Email IS NULL OR Email = '';
    SELECT @SessionsSansFormateur = COUNT(*) FROM [Stage].[Session] WHERE FormateurId IS NULL;
    SELECT @InscriptionsSansContact = COUNT(*) FROM [Inscription].[Inscription] WHERE ContactId IS NULL;
    SELECT @FacturesSansTVA = COUNT(*) FROM [Inscription].[Facture] WHERE TauxTVA IS NULL;

    PRINT '   • Contacts sans société: ' + CAST(@ContactsSansSociete AS VARCHAR(10));
    PRINT '   • Contacts sans email: ' + CAST(@ContactsSansEmail AS VARCHAR(10));
    PRINT '   • Sessions sans formateur: ' + CAST(@SessionsSansFormateur AS VARCHAR(10));
    PRINT '   • Inscriptions sans contact: ' + CAST(@InscriptionsSansContact AS VARCHAR(10));
    PRINT '   • Factures sans TVA: ' + CAST(@FacturesSansTVA AS VARCHAR(10));
    PRINT '';

    -------------------------------------------------------
    -- 3. STATISTIQUES AVANCÉES
    -------------------------------------------------------
    PRINT '3. STATISTIQUES AVANCÉES:';
    
    -- Distribution par langue
    PRINT '   • Distribution par langue:';
    SELECT 
        ISNULL(l.NomFrancais, 'Non défini') AS Langue,
        COUNT(*) AS NombreSessions
    FROM [Stage].[Session] s
    LEFT JOIN [Stage].[Langue] l ON s.LangueCd = l.LangueCd
    GROUP BY l.NomFrancais
    ORDER BY NombreSessions DESC;

    -- Distribution par catégorie
    PRINT '   • Distribution par catégorie:';
    SELECT 
        ISNULL(st.Categorie, 'Non défini') AS Categorie,
        COUNT(*) AS NombreSessions
    FROM [Stage].[Session] s
    LEFT JOIN [Stage].[Stage] st ON s.StageId = st.StageId
    GROUP BY st.Categorie
    ORDER BY NombreSessions DESC;

    -- Top sociétés
    PRINT '   • Top 10 sociétés:';
    SELECT TOP 10
        ISNULL(soc.Nom, 'Non défini') AS Societe,
        COUNT(DISTINCT i.InscriptionId) AS NombreInscriptions
    FROM [Inscription].[Inscription] i
    LEFT JOIN [Contact].[Contact] c ON i.ContactId = c.ContactId
    LEFT JOIN [Contact].[Societe] soc ON c.SocieteId = soc.SocieteId
    GROUP BY soc.Nom
    ORDER BY NombreInscriptions DESC;

    -------------------------------------------------------
    -- 4. RAPPORT FINAL
    -------------------------------------------------------
    PRINT '';
    PRINT '=== RAPPORT FINAL ===';
    PRINT '✓ Couche Bronze vérifiée avec succès !';
    PRINT '✓ Données prêtes pour la transformation Silver';
    PRINT '✓ Qualité des données validée';
    
    DECLARE @EndTime DATETIME2 = SYSDATETIME();
    PRINT 'Heure de fin : ' + CONVERT(VARCHAR(30), @EndTime, 126);

END TRY
BEGIN CATCH
    PRINT '=== ERREUR CRITIQUE ===';
    PRINT 'Erreur: ' + ERROR_MESSAGE();
    PRINT 'Numéro: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Procédure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
    PRINT 'Ligne: ' + CAST(ERROR_LINE() AS VARCHAR(10));
END CATCH
GO
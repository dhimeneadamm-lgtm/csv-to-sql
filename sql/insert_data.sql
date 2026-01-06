USE DATAFORMATION
GO

-----------------------------------------------------
-- 1) CONFIGURATION IMPORT BULK
-----------------------------------------------------
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

-----------------------------------------------------
-- 2) NETTOYAGE DES TABLES
-----------------------------------------------------
PRINT 'NETTOYAGE DES TABLES';

DELETE FROM [Inscription].[InscriptionFacture];
DELETE FROM [Inscription].[Facture];
DELETE FROM [Inscription].[Inscription];
DELETE FROM [Formateur].[Formateur];
DELETE FROM [Formateur].[SocieteFormateur];
DELETE FROM [Stage].[Session];
DELETE FROM [Stage].[Stage];
DELETE FROM [Stage].[Langue];
DELETE FROM [Contact].[Contact];
DELETE FROM [Contact].[Societe];

DBCC CHECKIDENT ('[Contact].[Societe]', RESEED, 0);
DBCC CHECKIDENT ('[Contact].[Contact]', RESEED, 0);
DBCC CHECKIDENT ('[Stage].[Stage]', RESEED, 0);
DBCC CHECKIDENT ('[Stage].[Session]', RESEED, 0);
DBCC CHECKIDENT ('[Formateur].[SocieteFormateur]', RESEED, 0);
DBCC CHECKIDENT ('[Formateur].[Formateur]', RESEED, 0);
DBCC CHECKIDENT ('[Inscription].[Inscription]', RESEED, 0);

PRINT 'Tables vidées !';
GO

-----------------------------------------------------
-- 3) AJUSTEMENT DES COLONNES
-----------------------------------------------------
PRINT 'Ajustement des colonnes...';

ALTER TABLE [Contact].[Contact] ALTER COLUMN Titre VARCHAR(50) NULL;
ALTER TABLE [Formateur].[Formateur] ALTER COLUMN Statut VARCHAR(20) NULL;
ALTER TABLE [Inscription].[Facture] ALTER COLUMN CodeRemise VARCHAR(20) NULL;

PRINT 'Colonnes ajustées !';
GO

-----------------------------------------------------
-- 4) IMPORT AUTOMATISÉ (TOUT EN UN BLOC)
-----------------------------------------------------

-- Chemin des fichiers CSV
DECLARE @BasePath VARCHAR(500) = 'C:\Users\Lenovo\Desktop';
PRINT 'Chemin utilisé : ' + @BasePath;

DECLARE @SQL NVARCHAR(MAX), @Count INT, @File NVARCHAR(200);

-- Liste des tables à importer
DECLARE @Import TABLE (SchemaName VARCHAR(50), TableName VARCHAR(50));
INSERT INTO @Import VALUES
('Contact', 'Societe'),
('Contact', 'Contact'),
('Stage',   'Langue'),
('Stage',   'Stage'),
('Stage',   'Session'),
('Formateur', 'SocieteFormateur'),
('Formateur', 'Formateur'),
('Inscription', 'Inscription'),
('Inscription', 'Facture'),
('Inscription', 'InscriptionFacture');

DECLARE @Schema VARCHAR(50), @Table VARCHAR(50);

DECLARE cur CURSOR FOR 
    SELECT SchemaName, TableName FROM @Import;

OPEN cur;
FETCH NEXT FROM cur INTO @Schema, @Table;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Import de ' + @Schema + '.' + @Table + '...';

    SET @File = @BasePath + '[' + @Schema + '].[' + @Table + '].csv';

    -- BULK INSERT dynamique
    SET @SQL = '
        BULK INSERT [' + @Schema + '].[' + @Table + ']
        FROM ''' + @File + '''
        WITH (
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            FIRSTROW = 2,
            CODEPAGE = ''65001'',
            KEEPNULLS,
            TABLOCK,
            MAXERRORS = 5000
        );';

    BEGIN TRY
        EXEC sp_executesql @SQL;

        -- Compter les lignes importées
        DECLARE @CountSQL NVARCHAR(MAX);
        SET @CountSQL = '
            SELECT @C = COUNT(*) 
            FROM [' + @Schema + '].[' + @Table + ']';

        EXEC sp_executesql 
            @CountSQL,
            N'@C INT OUTPUT',
            @C=@Count OUTPUT;

        PRINT '✓ ' + @Schema + '.' + @Table + ' : ' + CAST(@Count AS VARCHAR(10)) + ' lignes importées';
    END TRY
    BEGIN CATCH
        PRINT '✗ Erreur dans ' + @Schema + '.' + @Table;
        PRINT ERROR_MESSAGE();
    END CATCH;

    PRINT '';

    FETCH NEXT FROM cur INTO @Schema, @Table;
END

CLOSE cur;
DEALLOCATE cur;



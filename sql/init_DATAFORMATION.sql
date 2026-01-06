-- =============================================
-- Script: init_DATAFORMATION.sql
-- Description: Création de la base de données DATAFORMATION
-- =============================================
USE master
GO

-- Supprimer la base de données si elle existe déjà
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'DATAFORMATION')
BEGIN
    ALTER DATABASE DATAFORMATION SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DATAFORMATION;
END
GO

-- Créer la base de données DATAFORMATION
CREATE DATABASE DATAFORMATION
USE  master
GO
-- Utiliser la base de données
USE DATAFORMATION
GO

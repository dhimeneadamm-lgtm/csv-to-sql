USE PachaDataFormationDM
GO
PRINT '=== COUCHE SILVER ==='
PRINT 'Nettoyage et transformation des donn�es...'
GO
-- Vue Silver pour Contact enrichi
IF OBJECT_ID('[vSilverContact]', 'V') IS NOT NULL
    DROP VIEW [vSilverContact]
GO

CREATE VIEW [vSilverContact]
AS
SELECT 
    c.ContactId,
    c.Titre,
    c.Nom,
    c.Prenom,
    c.Email,
    c.Sexe,
    -- Enrichissement avec les donn�es de soci�t�
    c.SocieteId,
    ISNULL(s.Nom, 'Sans soci�t�') AS NomSociete,
    -- Donn�es g�ographiques (� enrichir si disponibles)
    NULL AS Ville,
    NULL AS CodeDepartement,
    NULL AS NomDepartement,
    NULL AS CodePays,
    NULL AS NomPaysFrancais,
    NULL AS NomPaysAnglais
FROM [PachaDataFormation].[Contact].Contact c
LEFT JOIN [PachaDataFormation].[Contact].Societe s ON c.SocieteId = s.SocieteId
WHERE c.Nom IS NOT NULL  -- Nettoyage: exclure les contacts sans nom
GO

-- Vue Silver pour Session enrichie
IF OBJECT_ID('[vSilverSession]', 'V') IS NOT NULL
    DROP VIEW [vSilverSession]
GO

CREATE VIEW [vSilverSession]
AS
SELECT 
    s.SessionId,
    s.StageId,
    s.LangueCd,
    l.NomLocal AS LangueLocal,
    l.NomFrancais AS LangueFrancais,
    s.DateDebut,
    st.Categorie,
    st.Domaine,
    s.Prix,
    s.Note,
    s.Duree,
    s.FormateurId,
    -- Enrichissement avec les donn�es du formateur
    f.ContactId AS FormateurContactId,
    cf.Nom + ' ' + ISNULL(cf.Prenom, '') AS NomFormateur,
    f.SocieteFormateurId,
    sf.Nom AS NomSocieteFormateur,
    -- Donn�es de localisation (� enrichir si disponibles)
    NULL AS NomSalleFormation,
    NULL AS NomLieuFormation,
    NULL AS NomVilleFormation,
    NULL AS NomVilleSocieteFormateur
FROM PachaDataFormation.[Stage].[Session] s
INNER JOIN PachaDataFormation.[Stage].[Stage] st ON s.StageId = st.StageId
INNER JOIN PachaDataFormation.[Stage].[Langue] l ON s.LangueCd = l.LangueCd
LEFT JOIN PachaDataFormation.[Formateur].[Formateur] f ON s.FormateurId = f.FormateurId
LEFT JOIN PachaDataFormation.[Contact].[Contact] cf ON f.ContactId = cf.ContactId
LEFT JOIN PachaDataFormation.[Formateur].[SocieteFormateur] sf ON f.SocieteFormateurId = sf.SocieteFormateurId
WHERE s.DateDebut IS NOT NULL  -- Nettoyage: exclure les sessions sans date
GO

-- Vue Silver pour Inscription enrichie
IF OBJECT_ID('[vSilverInscription]', 'V') IS NOT NULL
    DROP VIEW [vSilverInscription]
GO

CREATE VIEW [vSilverInscription]
AS
SELECT 
    i.InscriptionId,
    i.SessionId,
    i.ContactId,
    i.ReferenceCommande,
    i.DateCreation,
    i.Remise,
    i.Present,
    -- Enrichissement avec les donn�es de facture
    f.FactureCd,
    fact.DateFacture,
    fact.MontantHT,
    fact.MontantTTC,
    fact.TauxTVA,
    -- Date de session pour l'analyse
    s.DateDebut AS DateSession
FROM PachaDataFormation.[Inscription].[Inscription] i
INNER JOIN PachaDataFormation.[Stage].[Session] s ON i.SessionId = s.SessionId
LEFT JOIN PachaDataFormation.[Inscription].[InscriptionFacture] inf ON i.InscriptionId = inf.InscriptionId
LEFT JOIN PachaDataFormation.[Inscription].[Facture] fact ON inf.FactureCd = fact.FactureCd
LEFT JOIN PachaDataFormation.[Inscription].[Facture] f ON inf.FactureCd = f.FactureCd
WHERE i.ContactId IS NOT NULL  -- Nettoyage: exclure les inscriptions sans contact
GO

PRINT 'Vues Silver cr��es:'
PRINT '- vSilverContact: Contacts enrichis avec donn�es de soci�t�'
PRINT '- vSilverSession: Sessions enrichies avec donn�es de formateur et stage'
PRINT '- vSilverInscription: Inscriptions enrichies avec donn�es de facture'
PRINT ''
PRINT 'Couche Silver pr�te. Les donn�es sont nettoy�es et enrichies.'
GO


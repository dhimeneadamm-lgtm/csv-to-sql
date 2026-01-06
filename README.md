# CSV to SQL avec SSMS
## Objectif
Parcourir le cycle complet (ETL/ELT) pour construire un Modèle de Données Prêt pour le
Business (Gold Layer) à partir des sources brutes (Bronze Layer), en utilisant les
spécifications et meilleures pratiques présentées.
## Technologies utilisées
- SQL Server / SSMS
- SQL (Création des tables, Insert, Select, Update)
- CSV (fichiers d'exemple)

## Organisation du projet
- `data/` : fichiers CSV d'exemple
- `sql/` : scripts SQL pour création des tables et insertion des données
- `queries.sql` : requêtes pour tester et manipuler les données

## Comment utiliser
1. Ouvrir SQL Server Management Studio (SSMS)
2. Créer une nouvelle base de données
3. Exécuter `create_tables.sql` pour créer les tables
4. Insérer les données depuis CSV via `insert_data.sql` ou l'interface SSMS
5. Tester avec `queries.sql`

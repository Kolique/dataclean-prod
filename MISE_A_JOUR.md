# 🔧 MISE À JOUR DE LA BASE DE DONNÉES

## ⚠️ IMPORTANT : Exécutez ce SQL dans Supabase

Allez sur **Supabase → SQL Editor** et exécutez ce code :

```sql
-- Ajouter la colonne description à la table files
ALTER TABLE files 
ADD COLUMN IF NOT EXISTS description TEXT;

-- Ajouter une colonne pour lier un fichier à un dashboard
ALTER TABLE files 
ADD COLUMN IF NOT EXISTS dashboard_id UUID REFERENCES dashboards(id);

-- Créer un index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_files_dashboard_id ON files(dashboard_id);

-- Mettre à jour les policies pour permettre aux admins de voir les descriptions
DROP POLICY IF EXISTS "Admin can read all files" ON files;
CREATE POLICY "Admin can read all files" ON files
FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);
```

## ✅ VÉRIFICATION

Après avoir exécuté le SQL, vérifiez que tout fonctionne :

1. **Table Editor** → **files** → Vous devez voir les colonnes :
   - `id`
   - `user_id`
   - `filename`
   - `original_name`
   - `file_path`
   - `upload_date`
   - **`description`** ← NOUVEAU
   - **`dashboard_id`** ← NOUVEAU

2. Testez en uploadant un nouveau fichier avec une description

---

## 🎯 RÉSUMÉ DES MODIFICATIONS

### 1. **Dashboard Client (dashboard.html)** :
- ✅ Champ description obligatoire lors de l'upload
- ✅ Message d'avertissement sur fichiers importants
- ✅ Liste de tous les fichiers uploadés avec descriptions
- ✅ Plusieurs fichiers peuvent être uploadés

### 2. **Admin (admin.html)** :
- ✅ Alerte visible quand des fichiers sont en attente
- ✅ Liste de TOUS les fichiers par client
- ✅ Affichage des descriptions
- ✅ Bouton "Publier Dashboard" pour chaque fichier
- ✅ Statut "Traité" ou "En attente" pour chaque fichier
- ✅ Rafraîchissement automatique toutes les 30 secondes

### 3. **Base de données** :
- ✅ Colonne `description` dans `files`
- ✅ Colonne `dashboard_id` pour lier fichier → dashboard
- ✅ Index pour performances

---

## 🚀 PROCHAINES ÉTAPES

1. **Exécutez le SQL ci-dessus** dans Supabase
2. **Téléchargez les nouveaux fichiers** (dashboard.html + admin.html)
3. **Uploadez-les** sur votre hébergement (Vercel)
4. **Testez** :
   - Créez un nouveau compte client
   - Uploadez un fichier avec description
   - Connectez-vous en admin
   - Vérifiez que vous voyez le fichier en attente
   - Téléchargez-le et publiez un dashboard

---

**TOUT EST PRÊT ! 🎉**

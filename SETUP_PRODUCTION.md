# 🚀 GUIDE COMPLET - Data Clean Production

## ✨ CE QUE VOUS AVEZ

Un site **100% fonctionnel en production** avec :
- ✅ Design ultra-moderne (glassmorphisme + precision-grid)
- ✅ Base de données PostgreSQL cloud (Supabase)
- ✅ Stockage fichiers cloud (Supabase Storage)
- ✅ Authentification sécurisée
- ✅ Emails automatiques (Resend)
- ✅ Déploiement gratuit (Vercel)

---

## 🎯 ÉTAPE 1 : CRÉER VOTRE BASE DE DONNÉES SUPABASE

### 1. Créer un compte Supabase (GRATUIT)

1. Allez sur **https://supabase.com**
2. Cliquez sur **"Start your project"**
3. Connectez-vous avec GitHub (ou email)
4. Cliquez sur **"New Project"**
5. Remplissez :
   - **Name** : `dataclean-prod`
   - **Database Password** : Choisissez un mot de passe fort (NOTEZ-LE !)
   - **Region** : Europe (Frankfurt)
6. Cliquez sur **"Create new project"**
7. **Attendez 2 minutes** (création de la base de données)

---

### 2. Créer les tables de la base de données

Une fois votre projet créé :

1. Dans le menu de gauche, cliquez sur **"SQL Editor"**
2. Cliquez sur **"New Query"**
3. **Copiez-collez ce code SQL complet** :

```sql
-- Table des utilisateurs
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL,
    laverie_name TEXT NOT NULL,
    role TEXT DEFAULT 'client',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Table des fichiers uploadés par les clients
CREATE TABLE files (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) NOT NULL,
    filename TEXT NOT NULL,
    original_name TEXT NOT NULL,
    file_path TEXT NOT NULL,
    upload_date TIMESTAMP DEFAULT NOW()
);

-- Table des dashboards
CREATE TABLE dashboards (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) NOT NULL,
    file_id UUID REFERENCES files(id),
    period TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    dashboard_path TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    published_at TIMESTAMP,
    notified BOOLEAN DEFAULT FALSE
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE files ENABLE ROW LEVEL SECURITY;
ALTER TABLE dashboards ENABLE ROW LEVEL SECURITY;

-- Policies pour users
CREATE POLICY "Users can read own data" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own data" ON users FOR UPDATE USING (auth.uid() = id);

-- Policies pour files
CREATE POLICY "Users can read own files" ON files FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own files" ON files FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policies pour dashboards
CREATE POLICY "Users can read own dashboards" ON dashboards FOR SELECT USING (auth.uid() = user_id);

-- Admin peut tout voir
CREATE POLICY "Admin can read all" ON users FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admin can read all files" ON files FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admin can read all dashboards" ON dashboards FOR SELECT USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admin can insert dashboards" ON dashboards FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admin can update dashboards" ON dashboards FOR UPDATE USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);
```

4. Cliquez sur **"Run"** (en bas à droite)
5. ✅ Vous devriez voir : **"Success. No rows returned"**

---

### 3. Créer votre compte admin

1. Toujours dans **SQL Editor**, nouvelle query :

```sql
-- D'abord, créez votre compte sur le site (signup.html)
-- Puis revenez ici et remplacez 'votre@email.com' par votre vrai email :

UPDATE users 
SET role = 'admin' 
WHERE email = 'costisork@gmail.com';
```

2. **Mais AVANT** : Allez d'abord sur votre site et créez votre compte via signup.html
3. **PUIS** revenez exécuter cette requête

---

### 4. Créer les buckets de stockage

1. Dans le menu de gauche, cliquez sur **"Storage"**
2. Cliquez sur **"Create a new bucket"**
3. Créez 2 buckets :

**Bucket 1 : Fichiers Excel**
- Name : `client-uploads`
- Public : ❌ Non (privé)
- Cliquez **"Create bucket"**

**Bucket 2 : Dashboards PDF**
- Name : `dashboards`
- Public : ❌ Non (privé)
- Cliquez **"Create bucket"**

---

### 5. Configurer les policies de storage

1. Pour chaque bucket, cliquez sur les **3 points** → **"Edit policies"**

**Pour `client-uploads`** :
- Policy name : `Users can upload own files`
- Target roles : `authenticated`
- Policy definition :
```sql
(bucket_id = 'client-uploads' AND auth.uid()::text = (storage.foldername(name))[1])
```

**Pour `dashboards`** :
- Policy name : `Users can read own dashboards`
- Target roles : `authenticated`
- Policy definition :
```sql
(bucket_id = 'dashboards' AND auth.uid()::text = (storage.foldername(name))[1])
```

---

### 6. Récupérer vos clés API

1. Dans le menu de gauche, cliquez sur **"Project Settings"** (icône engrenage)
2. Cliquez sur **"API"**
3. **COPIEZ ces 2 valeurs** :
   - **Project URL** : `https://xxxxxxxxx.supabase.co`
   - **anon public** : `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (longue clé)

---

## 🎯 ÉTAPE 2 : CONFIGURER LE SITE

### 1. Remplacer les clés Supabase

Dans **TOUS** les fichiers HTML (login.html, signup.html, dashboard.html, admin.html), remplacez :

```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

Par vos vraies clés :

```javascript
const SUPABASE_URL = 'https://xxxxxxxxx.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

---

## 🎯 ÉTAPE 3 : CONFIGURER LES EMAILS (Resend)

### 1. Créer un compte Resend

1. Allez sur **https://resend.com**
2. Cliquez sur **"Sign up"**
3. Créez votre compte (gratuit 3000 emails/mois)
4. Dans le dashboard, cliquez sur **"API Keys"**
5. Cliquez sur **"Create API Key"**
6. Name : `dataclean-prod`
7. **COPIEZ LA CLÉ** : `re_xxxxxxxxxxxxx`

### 2. Ajouter votre domaine (optionnel mais recommandé)

1. Dans Resend, allez dans **"Domains"**
2. Cliquez sur **"Add Domain"**
3. Entrez votre domaine (ex: `dataclean.fr`)
4. Suivez les instructions DNS
5. ✅ Une fois vérifié, vos emails partiront de `noreply@dataclean.fr`

---

## 🎯 ÉTAPE 4 : DÉPLOYER SUR VERCEL (Gratuit)

### 1. Préparer le projet

1. Téléchargez tout le dossier `dataclean-production`
2. Créez un compte GitHub si vous n'en avez pas
3. Créez un nouveau repository **privé** : `dataclean-prod`
4. Uploadez tous les fichiers sur GitHub

### 2. Déployer sur Vercel

1. Allez sur **https://vercel.com**
2. Cliquez sur **"Sign Up"** et connectez-vous avec GitHub
3. Cliquez sur **"New Project"**
4. Sélectionnez votre repo `dataclean-prod`
5. Cliquez sur **"Deploy"**
6. **Attendez 2 minutes**

✅ **VOTRE SITE EST EN LIGNE !**

URL : `https://dataclean-prod.vercel.app`

---

### 3. Configurer un domaine personnalisé (optionnel)

1. Achetez un domaine (ex: `dataclean.fr` sur OVH, Gandi...)
2. Dans Vercel, allez dans **Settings** → **Domains**
3. Ajoutez votre domaine
4. Configurez les DNS selon les instructions
5. ✅ Votre site sera sur `https://dataclean.fr`

---

## 🎯 ÉTAPE 5 : TESTER LE SITE

### 1. Créer votre compte admin

1. Allez sur votre URL Vercel
2. Cliquez sur **"Essai gratuit"**
3. Remplissez avec **costisork@gmail.com**
4. Validez

### 2. Passer en mode admin

1. Retournez sur Supabase → SQL Editor
2. Exécutez :
```sql
UPDATE users SET role = 'admin' WHERE email = 'costisork@gmail.com';
```

### 3. Tester le workflow complet

1. Créez un compte client test (navigation privée)
2. Uploadez un fichier Excel
3. Connectez-vous en admin
4. Téléchargez le fichier
5. Uploadez un dashboard PDF
6. Notifiez le client
7. Vérifiez que le client reçoit l'email

---

## 📊 STRUCTURE DE LA BASE DE DONNÉES

```
users
├── id (UUID, lié à auth.users)
├── email
├── laverie_name
├── role ('client' ou 'admin')
└── created_at

files
├── id (UUID)
├── user_id (FK → users.id)
├── filename
├── original_name
├── file_path (chemin Supabase Storage)
└── upload_date

dashboards
├── id (UUID)
├── user_id (FK → users.id)
├── file_id (FK → files.id)
├── period (ex: "Janvier 2026")
├── status ('pending' ou 'published')
├── dashboard_path (chemin PDF dans Storage)
├── created_at
├── published_at
└── notified (boolean)
```

---

## 🔒 SÉCURITÉ

✅ **Authentification** : JWT via Supabase Auth
✅ **RLS** : Row Level Security activé
✅ **HTTPS** : Automatique avec Vercel
✅ **Passwords** : Hashés par Supabase
✅ **Storage** : Fichiers privés par utilisateur

---

## 💰 COÛTS

| Service | Plan Gratuit | Limite |
|---------|--------------|--------|
| **Supabase** | 500 MB base de données | 1 GB storage |
| **Vercel** | Illimité | 100 GB bandwidth/mois |
| **Resend** | 3000 emails/mois | Suffisant pour 100 clients |

**Total : 0 € jusqu'à ~50 clients !**

---

## 🎉 FÉLICITATIONS !

Votre site est **100% opérationnel en production** !

**URL de test** : Votre URL Vercel
**Admin** : costisork@gmail.com
**Dashboard admin** : /admin.html

**Prochaines étapes** :
1. ✅ Tester avec des clients fictifs
2. ✅ Affiner le template de dashboard
3. ✅ Lancer l'acquisition client
4. 💰 **FAIRE DU BUSINESS !**

---

## 🆘 BESOIN D'AIDE ?

- **Supabase** : https://supabase.com/docs
- **Vercel** : https://vercel.com/docs
- **Resend** : https://resend.com/docs
- **Email** : costisork@gmail.com

**VOTRE BUSINESS EST PRÊT ! 🚀💰**

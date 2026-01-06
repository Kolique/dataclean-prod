# 💳 GUIDE COMPLET - INTÉGRATION STRIPE + VERCEL

## 🎯 CE QUE VOUS ALLEZ AVOIR :

- ✅ Paiement réel avec carte bancaire
- ✅ Redirection vers Stripe sécurisée
- ✅ Webhook pour confirmation automatique
- ✅ Abonnement créé automatiquement dans Supabase
- ✅ Page de succès après paiement

---

## 📋 ÉTAPE 1 : CONFIGURATION STRIPE (10 min)

### **A. Créer compte Stripe**

1. Allez sur **https://stripe.com**
2. **Sign up** (gratuit)
3. Complétez votre profil

### **B. Mode Test**

1. En haut à droite : **Activez "Test Mode"** (toggle switch)
2. ⚠️ Vous allez tester avec des fausses cartes d'abord

### **C. Récupérer les clés API**

1. **Developers** → **API keys**
2. Vous voyez :
   - **Publishable key** : `pk_test_...` → Pour le frontend
   - **Secret key** : `sk_test_...` → Pour le backend ⚠️ SECRÈTE

3. **Copiez les deux** quelque part

### **D. Configurer le Webhook**

1. **Developers** → **Webhooks** → **Add endpoint**
2. **Endpoint URL** : `https://VOTRE-PROJET.vercel.app/api/stripe-webhook`
   (vous mettrez l'URL après déploiement Vercel)
3. **Events to send** : Sélectionnez `checkout.session.completed`
4. **Add endpoint**
5. **Copiez le Webhook signing secret** : `whsec_...`

---

## 🚀 ÉTAPE 2 : DÉPLOYER SUR VERCEL (15 min)

### **A. Préparer le projet**

1. Créez un dossier `dataclean-backend`
2. Mettez dedans :
   - `api/create-checkout.js`
   - `api/stripe-webhook.js`
   - `package.json`
   - `dashboard.html`
   - `success.html`
   - Tous les autres fichiers HTML

### **B. Créer compte Vercel**

1. Allez sur **https://vercel.com**
2. **Sign up** avec GitHub (gratuit)

### **C. Importer le projet**

#### **Option 1 : Via GitHub (RECOMMANDÉ)**

1. Créez un repo GitHub avec votre projet
2. Sur Vercel : **New Project** → Importer depuis GitHub
3. Sélectionnez votre repo

#### **Option 2 : Via CLI**

```bash
# Installer Vercel CLI
npm install -g vercel

# Dans votre dossier projet
cd dataclean-backend

# Déployer
vercel
```

### **D. Configurer les variables d'environnement**

Sur Vercel, allez dans **Settings** → **Environment Variables** :

| Variable | Valeur | Où la trouver |
|----------|--------|---------------|
| `STRIPE_SECRET_KEY` | `sk_test_...` | Stripe → API keys |
| `STRIPE_WEBHOOK_SECRET` | `whsec_...` | Stripe → Webhooks |
| `SUPABASE_URL` | `https://xxx.supabase.co` | Supabase → Settings → API |
| `SUPABASE_SERVICE_KEY` | `eyJhbG...` | Supabase → Settings → API → service_role key ⚠️ |
| `FRONTEND_URL` | `https://votre-site.com` | URL de votre site |

⚠️ **IMPORTANT** : Pour Supabase, utilisez la **service_role key**, pas l'anon key !

### **E. Déployer**

1. Cliquez **Deploy**
2. Attendez 2 minutes
3. Vous obtenez une URL : `https://votre-projet.vercel.app`

---

## 🔧 ÉTAPE 3 : CONFIGURER LE FRONTEND (5 min)

Dans `dashboard.html`, mettez à jour :

```javascript
const SUPABASE_URL = 'https://xkrjtaqphzuwjwnsibzf.supabase.co';
const SUPABASE_KEY = 'eyJh...'; // Anon key
const STRIPE_PUBLISHABLE_KEY = 'pk_test_...'; // De Stripe
const BACKEND_URL = 'https://votre-projet.vercel.app'; // URL Vercel
```

Dans `success.html`, même chose :

```javascript
const SUPABASE_URL = 'https://xkrjtaqphzuwjwnsibzf.supabase.co';
const SUPABASE_KEY = 'eyJh...';
```

---

## 🔄 ÉTAPE 4 : METTRE À JOUR LE WEBHOOK STRIPE

1. Retournez sur **Stripe → Webhooks**
2. **Éditez** votre webhook
3. **Endpoint URL** : `https://votre-projet.vercel.app/api/stripe-webhook`
4. **Update endpoint**

---

## 🧪 ÉTAPE 5 : TESTER EN MODE TEST (10 min)

### **A. Cartes de test Stripe**

Utilisez ces numéros de carte :

| Carte | Numéro | Résultat |
|-------|--------|----------|
| ✅ Succès | `4242 4242 4242 4242` | Paiement réussi |
| ❌ Décliné | `4000 0000 0000 0002` | Carte déclinée |
| ⏳ 3D Secure | `4000 0027 6000 3184` | Authentification requise |

- **Date d'expiration** : N'importe quelle date future (ex: 12/25)
- **CVC** : N'importe quel 3 chiffres (ex: 123)
- **Code postal** : N'importe quoi (ex: 75001)

### **B. Test complet**

1. Connectez-vous en tant que client (qui a déjà reçu 1 dashboard)
2. Essayez d'uploader → **Bloqué**
3. Cliquez **"Payer 99€"**
4. Vous êtes redirigé vers **Stripe Checkout**
5. Entrez la carte `4242 4242 4242 4242`
6. **Pay**
7. Vous êtes redirigé vers **success.html**
8. Retournez sur **dashboard.html**
9. **Vous pouvez uploader !** ✅

### **C. Vérifier dans Stripe**

1. **Stripe → Payments**
2. Vous devez voir le paiement de 99€
3. Status : **Succeeded**

### **D. Vérifier dans Supabase**

```sql
SELECT * FROM subscriptions 
WHERE user_id = 'UUID_DU_CLIENT' 
ORDER BY created_at DESC;
```

Vous devez voir :
- `month` : "2026-02"
- `status` : "available"
- `payment_method` : "stripe"
- `stripe_payment_id` : "pi_..."

---

## 🎬 ÉTAPE 6 : PASSER EN MODE LIVE (PRODUCTION)

Quand vous êtes prêt pour de VRAIS paiements :

### **A. Activer votre compte Stripe**

1. **Stripe → Activate your account**
2. Fournissez vos infos d'entreprise
3. Infos bancaires (pour recevoir l'argent)
4. Validation peut prendre 24-48h

### **B. Récupérer les clés LIVE**

1. **Désactivez "Test Mode"** (toggle)
2. **Developers → API keys**
3. Nouvelles clés :
   - `pk_live_...`
   - `sk_live_...`

### **C. Créer nouveau webhook LIVE**

1. **Developers → Webhooks** → **Add endpoint**
2. URL : `https://votre-projet.vercel.app/api/stripe-webhook`
3. Events : `checkout.session.completed`
4. Nouveau secret : `whsec_...` (différent du test)

### **D. Mettre à jour Vercel**

Dans **Vercel → Settings → Environment Variables** :

- `STRIPE_SECRET_KEY` → Remplacez par `sk_live_...`
- `STRIPE_WEBHOOK_SECRET` → Remplacez par le nouveau `whsec_...`

### **E. Mettre à jour le frontend**

Dans `dashboard.html` :

```javascript
const STRIPE_PUBLISHABLE_KEY = 'pk_live_...'; // Clé LIVE
```

### **F. Redéployer**

```bash
vercel --prod
```

---

## 💰 COÛTS STRIPE

- **Frais Stripe** : 1,4% + 0,25€ par transaction
- **Exemple** : 99€ → Vous recevez ~97,40€
- **Pas d'abonnement mensuel**

---

## 🔍 DEBUG

### **Webhook ne fonctionne pas**

```bash
# Tester localement avec Stripe CLI
stripe listen --forward-to localhost:3000/api/stripe-webhook

# Déclencher un événement test
stripe trigger checkout.session.completed
```

### **Vérifier les logs Vercel**

1. Vercel → Votre projet → **Logs**
2. Regardez les erreurs

### **Vérifier les webhooks Stripe**

1. Stripe → Webhooks → Cliquez sur votre webhook
2. Onglet **Events** : voir tous les événements envoyés

---

## 📋 CHECKLIST FINALE

### **Mode Test :**
- [ ] Compte Stripe créé
- [ ] Mode Test activé
- [ ] Clés API copiées (pk_test + sk_test)
- [ ] Webhook créé avec signing secret
- [ ] Projet déployé sur Vercel
- [ ] Variables d'environnement configurées
- [ ] Frontend mis à jour avec les clés
- [ ] Test de paiement avec 4242...
- [ ] Subscription créée dans Supabase

### **Mode Live :**
- [ ] Compte Stripe activé
- [ ] Clés LIVE copiées
- [ ] Webhook LIVE créé
- [ ] Vercel mis à jour
- [ ] Frontend mis à jour
- [ ] Test avec vraie carte

---

## 🆘 AIDE

**Problème de CORS ?**
→ Vérifiez que `Access-Control-Allow-Origin` est dans l'API

**Webhook ne reçoit rien ?**
→ Vérifiez l'URL du webhook dans Stripe

**Paiement OK mais pas dans Supabase ?**
→ Regardez les logs Vercel

---

**TOUT EST PRÊT ! TESTEZ MAINTENANT ! 🚀💳**

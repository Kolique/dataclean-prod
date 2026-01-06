# 🚀 GUIDE COMPLET - SYSTÈME D'ABONNEMENT

## 📋 CE QUI A ÉTÉ AJOUTÉ

### ✅ CÔTÉ CLIENT (dashboard.html) :
- Sélecteur de mois lors de l'upload (dropdown)
- Fichiers groupés par mois (accordéon cliquable)
- Bouton 🗑️ Supprimer pour chaque fichier
- Section "Mon abonnement" avec statut
- Blocage upload si impayé + message d'avertissement
- Bouton "Payer avec Stripe" (99€)

### ✅ CÔTÉ ADMIN (admin.html) :
- Badge sur chaque client (🆓 Gratuit / 💳 Payé / ⚠️ Impayé)
- Fichiers groupés par mois (cliquables)
- Modal par mois avec tous les fichiers
- Upload 1 dashboard PDF par mois
- Statistique "Mois en attente"

### ✅ BASE DE DONNÉES :
- Table `subscriptions` (gestion abonnements)
- Colonne `month` dans `files` (format: "2026-01")
- Trigger automatique pour créer 1er mois gratuit

---

## 🔧 INSTALLATION - ÉTAPE PAR ÉTAPE

### **ÉTAPE 1 : EXÉCUTER LE SQL**

1. Allez sur **Supabase → SQL Editor**
2. Ouvrez le fichier **`MIGRATION_ABONNEMENT.sql`**
3. **Copiez TOUT le contenu**
4. Collez dans SQL Editor
5. Cliquez sur **"Run"**
6. ✅ Vous devriez voir : **"Success"**

**Vérification :**
```sql
-- Vérifier que la table existe
SELECT * FROM subscriptions LIMIT 5;

-- Vérifier que vos clients ont leur mois gratuit
SELECT 
    u.laverie_name,
    s.month,
    s.status
FROM subscriptions s
JOIN users u ON s.user_id = u.id;
```

---

### **ÉTAPE 2 : CONFIGURER STRIPE**

#### **A. Créer un compte Stripe**

1. Allez sur **https://stripe.com**
2. Cliquez sur **"Sign up"**
3. Créez votre compte (gratuit)
4. Complétez votre profil

#### **B. Activer le mode Test**

Dans le dashboard Stripe, en haut à droite, vérifiez que vous êtes en **"Test Mode"** (toggle switch).

#### **C. Récupérer vos clés API**

1. Dans Stripe, allez dans **"Developers"** → **"API keys"**
2. Vous verrez 2 clés :
   - **Publishable key** (commence par `pk_test_...`)
   - **Secret key** (commence par `sk_test_...`) - ⚠️ Ne jamais la partager !

3. **Copiez la Publishable key**

#### **D. Configurer dans le code**

Dans **`dashboard.html`**, remplacez :

```javascript
const STRIPE_PUBLISHABLE_KEY = 'YOUR_STRIPE_PUBLISHABLE_KEY';
```

Par :

```javascript
const STRIPE_PUBLISHABLE_KEY = 'pk_test_51ABC...'; // Votre vraie clé
```

---

### **ÉTAPE 3 : CRÉER UN PRODUIT STRIPE**

#### **A. Créer le produit "Abonnement Data Clean"**

1. Dans Stripe, allez dans **"Products"** → **"Add product"**
2. Remplissez :
   - **Name** : `Abonnement Data Clean`
   - **Description** : `Accès mensuel au service de dashboards`
   - **Pricing** :
     - Type : **One-time**
     - Price : **99.00 EUR**
   - **Tax behavior** : **Inclusive**
3. Cliquez sur **"Save product"**

#### **B. Récupérer le Price ID**

Une fois créé, copiez le **Price ID** (commence par `price_...`)

---

### **ÉTAPE 4 : CRÉER UNE FONCTION STRIPE CHECKOUT**

#### **Option A : Checkout hébergé Stripe (FACILE)**

Dans `dashboard.html`, modifiez la fonction `paySubscription` :

```javascript
window.paySubscription = async function() {
    if (!confirm('Payer 99€ pour le mois en cours ?')) return;
    
    try {
        const selectedMonth = monthSelect.value;
        
        // Créer une session Stripe Checkout
        const response = await fetch('https://VOTRE-URL-BACKEND/create-checkout-session', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                userId: user.id,
                month: selectedMonth,
                email: userData.email
            })
        });

        const { sessionId } = await response.json();
        
        // Rediriger vers Stripe
        const { error } = await stripe.redirectToCheckout({ sessionId });
        
        if (error) throw error;
        
    } catch (error) {
        alert('Erreur : ' + error.message);
    }
}
```

#### **Option B : Version simplifiée (SIMULATION)**

Pour tester sans backend complet, gardez la version actuelle qui simule le paiement :

```javascript
window.paySubscription = async function() {
    if (!confirm('Payer 99€ pour le mois en cours ?')) return;
    
    try {
        const selectedMonth = monthSelect.value;
        
        // SIMULATION - En prod, utilisez Stripe Checkout
        alert('Redirection vers Stripe...');
        
        // Marquer comme payé dans la base
        const { error } = await supabase.from('subscriptions').upsert({
            user_id: user.id,
            month: selectedMonth,
            status: 'paid',
            payment_method: 'stripe',
            paid_at: new Date().toISOString(),
            amount: 99.00
        });

        if (error) throw error;
        
        alert('✅ Paiement effectué !');
        checkSubscriptionStatus();
        
    } catch (error) {
        alert('Erreur : ' + error.message);
    }
}
```

---

### **ÉTAPE 5 : REMPLACER LES FICHIERS**

1. **Uploadez** les nouveaux fichiers sur votre hébergement :
   - `dashboard.html` (nouveau)
   - `admin.html` (nouveau)

2. **N'oubliez pas de mettre vos clés** dans TOUS les fichiers :
   - Supabase URL
   - Supabase Key
   - Stripe Publishable Key

3. **Rafraîchissez** votre site (Ctrl + F5)

---

## 🧪 TESTER LE SYSTÈME

### **Test 1 : Nouveau client**

1. Créez un nouveau compte client
2. Vérifiez qu'il a le badge "🆓 Gratuit"
3. Uploadez un fichier pour le mois actuel
4. Vérifiez que ça fonctionne ✅

### **Test 2 : Blocage upload**

1. En SQL, passez le mois suivant :
```sql
UPDATE subscriptions 
SET month = TO_CHAR(NOW() + INTERVAL '1 month', 'YYYY-MM')
WHERE user_id = 'ID_DU_CLIENT';
```

2. Le client ne devrait PLUS pouvoir uploader
3. Message : "⚠️ Abonnement requis"
4. Bouton "Payer 99€" visible

### **Test 3 : Admin voit les mois**

1. Connectez-vous en admin
2. Cliquez sur un client
3. Vous devez voir les fichiers groupés par mois
4. Cliquez sur un mois
5. Modal avec tous les fichiers
6. Téléchargez + Upload dashboard PDF

---

## 💳 PAIEMENTS RÉELS - PRODUCTION

Pour activer les **vrais paiements** :

### **1. Passer en mode Live**

Dans Stripe :
- Toggle **"Test Mode"** → **"Live Mode"**
- Récupérez les nouvelles clés (commencent par `pk_live_...`)
- Remplacez dans le code

### **2. Créer un webhook**

Pour être notifié quand un paiement réussit :

1. Stripe → **"Developers"** → **"Webhooks"**
2. **"Add endpoint"**
3. URL : `https://votre-site.com/webhook/stripe`
4. Événements : `checkout.session.completed`
5. Créez une fonction qui reçoit cet événement et met à jour `subscriptions`

---

## 🎯 WORKFLOW COMPLET

```
MOIS 1 (Janvier) :
├── Client créé → Abonnement gratuit auto-créé
├── Client upload fichiers pour Janvier
├── Admin télécharge + crée dashboard
└── Client reçoit son dashboard ✅

MOIS 2 (Février) :
├── Client essaie d'uploader → ❌ BLOQUÉ
├── Message : "Veuillez payer votre abonnement"
├── Client clique "Payer 99€"
├── Redirection Stripe → Paiement
├── Webhook → Abonnement "paid" créé
├── Client peut uploader pour Février ✅
└── Cycle se répète chaque mois
```

---

## 📊 GESTION MANUELLE (ADMIN)

Si un client paie par virement bancaire :

```sql
-- Créer/Mettre à jour manuellement son abonnement
INSERT INTO subscriptions (user_id, month, status, payment_method, paid_at, amount)
VALUES (
    'UUID_DU_CLIENT',
    '2026-02', -- Mois concerné
    'paid',
    'manual',
    NOW(),
    99.00
)
ON CONFLICT (user_id, month) 
DO UPDATE SET 
    status = 'paid',
    payment_method = 'manual',
    paid_at = NOW();
```

---

## 🆘 DÉPANNAGE

### Problème : Client ne voit pas le sélecteur de mois
→ Vérifiez que `dashboard.html` est bien remplacé

### Problème : Admin ne voit pas les fichiers par mois
→ Exécutez : `ALTER TABLE files ADD COLUMN month TEXT;`

### Problème : Erreur "table subscriptions n'existe pas"
→ Ré-exécutez le SQL de migration

### Problème : Stripe ne se charge pas
→ Vérifiez que la clé `pk_test_...` est correcte

---

## ✅ CHECKLIST FINALE

- [ ] SQL exécuté (table subscriptions créée)
- [ ] Colonne `month` ajoutée à `files`
- [ ] Clés Supabase remplacées
- [ ] Clé Stripe ajoutée
- [ ] `dashboard.html` uploadé
- [ ] `admin.html` uploadé
- [ ] Test : nouveau client a mois gratuit
- [ ] Test : fichiers groupés par mois
- [ ] Test : blocage upload fonctionne
- [ ] Test : admin voit badges statut

---

**TOUT EST PRÊT ! 🎉**

Questions ? Besoin d'aide pour Stripe ? Dites-moi ! 😊

# 🎯 GUIDE FINAL - PAIEMENT PAR DASHBOARD

## ✅ LA VRAIE LOGIQUE (CORRIGÉE) :

```
❌ ANCIEN SYSTÈME :
- 1er MOIS gratuit
- 2ème mois = payer

✅ NOUVEAU SYSTÈME :
- 1er DASHBOARD gratuit
- Chaque dashboard suivant = 99€
- 1 dashboard = 1 mois spécifique
```

---

## 📊 WORKFLOW COMPLET

### **SCÉNARIO COMPLET :**

```
JANVIER (1er dashboard) :
1. Client s'inscrit
2. Badge : 🆓 "1er gratuit"
3. Client upload fichiers pour JANVIER
4. Admin télécharge + crée dashboard
5. Admin publie dashboard JANVIER
   → Trigger SQL marque : {month: "2026-01", status: "completed", is_first_free: TRUE}
6. Client reçoit son 1er dashboard ✅
7. Badge client devient : 💳 "1 dashboard reçu"

FÉVRIER (2ème dashboard) :
1. Client veut uploader pour FÉVRIER → ❌ BLOQUÉ
2. Message : "Premier dashboard gratuit utilisé. Payez 99€ pour Février"
3. Client paie 99€
   → Créé : {month: "2026-02", status: "available", paid_at: NOW()}
4. Client peut uploader pour FÉVRIER ✅
5. Admin publie dashboard FÉVRIER
   → Update : {status: "completed"}
6. Client reçoit dashboard février
7. Badge : 💳 "2 dashboards reçus"

MARS (3ème dashboard) :
1. Client veut uploader pour MARS → ❌ BLOQUÉ
2. Doit payer 99€ pour MARS
3. Et ainsi de suite...
```

---

## 🔑 RÈGLES CLÉS

| Règle | Explication |
|-------|-------------|
| **1 dashboard = 1 mois** | Un paiement permet d'uploader pour 1 mois spécifique uniquement |
| **1er dashboard gratuit** | Le tout premier dashboard, peu importe le mois choisi |
| **Dashboard publié = Mois consommé** | Dès que l'admin publie, le mois passe en "completed" |
| **Paiement manuel OK** | Admin peut marquer comme payé en SQL |
| **Stripe optionnel** | Fonctionne sans Stripe (paiement simulé) |

---

## 🔧 INSTALLATION

### **ÉTAPE 1 : EXÉCUTER LE SQL (5 min)**

1. Ouvrez **`MIGRATION_PAY_PER_DASHBOARD.sql`**
2. Copiez **TOUT** le contenu
3. Supabase → SQL Editor → Coller → Run
4. ✅ Vérifiez : `SELECT * FROM subscriptions;`

### **ÉTAPE 2 : REMPLACER LES FICHIERS (2 min)**

1. Uploadez `dashboard.html` (nouveau)
2. Uploadez `admin.html` (nouveau)
3. **Mettez vos clés Supabase** dans les 2 fichiers

### **ÉTAPE 3 : TESTER (10 min)**

#### **Test 1 : Premier dashboard gratuit**
```
1. Créer un compte client
2. Voir badge : 🆓 "1er gratuit"
3. Upload fichiers pour Janvier
4. Admin : voir fichiers Janvier
5. Admin : publier dashboard Janvier
6. Client : badge devient 💳 "1 dashboard"
7. Client : voir dashboard Janvier ✅
```

#### **Test 2 : Blocage pour 2ème mois**
```
1. Client veut uploader pour Février
2. ❌ BLOQUÉ : "Paiement requis"
3. Bouton "Payer 99€" visible
```

#### **Test 3 : Payer et débloquer**
```
1. Client clique "Payer 99€"
2. (Simulation pour test)
3. Client peut uploader pour Février ✅
```

---

## 💳 MARQUER UN MOIS COMME PAYÉ (SQL)

Si un client paie par virement :

```sql
-- 1. Trouver l'ID du client
SELECT id, email FROM users WHERE email = 'client@example.com';

-- 2. Créer l'abonnement pour le mois
INSERT INTO subscriptions (user_id, month, status, payment_method, paid_at, amount, is_first_free)
VALUES (
    'UUID_DU_CLIENT',
    '2026-02',           -- Mois concerné
    'available',         -- Peut uploader
    'manual',
    NOW(),
    99.00,
    FALSE                -- Pas le 1er gratuit
)
ON CONFLICT (user_id, month) 
DO UPDATE SET 
    status = 'available',
    payment_method = 'manual',
    paid_at = NOW();
```

---

## 📊 VÉRIFICATIONS UTILES

### **Voir tous les abonnements d'un client**
```sql
SELECT 
    s.month,
    s.status,
    s.is_first_free,
    s.payment_method,
    s.paid_at
FROM subscriptions s
JOIN users u ON s.user_id = u.id
WHERE u.email = 'client@example.com'
ORDER BY s.month DESC;
```

### **Voir les clients qui ont utilisé leur 1er gratuit**
```sql
SELECT 
    u.laverie_name,
    u.email,
    COUNT(CASE WHEN s.status = 'completed' THEN 1 END) as dashboards_recus
FROM users u
LEFT JOIN subscriptions s ON s.user_id = u.id
WHERE u.role = 'client'
GROUP BY u.id, u.laverie_name, u.email
ORDER BY dashboards_recus DESC;
```

### **Voir les mois en attente de traitement**
```sql
SELECT 
    u.laverie_name,
    f.month,
    COUNT(f.id) as nb_fichiers
FROM files f
JOIN users u ON f.user_id = u.id
WHERE f.dashboard_id IS NULL AND f.month IS NOT NULL
GROUP BY u.laverie_name, f.month
ORDER BY u.laverie_name, f.month;
```

---

## 🎨 BADGES ADMIN

| Badge | Signification | Couleur |
|-------|---------------|---------|
| 🆓 1er gratuit | N'a jamais reçu de dashboard | Vert |
| 💳 1 dashboard | A reçu 1 dashboard | Bleu |
| 💳 2 dashboards | A reçu 2 dashboards | Bleu |
| 💳 X dashboards | A reçu X dashboards | Bleu |

---

## 🚀 INTÉGRER STRIPE (OPTIONNEL)

Pour l'instant, le paiement est **simulé**. 

Pour activer Stripe :
1. Créer compte sur stripe.com
2. Mode Test
3. Créer produit "Dashboard mensuel" à 99€
4. Récupérer clé `pk_test_...`
5. Mettre dans `dashboard.html`
6. Modifier fonction `payForMonth()` (doc Stripe Checkout)

---

## ⚠️ TRIGGER AUTOMATIQUE

Le trigger SQL s'occupe de **TOUT** automatiquement :

```sql
Quand admin publie dashboard :
1. Récupère le mois des fichiers liés
2. Vérifie si c'est le 1er dashboard du client
3. Crée/met à jour l'entrée subscriptions
4. Marque status = "completed"
5. Marque is_first_free = TRUE si c'est le 1er
```

**Vous n'avez RIEN à faire manuellement ! 🎉**

---

## 📋 CHECKLIST FINALE

- [ ] SQL exécuté (table subscriptions créée)
- [ ] Trigger créé (mark_month_completed)
- [ ] Functions créées (has_received_first_dashboard, can_upload_for_month)
- [ ] dashboard.html uploadé avec clés
- [ ] admin.html uploadé avec clés
- [ ] Test : nouveau client → badge "1er gratuit"
- [ ] Test : upload fichier → OK
- [ ] Test : admin publie → client passe en "1 dashboard"
- [ ] Test : client essaie 2ème mois → bloqué
- [ ] Test : paiement → débloqué

---

## 🎯 RÉSUMÉ EN 1 PHRASE

**"Chaque client a 1 dashboard gratuit, puis paie 99€ par mois pour chaque nouveau dashboard."**

---

**TOUT EST AUTOMATIQUE ! INSTALLEZ ET TESTEZ ! 🚀**

Questions ? Dites-moi ! 😊

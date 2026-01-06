# 🔧 MIGRATION SQL - SYSTÈME PAR DASHBOARD

## ⚡ NOUVELLE LOGIQUE :
- **1er dashboard = GRATUIT** (peu importe le mois)
- **Après le 1er dashboard = Payer 99€ PAR MOIS**
- **1 paiement = 1 mois spécifique**

---

## 📝 EXÉCUTEZ CE SQL DANS SUPABASE

```sql
-- ============================================
-- ÉTAPE 1 : AJOUTER COLONNES À FILES
-- ============================================
ALTER TABLE files ADD COLUMN IF NOT EXISTS month TEXT; -- Format: "2026-01"

-- ============================================
-- ÉTAPE 2 : CRÉER TABLE SUBSCRIPTIONS
-- ============================================
DROP TABLE IF EXISTS subscriptions CASCADE;

CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    month TEXT NOT NULL, -- Format: "2026-01"
    status TEXT DEFAULT 'available', -- "available" (peut uploader) ou "completed" (dashboard reçu)
    is_first_free BOOLEAN DEFAULT FALSE,
    paid_at TIMESTAMP,
    amount DECIMAL DEFAULT 99.00,
    payment_method TEXT, -- "stripe", "manual", "free"
    stripe_payment_id TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, month)
);

-- Index pour performances
CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_month ON subscriptions(month);
CREATE INDEX idx_files_month ON files(month);

-- ============================================
-- ÉTAPE 3 : FUNCTION - Vérifier si 1er dashboard gratuit utilisé
-- ============================================
CREATE OR REPLACE FUNCTION has_received_first_dashboard(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM subscriptions 
        WHERE user_id = p_user_id 
        AND status = 'completed' 
        AND is_first_free = TRUE
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ÉTAPE 4 : FUNCTION - Vérifier si peut uploader pour un mois
-- ============================================
CREATE OR REPLACE FUNCTION can_upload_for_month(p_user_id UUID, p_month TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    has_first_free BOOLEAN;
    subscription_exists BOOLEAN;
    sub_status TEXT;
BEGIN
    -- Vérifier si déjà reçu le 1er dashboard gratuit
    has_first_free := has_received_first_dashboard(p_user_id);
    
    -- Si pas encore reçu le 1er dashboard gratuit → OK
    IF has_first_free = FALSE THEN
        RETURN TRUE;
    END IF;
    
    -- Sinon, vérifier s'il a payé pour ce mois spécifique
    SELECT EXISTS(
        SELECT 1 FROM subscriptions 
        WHERE user_id = p_user_id AND month = p_month
    ) INTO subscription_exists;
    
    -- Pas d'abonnement pour ce mois → NON
    IF subscription_exists = FALSE THEN
        RETURN FALSE;
    END IF;
    
    -- Vérifier le statut
    SELECT status INTO sub_status
    FROM subscriptions
    WHERE user_id = p_user_id AND month = p_month;
    
    -- Peut uploader seulement si "available"
    RETURN (sub_status = 'available');
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ÉTAPE 5 : POLICIES POUR SUBSCRIPTIONS
-- ============================================
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own subscriptions" ON subscriptions;
DROP POLICY IF EXISTS "Admin can read all subscriptions" ON subscriptions;
DROP POLICY IF EXISTS "Admin can insert subscriptions" ON subscriptions;
DROP POLICY IF EXISTS "Admin can update subscriptions" ON subscriptions;

CREATE POLICY "Users can read own subscriptions" ON subscriptions
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Admin can read all subscriptions" ON subscriptions
FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM users 
        WHERE users.id = auth.uid() 
        AND users.role = 'admin'
    )
);

CREATE POLICY "Admin can insert subscriptions" ON subscriptions
FOR INSERT TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM users 
        WHERE users.id = auth.uid() 
        AND users.role = 'admin'
    )
);

CREATE POLICY "Admin can update subscriptions" ON subscriptions
FOR UPDATE TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM users 
        WHERE users.id = auth.uid() 
        AND users.role = 'admin'
    )
);

-- Permettre aux clients d'insérer (pour Stripe)
CREATE POLICY "Users can create paid subscriptions" ON subscriptions
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id AND paid_at IS NOT NULL);

-- ============================================
-- ÉTAPE 6 : POLICY - Permettre suppression fichiers
-- ============================================
DROP POLICY IF EXISTS "Users can delete own files" ON files;
CREATE POLICY "Users can delete own files" ON files
FOR DELETE TO authenticated
USING (auth.uid() = user_id);

-- ============================================
-- ÉTAPE 7 : TRIGGER - Marquer mois comme "completed" quand dashboard publié
-- ============================================
CREATE OR REPLACE FUNCTION mark_month_completed()
RETURNS TRIGGER AS $$
DECLARE
    target_month TEXT;
    is_first BOOLEAN;
BEGIN
    -- Récupérer le mois du premier fichier lié à ce dashboard
    SELECT month INTO target_month
    FROM files
    WHERE dashboard_id = NEW.id
    LIMIT 1;
    
    IF target_month IS NULL THEN
        RETURN NEW;
    END IF;
    
    -- Vérifier si c'est le premier dashboard de ce client
    is_first := NOT has_received_first_dashboard(NEW.user_id);
    
    -- Créer ou mettre à jour l'abonnement
    INSERT INTO subscriptions (user_id, month, status, is_first_free, payment_method)
    VALUES (
        NEW.user_id,
        target_month,
        'completed',
        is_first,
        CASE WHEN is_first THEN 'free' ELSE 'paid' END
    )
    ON CONFLICT (user_id, month)
    DO UPDATE SET
        status = 'completed',
        is_first_free = CASE 
            WHEN subscriptions.is_first_free IS NULL OR subscriptions.is_first_free = FALSE 
            THEN is_first 
            ELSE subscriptions.is_first_free 
        END;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_mark_month_completed ON dashboards;
CREATE TRIGGER trigger_mark_month_completed
AFTER INSERT ON dashboards
FOR EACH ROW
WHEN (NEW.status = 'published')
EXECUTE FUNCTION mark_month_completed();
```

---

## ✅ VÉRIFICATION

Après avoir exécuté le SQL :

```sql
-- Tester les fonctions
SELECT has_received_first_dashboard('UUID_CLIENT'); -- FALSE au début

SELECT can_upload_for_month('UUID_CLIENT', '2026-01'); -- TRUE (1er gratuit)

-- Voir la structure
\d subscriptions
```

---

## 🎯 COMMENT ÇA MARCHE

1. **Client s'inscrit** → Aucune entrée dans `subscriptions`
2. **Client upload pour Janvier** → `can_upload_for_month()` retourne TRUE (1er gratuit)
3. **Admin publie dashboard Janvier** → Trigger crée : `{month: "2026-01", status: "completed", is_first_free: TRUE}`
4. **Client veut uploader pour Février** → `can_upload_for_month()` retourne FALSE (doit payer)
5. **Client paie 99€ pour Février** → Crée : `{month: "2026-02", status: "available", paid_at: NOW()}`
6. **Client peut uploader pour Février** → `can_upload_for_month()` retourne TRUE
7. **Admin publie dashboard Février** → Update : `status = "completed"`
8. **Client veut uploader pour Mars** → FALSE (doit payer à nouveau)

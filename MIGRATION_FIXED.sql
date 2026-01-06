# 🔧 MIGRATION SQL - VERSION CORRIGÉE

## ⚠️ SI VOUS AVEZ DÉJÀ EXÉCUTÉ L'ANCIEN SQL :

Exécutez d'abord ceci pour nettoyer :

```sql
-- Nettoyer l'ancienne version
DROP TRIGGER IF EXISTS trigger_mark_month_completed ON dashboards;
DROP FUNCTION IF EXISTS mark_month_completed();
DROP FUNCTION IF EXISTS has_received_first_dashboard(UUID);
DROP FUNCTION IF EXISTS can_upload_for_month(UUID, TEXT);
DROP TABLE IF EXISTS subscriptions CASCADE;
```

---

## 📝 NOUVELLE MIGRATION - COPIEZ TOUT ÇA :

```sql
-- ============================================
-- ÉTAPE 1 : COLONNES FILES
-- ============================================
ALTER TABLE files ADD COLUMN IF NOT EXISTS month TEXT;

-- ============================================
-- ÉTAPE 2 : TABLE SUBSCRIPTIONS
-- ============================================
CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    month TEXT NOT NULL,
    status TEXT DEFAULT 'available', -- "available" ou "completed"
    is_first_free BOOLEAN DEFAULT FALSE,
    paid_at TIMESTAMP,
    amount DECIMAL DEFAULT 99.00,
    payment_method TEXT,
    stripe_payment_id TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, month)
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_month ON subscriptions(month);
CREATE INDEX IF NOT EXISTS idx_files_month ON files(month);

-- ============================================
-- ÉTAPE 3 : FUNCTION - Vérifier 1er dashboard
-- ============================================
CREATE OR REPLACE FUNCTION has_received_first_dashboard(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM dashboards 
        WHERE user_id = p_user_id 
        AND status = 'published'
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ÉTAPE 4 : TRIGGER - Marquer comme completed
-- ============================================
CREATE OR REPLACE FUNCTION mark_month_completed()
RETURNS TRIGGER AS $$
DECLARE
    target_month TEXT;
    is_first BOOLEAN;
    files_count INTEGER;
BEGIN
    -- Seulement si le dashboard est publié
    IF NEW.status != 'published' THEN
        RETURN NEW;
    END IF;

    -- Attendre un peu pour que les fichiers soient liés
    PERFORM pg_sleep(0.5);

    -- Récupérer le mois du dashboard via les fichiers
    SELECT DISTINCT f.month INTO target_month
    FROM files f
    WHERE f.dashboard_id = NEW.id
    LIMIT 1;

    -- Si pas de mois trouvé, essayer avec user_id
    IF target_month IS NULL THEN
        SELECT DISTINCT f.month INTO target_month
        FROM files f
        WHERE f.user_id = NEW.user_id
        AND f.dashboard_id = NULL
        AND f.month IS NOT NULL
        ORDER BY f.upload_date DESC
        LIMIT 1;
    END IF;

    -- Si toujours pas de mois, sortir
    IF target_month IS NULL THEN
        RETURN NEW;
    END IF;

    -- Lier les fichiers du mois au dashboard
    UPDATE files 
    SET dashboard_id = NEW.id
    WHERE user_id = NEW.user_id 
    AND month = target_month 
    AND dashboard_id IS NULL;

    -- Vérifier si c'est le premier dashboard
    SELECT COUNT(*) INTO files_count
    FROM dashboards
    WHERE user_id = NEW.user_id
    AND id != NEW.id
    AND status = 'published';

    is_first := (files_count = 0);

    -- Créer ou mettre à jour subscription
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
        is_first_free = EXCLUDED.is_first_free;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_mark_month_completed ON dashboards;
CREATE TRIGGER trigger_mark_month_completed
AFTER INSERT OR UPDATE ON dashboards
FOR EACH ROW
EXECUTE FUNCTION mark_month_completed();

-- ============================================
-- ÉTAPE 5 : POLICIES
-- ============================================
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own subscriptions" ON subscriptions;
DROP POLICY IF EXISTS "Admin can read all subscriptions" ON subscriptions;
DROP POLICY IF EXISTS "Admin can insert subscriptions" ON subscriptions;
DROP POLICY IF EXISTS "Admin can update subscriptions" ON subscriptions;
DROP POLICY IF EXISTS "Users can create paid subscriptions" ON subscriptions;
DROP POLICY IF EXISTS "Users can delete own files" ON files;

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

CREATE POLICY "Users can create paid subscriptions" ON subscriptions
FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own files" ON files
FOR DELETE TO authenticated
USING (auth.uid() = user_id);
```

---

## ✅ VÉRIFICATION APRÈS SQL

Exécutez ceci pour vérifier :

```sql
-- 1. Vérifier que le trigger existe
SELECT 
    tgname, 
    tgrelid::regclass, 
    tgenabled
FROM pg_trigger 
WHERE tgname = 'trigger_mark_month_completed';

-- 2. Vérifier la function
SELECT proname FROM pg_proc WHERE proname = 'mark_month_completed';

-- 3. Tester la function manually
SELECT has_received_first_dashboard('UUID_TEST');
```

---

## 🧪 TEST MANUEL DU TRIGGER

Pour forcer le trigger sur un dashboard existant :

```sql
-- Trouver un dashboard
SELECT id, user_id FROM dashboards WHERE status = 'published' LIMIT 1;

-- Forcer le trigger
UPDATE dashboards SET status = 'published' WHERE id = 'DASHBOARD_ID';

-- Vérifier subscriptions
SELECT * FROM subscriptions;
```

---

## 🔍 DEBUG SI ÇA NE MARCHE TOUJOURS PAS

```sql
-- Voir les dashboards
SELECT id, user_id, period, status, created_at FROM dashboards;

-- Voir les fichiers
SELECT id, user_id, month, dashboard_id, original_name FROM files;

-- Voir les subscriptions
SELECT * FROM subscriptions;

-- Compter dashboards par client
SELECT 
    u.email,
    COUNT(d.id) as nb_dashboards,
    COUNT(s.id) as nb_subscriptions
FROM users u
LEFT JOIN dashboards d ON d.user_id = u.id AND d.status = 'published'
LEFT JOIN subscriptions s ON s.user_id = u.id
WHERE u.role = 'client'
GROUP BY u.email;
```

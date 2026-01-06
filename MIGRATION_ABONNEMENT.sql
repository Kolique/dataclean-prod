# 🔧 MIGRATION SQL - SYSTÈME D'ABONNEMENT

Exécutez ce SQL dans **Supabase → SQL Editor**

```sql
-- 1. AJOUTER COLONNES À LA TABLE FILES
ALTER TABLE files ADD COLUMN IF NOT EXISTS month TEXT; -- Format: "2026-01"

-- 2. CRÉER LA TABLE SUBSCRIPTIONS
CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    month TEXT NOT NULL, -- Format: "2026-01" (année-mois)
    status TEXT DEFAULT 'unpaid', -- "free", "paid", "unpaid"
    paid_at TIMESTAMP,
    amount DECIMAL DEFAULT 99.00,
    payment_method TEXT, -- "stripe", "manual", "free"
    stripe_payment_id TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, month) -- Un seul abonnement par client par mois
);

-- 3. CRÉER INDEX POUR PERFORMANCES
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_month ON subscriptions(month);
CREATE INDEX IF NOT EXISTS idx_files_month ON files(month);

-- 4. FUNCTION: Créer automatiquement l'abonnement gratuit pour nouveaux clients
CREATE OR REPLACE FUNCTION create_free_first_month()
RETURNS TRIGGER AS $$
BEGIN
    -- Si c'est un client (pas admin)
    IF NEW.role = 'client' THEN
        -- Créer l'abonnement gratuit pour le mois actuel
        INSERT INTO subscriptions (user_id, month, status, payment_method)
        VALUES (
            NEW.id,
            TO_CHAR(NOW(), 'YYYY-MM'),
            'free',
            'free'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. TRIGGER: Créer abonnement gratuit automatiquement
DROP TRIGGER IF EXISTS trigger_create_free_month ON users;
CREATE TRIGGER trigger_create_free_month
AFTER INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION create_free_first_month();

-- 6. POLICIES POUR SUBSCRIPTIONS
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Clients peuvent lire leurs propres abonnements
CREATE POLICY "Users can read own subscriptions" ON subscriptions
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

-- Admin peut tout lire
CREATE POLICY "Admin can read all subscriptions" ON subscriptions
FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM users 
        WHERE users.id = auth.uid() 
        AND users.role = 'admin'
    )
);

-- Admin peut insérer/modifier les abonnements
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

-- 7. POLICY: Permettre aux clients de supprimer leurs fichiers
CREATE POLICY "Users can delete own files" ON files
FOR DELETE TO authenticated
USING (auth.uid() = user_id);

-- 8. CRÉER LES ABONNEMENTS GRATUITS POUR LES CLIENTS EXISTANTS
INSERT INTO subscriptions (user_id, month, status, payment_method)
SELECT 
    id,
    TO_CHAR(created_at, 'YYYY-MM'),
    'free',
    'free'
FROM users
WHERE role = 'client'
ON CONFLICT (user_id, month) DO NOTHING;
```

---

## ✅ VÉRIFICATION

Après avoir exécuté le SQL, vérifiez :

```sql
-- Voir tous les abonnements
SELECT 
    u.laverie_name,
    u.email,
    s.month,
    s.status,
    s.payment_method,
    s.paid_at
FROM subscriptions s
JOIN users u ON s.user_id = u.id
ORDER BY u.laverie_name, s.month DESC;

-- Vérifier la structure
\d subscriptions
```

Vous devriez voir :
- Tous vos clients existants ont un abonnement "free" pour leur 1er mois ✅

# 📊 Data Clean - Documentation Complète du Projet

## 📋 Table des Matières
1. [Vue d'ensemble](#vue-densemble)
2. [Problème résolu](#problème-résolu)
3. [Solution proposée](#solution-proposée)
4. [Public cible](#public-cible)
5. [Architecture technique](#architecture-technique)
6. [Fonctionnalités actuelles](#fonctionnalités-actuelles)
7. [Business Model](#business-model)
8. [Roadmap et Objectifs](#roadmap-et-objectifs)
9. [Stack Technique](#stack-technique)
10. [Structure du Projet](#structure-du-projet)
11. [Flux Utilisateurs](#flux-utilisateurs)
12. [Points d'Amélioration](#points-damélioration)

---

## 🎯 Vue d'ensemble

**Data Clean** est une plateforme SaaS B2B qui transforme les données brutes des laveries automatiques en dashboards analytiques personnalisés et actionnables.

### Mission
Aider les gérants de laveries à prendre des décisions data-driven pour optimiser leur rentabilité et leur efficacité opérationnelle.

### Vision
Devenir la référence en analytics pour l'industrie des laveries automatiques en France, puis en Europe.

---

## 💡 Problème résolu

### Pain Points identifiés :

1. **Données inexploitées**
   - Les gérants reçoivent des fichiers Excel mensuels de leurs fournisseurs de caisses
   - Ces données sont brutes, difficiles à analyser
   - Pas de visualisation, pas d'insights

2. **Perte de temps**
   - Obligation de croiser manuellement les données
   - Pas de vue d'ensemble de la performance
   - Décisions basées sur l'intuition, pas les données

3. **Manque d'expertise**
   - Les gérants ne sont pas des data analysts
   - Pas de ressources pour embaucher un analyste
   - Besoin d'insights simples et actionnables

4. **Absence d'outils adaptés**
   - Les outils génériques (Excel, Google Sheets) sont complexes
   - Les solutions analytics (Tableau, Power BI) sont trop chères et complexes
   - Aucune solution spécialisée pour les laveries

---

## ✅ Solution proposée

### Proposition de valeur :

**"Envoyez vos fichiers Excel, recevez un dashboard pro en 48h"**

### Comment ça marche :

1. **Client s'inscrit** → Premier mois gratuit
2. **Client upload ses fichiers Excel** → Via interface simple (drag & drop)
3. **Notre équipe analyse** → Traitement manuel par des experts
4. **Client reçoit son dashboard PDF** → Graphiques, KPIs, insights
5. **Client paie si satisfait** → 99€/mois pour continuer

### Différenciation :

- ✅ **Simplicité extrême** : Pas de configuration, pas de setup
- ✅ **Expertise incluse** : Analyse faite par des humains, pas juste des graphiques auto
- ✅ **Prix accessible** : 99€/mois vs 500€+ pour Tableau
- ✅ **Spécialisé laveries** : KPIs et metrics adaptés au secteur
- ✅ **Sans engagement** : Cancel à tout moment

---

## 👥 Public cible

### Client Idéal (ICP) :

**Profil :**
- Gérant(e) de laverie automatique
- 1 à 5 établissements
- Chiffre d'affaires : 50k€ - 500k€/an
- Age : 35-55 ans
- Niveau tech : Moyen (utilise Excel, WhatsApp, email)

**Besoins :**
- Comprendre quelle machine est rentable
- Identifier les heures creuses
- Optimiser les tarifs
- Détecter les anomalies (pannes, vols)
- Comparer les performances entre établissements

**Motivations :**
- Augmenter la rentabilité
- Réduire le temps passé sur l'admin
- Prendre de meilleures décisions
- Professionnaliser leur activité

---

## 🏗️ Architecture technique

### Vue d'ensemble :

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│   CLIENT    │─────▶│   VERCEL     │─────▶│  SUPABASE   │
│  (Browser)  │      │  (Frontend)  │      │  (Database) │
└─────────────┘      └──────────────┘      └─────────────┘
                            │
                            ▼
                     ┌──────────────┐
                     │    STRIPE    │
                     │  (Paiement)  │
                     └──────────────┘
```

### Composants :

1. **Frontend (Vercel)**
   - Pages HTML/JS/CSS (Tailwind)
   - Hébergement et déploiement automatique
   - Serverless functions (API)

2. **Backend (Supabase)**
   - PostgreSQL database
   - Authentication (email/password)
   - Storage (fichiers Excel + PDF)
   - Row Level Security (RLS)

3. **Paiement (Stripe)**
   - Checkout sessions
   - Webhooks pour confirmation
   - Mode test actif

---

## ⚙️ Fonctionnalités actuelles

### 🔐 AUTHENTIFICATION
- [x] Inscription client (email + mot de passe)
- [x] Connexion
- [x] Déconnexion
- [x] Gestion des rôles (client / admin)

### 👤 ESPACE CLIENT
- [x] Dashboard avec statut d'abonnement
- [x] Upload de fichiers Excel par mois
- [x] Organisation des fichiers par période
- [x] Suppression de fichiers
- [x] Téléchargement des dashboards PDF reçus
- [x] Paiement Stripe (99€/mois)
- [x] Premier mois gratuit automatique

### 👨‍💼 ESPACE ADMIN
- [x] Vue d'ensemble (stats globales)
- [x] Liste de tous les clients
- [x] Badges visuels (gratuit / payé / en attente)
- [x] Accès aux fichiers de chaque client
- [x] Téléchargement des fichiers Excel
- [x] Upload de dashboards PDF
- [x] Publication des dashboards

### 💳 SYSTÈME DE PAIEMENT
- [x] Intégration Stripe Checkout
- [x] Webhook automatique
- [x] Gestion des abonnements
- [x] Premier dashboard gratuit
- [x] 99€ par mois supplémentaire

### 🗄️ BASE DE DONNÉES
- [x] Table `users` (clients + admin)
- [x] Table `files` (fichiers uploadés)
- [x] Table `dashboards` (dashboards créés)
- [x] Table `subscriptions` (historique paiements)
- [x] Triggers SQL automatiques
- [x] Row Level Security (RLS)

---

## 💰 Business Model

### Pricing :

| Offre | Prix | Détails |
|-------|------|---------|
| **1er dashboard** | **0€** | Gratuit, sans carte bancaire |
| **Dashboards suivants** | **99€/mois** | Un dashboard = un mois de données |

### Exemple de revenus :

**Client type** : 3 laveries, upload 3 mois/an (été + hiver)

```
Année 1 :
- Mois 1 : 0€ (gratuit)
- Mois 2 : 99€
- Mois 3 : 99€
= 198€/an

Avec 50 clients : 9,900€/an
Avec 200 clients : 39,600€/an
Avec 500 clients : 99,000€/an
```

### Coûts :

- Supabase : ~25€/mois (plan Pro)
- Vercel : 0€ (plan gratuit suffit)
- Stripe : 1.4% + 0.25€ par transaction (~1.50€ par paiement)
- Coût principal : **Temps d'analyse des données** (à automatiser)

### Objectif de rentabilité :

- **Break-even** : 30 clients payants
- **Rentable** : 100+ clients
- **Très rentable** : 500+ clients

---

## 🚀 Roadmap et Objectifs

### Phase 1 : MVP ✅ (TERMINÉ)
- [x] Authentification
- [x] Upload de fichiers
- [x] Interface admin
- [x] Paiement Stripe
- [x] Premier mois gratuit

### Phase 2 : Amélioration UX/UI 🔄 (EN COURS)
- [ ] Design premium et moderne
- [ ] Animations fluides
- [ ] Micro-interactions
- [ ] Responsive mobile parfait
- [ ] Onboarding guidé
- [ ] Emails transactionnels

### Phase 3 : Automatisation 🎯 (OBJECTIF Q1 2026)
- [ ] Parsing automatique des Excel
- [ ] Génération auto des dashboards (PDF)
- [ ] Templates de dashboards personnalisables
- [ ] Alertes automatiques (anomalies détectées)
- [ ] API pour intégrations

### Phase 4 : Scale 📈 (OBJECTIF Q2 2026)
- [ ] Multi-laveries (gestion de plusieurs établissements)
- [ ] Comparaison entre laveries
- [ ] Benchmarks sectoriels
- [ ] Prédictions (ML)
- [ ] Recommandations actionnables
- [ ] App mobile

### Phase 5 : Expansion 🌍 (OBJECTIF 2026-2027)
- [ ] Intégration directe avec caisses (API)
- [ ] Marché européen
- [ ] Autres verticales (salons de coiffure, pressing, etc.)
- [ ] Plateforme white-label

---

## 🛠️ Stack Technique

### Frontend :
- **HTML5** : Structure
- **Tailwind CSS** : Styling (utility-first)
- **JavaScript (Vanilla)** : Interactions
- **Chart.js** : Graphiques (page d'accueil)
- **Google Fonts** : Typographie (Cabinet Grotesk, General Sans)

### Backend :
- **Supabase** :
  - PostgreSQL (database)
  - Auth (email/password)
  - Storage (fichiers)
  - RLS (sécurité)
  - Triggers (automatisation)

### Paiement :
- **Stripe** :
  - Checkout Sessions
  - Webhooks
  - Test Mode actif

### Déploiement :
- **Vercel** :
  - Hosting frontend
  - Serverless functions
  - Déploiement automatique (push GitHub)
  - CDN global

### Outils :
- **VS Code** : Éditeur de code
- **Claude Code** : AI coding assistant
- **GitHub** : Version control
- **Git** : Source control

---

## 📁 Structure du Projet

```
dataclean-prod/
│
├── index.html              # Landing page (page d'accueil)
├── login.html              # Page de connexion
├── signup.html             # Page d'inscription
├── dashboard.html          # Interface client
├── admin.html              # Interface admin
├── success.html            # Confirmation paiement
│
├── api/                    # Serverless functions (Vercel)
│   ├── create-checkout.js  # Création session Stripe
│   └── stripe-webhook.js   # Réception paiements
│
├── package.json            # Dependencies (Stripe, Supabase)
├── vercel.json             # Config Vercel
│
└── README.md               # Documentation
```

---

## 🔄 Flux Utilisateurs

### Flux Client (Nouveau) :

```
1. Découverte → index.html
2. Inscription → signup.html
3. Connexion → login.html
4. Dashboard → dashboard.html
   ├─ Statut : "🎉 Premier mois gratuit"
   ├─ Upload fichiers Excel
   ├─ Attendre dashboard de l'admin
   └─ Télécharger dashboard PDF
5. Admin publie → Trigger SQL marque comme "completed"
6. Client retourne → Statut : "⚠️ Payer 99€ pour continuer"
7. Paiement Stripe → success.html
8. Webhook → Création subscription
9. Retour dashboard → Peut uploader pour nouveau mois
```

### Flux Admin :

```
1. Connexion → login.html
2. Dashboard admin → admin.html
3. Vue clients → Liste avec badges (gratuit/payé/attente)
4. Clic sur client → Modal avec fichiers par mois
5. Clic sur mois → Modal upload dashboard
6. Upload PDF → Publication
7. Trigger SQL → Marque mois comme "completed"
```

---

## 🎨 Points d'Amélioration

### UX/UI 🎨

**Priorité HAUTE :**
- [ ] Animations de chargement (skeleton screens)
- [ ] États vides avec illustrations
- [ ] Toasts pour les confirmations
- [ ] Onboarding en 3 étapes
- [ ] Preview des fichiers uploadés

**Priorité MOYENNE :**
- [ ] Mode sombre
- [ ] Thème personnalisable
- [ ] Raccourcis clavier
- [ ] Drag & drop amélioré

### Performance ⚡

**Priorité HAUTE :**
- [ ] Lazy loading des images
- [ ] Code splitting
- [ ] Optimisation bundle size
- [ ] Service Worker (offline mode)

**Priorité MOYENNE :**
- [ ] Compression images
- [ ] Cache stratégie
- [ ] Prefetch des pages

### Accessibilité ♿

**Priorité HAUTE :**
- [ ] Navigation clavier complète
- [ ] Labels ARIA
- [ ] Contraste couleurs (WCAG AAA)
- [ ] Focus management

**Priorité MOYENNE :**
- [ ] Screen reader support
- [ ] High contrast mode
- [ ] Réduction animations

### Fonctionnalités 🚀

**Quick Wins :**
- [ ] Recherche de fichiers
- [ ] Filtres par date
- [ ] Export CSV des données
- [ ] Notifications email (dashboard prêt)

**Moyen terme :**
- [ ] Multi-upload (plusieurs fichiers en même temps)
- [ ] Historique des paiements
- [ ] Factures automatiques
- [ ] Preview PDF avant download

**Long terme :**
- [ ] Dashboard interactif (pas juste PDF)
- [ ] Graphiques temps réel
- [ ] Comparaisons période/période
- [ ] Recommandations IA

### Sécurité 🔒

**Priorité HAUTE :**
- [ ] Rate limiting sur API
- [ ] CSRF tokens
- [ ] Input validation côté serveur
- [ ] Audit logs (actions admin)

**Priorité MOYENNE :**
- [ ] 2FA (authentification à deux facteurs)
- [ ] Session timeout
- [ ] Password strength meter
- [ ] Encrypt files at rest

### DevOps 🛠️

**Priorité HAUTE :**
- [ ] Monitoring (Sentry)
- [ ] Analytics (Plausible ou Mixpanel)
- [ ] Error tracking
- [ ] Uptime monitoring

**Priorité MOYENNE :**
- [ ] CI/CD pipeline
- [ ] Automated tests
- [ ] Staging environment
- [ ] Database backups automatiques

---

## 📊 Métriques à Suivre

### Acquisition :
- Nombre de visiteurs (landing page)
- Taux de conversion visiteur → inscription
- Sources de trafic

### Activation :
- Taux d'upload du 1er fichier
- Temps moyen avant 1er upload
- Taux de complétion onboarding

### Rétention :
- Taux de retour après 1er dashboard
- Taux de paiement (gratuit → payant)
- Churn rate mensuel

### Revenus :
- MRR (Monthly Recurring Revenue)
- ARPU (Average Revenue Per User)
- LTV (Lifetime Value)
- CAC (Customer Acquisition Cost)

### Satisfaction :
- NPS (Net Promoter Score)
- CSAT (Customer Satisfaction)
- Temps de support moyen
- Taux de résolution 1er contact

---

## 🎯 Objectifs 2026

### T1 2026 (Jan-Mar) :
- ✅ MVP fonctionnel
- [ ] 10 premiers clients payants
- [ ] 5,000€ MRR
- [ ] Refonte UI/UX complète

### T2 2026 (Apr-Jun) :
- [ ] 50 clients payants
- [ ] 15,000€ MRR
- [ ] Début automatisation (parsing Excel)
- [ ] App mobile (React Native)

### T3 2026 (Jul-Sep) :
- [ ] 150 clients payants
- [ ] 40,000€ MRR
- [ ] Génération auto des dashboards
- [ ] Levée de fonds (optional)

### T4 2026 (Oct-Dec) :
- [ ] 300 clients payants
- [ ] 80,000€ MRR
- [ ] Expansion européenne (Belgique, Suisse)
- [ ] Équipe de 3-5 personnes

---

## 💡 Opportunités Identifiées

### Court terme :
1. **Partenariats fournisseurs** : S'associer avec les fabricants de caisses enregistreuses
2. **Content marketing** : Blog sur la gestion de laveries
3. **Webinaires** : Sessions d'optimisation en live
4. **Témoignages clients** : Case studies avec ROI

### Moyen terme :
1. **Marketplace** : Templates de dashboards créés par la communauté
2. **API publique** : Permettre intégrations tierces
3. **Programme d'affiliation** : 20% de commission sur référrals
4. **White-label** : Vendre la solution en marque blanche

### Long terme :
1. **Expansion verticale** : Pressing, salons, stations de lavage auto
2. **Fintech** : Offrir du crédit basé sur les données
3. **IoT** : Capteurs connectés pour data en temps réel
4. **Plateforme** : Place de marché pour services laveries

---

## 🚨 Risques et Mitigation

### Risques identifiés :

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Concurrence directe | Faible | Élevé | First-mover advantage, spécialisation |
| Automatisation trop complexe | Moyenne | Moyen | Phase d'analyse manuelle d'abord |
| Acquisition coûteuse | Moyenne | Élevé | Partenariats, SEO, bouche-à-oreille |
| Dépendance Stripe/Supabase | Faible | Élevé | Architecture découplée, backups |
| Scaling technique | Moyenne | Moyen | Architecture cloud-native |

---

## 📞 Next Steps

### Pour améliorer le projet :

1. **Immédiat** (cette semaine) :
   - Refonte UI/UX avec design moderne
   - Ajout d'animations et micro-interactions
   - Optimisation mobile

2. **Court terme** (ce mois) :
   - Emails transactionnels (dashboard prêt)
   - Onboarding guidé
   - Analytics et monitoring

3. **Moyen terme** (3 mois) :
   - Automatisation parsing Excel
   - Génération PDF automatique
   - Premiers clients payants

4. **Long terme** (6+ mois) :
   - Dashboard interactif
   - App mobile
   - Expansion européenne

---

## 📚 Ressources

### Documentation technique :
- Supabase: https://supabase.com/docs
- Stripe: https://stripe.com/docs
- Vercel: https://vercel.com/docs
- Tailwind: https://tailwindcss.com/docs

### Inspiration design :
- Stripe: https://stripe.com/fr
- Linear: https://linear.app
- Vercel: https://vercel.com
- Notion: https://notion.so

### Outils utilisés :
- VS Code + Claude Code
- GitHub
- Supabase Dashboard
- Stripe Dashboard
- Vercel Dashboard

---

## ✅ Checklist de mise en production

### Avant de lancer :

**Technique :**
- [ ] Tests end-to-end sur tous les flux
- [ ] Vérification sécurité (XSS, CSRF, SQL injection)
- [ ] Performance (Lighthouse score > 90)
- [ ] Responsive (mobile, tablet, desktop)
- [ ] Monitoring en place (erreurs, uptime)

**Business :**
- [ ] Mentions légales + CGU/CGV
- [ ] Politique de confidentialité (RGPD)
- [ ] Conditions de paiement Stripe
- [ ] Support client (email, chat)

**Marketing :**
- [ ] Landing page optimisée (SEO)
- [ ] Pitch deck prêt
- [ ] Démo video
- [ ] Premiers témoignages

---

**Date de création** : Janvier 2026  
**Dernière mise à jour** : 06 janvier 2026  
**Version** : 1.0.0  
**Status** : 🚀 MVP Fonctionnel - Phase d'amélioration

---

*Ce document est vivant et sera mis à jour régulièrement au fur et à mesure de l'évolution du projet.*

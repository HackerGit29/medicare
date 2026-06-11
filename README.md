# MindCare — Carnet de Santé Numérique Mobile

Application mobile de gestion des soins de santé connectée à un backend Spring Boot + PostgreSQL. Architecture **3 tiers** : App Flutter ←→ API REST :8081 ←→ PostgreSQL `care_db`.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    App Mobile Flutter (Riverpod)                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌───────────────┐  │
│  │ Auth     │  │ Patient  │  │ Doctor   │  │ Nurse / Lab / │  │
│  │ Screen   │  │ Screen   │  │ Screen   │  │ Pharm Screen  │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └───────┬───────┘  │
│       │              │             │                │          │
│  ┌────▼──────────────▼─────────────▼────────────────▼──────┐   │
│  │                  GoRouter (app_router)                    │   │
│  │  /login · /patient · /doctor · /nurse · /lab · /pharm   │   │
│  │  /home (agent) · /settings                                │   │
│  └───────────────────────┬──────────────────────────────────┘   │
│                          │                                      │
│  ┌───────────────────────▼──────────────────────────────────┐   │
│  │    Riverpod Providers (State Management)                  │   │
│  │  ┌──────────────┐  ┌────────────────┐  ┌──────────────┐  │   │
│  │  │ authProvider  │  │ settingsProvider│  │ themeProvider│  │   │
│  │  │ (User?)       │  │ (lang: String)  │  │ (ThemeMode)  │  │   │
│  │  └──────┬───────┘  └────────────────┘  └──────────────┘  │   │
│  └─────────┼─────────────────────────────────────────────────┘   │
│            │                                                     │
│  ┌─────────▼─────────────────────────────────────────────────┐   │
│  │    SharedPreferences (stockage local)                      │   │
│  │  auth_token · user_type · user_data · is_dark_mode · lang  │   │
│  └────────────────────────────────────────────────────────────┘   │
└───────────────────────────────┬─────────────────────────────────┘
                                │ HTTP + JSON + JWT Bearer
┌───────────────────────────────▼─────────────────────────────────┐
│              API REST Spring Boot (:8081)                       │
│  ┌────────────┐  ┌────────────┐  ┌───────────┐  ┌───────────┐  │
│  │Auth        │  │Admission   │  │Patient    │  │Passage    │  │
│  │Controller  │  │Controller  │  │Controller │  │Controller │  │
│  └─────┬──────┘  └─────┬──────┘  └─────┬─────┘  └─────┬─────┘  │
│        │               │               │               │        │
│  ┌─────▼───────────────▼───────────────▼───────────────▼─────┐  │
│  │          Services (Auth · Admission · Patient · Passage)   │  │
│  └─────┬───────────────────────────────┬─────────────────────┘  │
│        │                               │                        │
│  ┌─────▼──────────────┐    ┌───────────▼──────────────────────┐ │
│  │ JPA Repositories   │    │ Spring Security (JWT Filter)     │ │
│  │ PatientRepository  │    │ BCrypt · JWT (24h) · Bearer     │ │
│  │ PassageRepository  │    └──────────────────────────────────┘ │
│  │ ExamenRepository   │                                        │
│  │ ProfessionnelRepo  │                                        │
│  └─────┬──────────────┘                                        │
└────────┼────────────────────────────────────────────────────────┘
         │ JDBC :5432
┌────────▼────────────────────────────────────────────────────────┐
│              PostgreSQL (care_db)                               │
│  patient · personnel · passage · examen · hopital · biometrie   │
└─────────────────────────────────────────────────────────────────┘
```

---

## State Management (Riverpod)

| Provider | Type | Rôle | Stockage |
|----------|------|------|----------|
| `authProvider` | `StateNotifier<AsyncValue<User?>>` | Authentification, session, déconnexion | `SharedPreferences` (token, user_type, user_data) |
| `settingsProvider` | `StateNotifier<String>` | Langue (fr/en) | `SharedPreferences` (app_language) |
| `themeProvider` | `StateNotifier<ThemeMode>` | Mode clair/sombre système | `SharedPreferences` (is_dark_mode) |

Le `goRouterProvider` est un `Provider<GoRouter>` qui écoute `authProvider` pour les redirections automatiques :
- Non connecté → `/login`
- Connecté → redirige vers l'écran du rôle (`/patient`, `/doctor`, `/nurse`, `/lab`, `/pharmacist`, `/home`)

### Flux d'authentification complet

```
Utilisateur → AuthScreen (sélectionne rôle + saisit credentials)
  → AuthNotifier.login(email, password)
  → Future.delayed(2s) [simule API] ⚠️ actuellement mocké
  → AsyncValue.data(User) stocké dans state
  → GoRouter écoute le changement → redirige vers /{role}

Déconnexion :
  → AuthNotifier.logout()
  → SharedPreferences.clear() (token, user_type, user_data)
  → state = null → GoRouter redirige vers /login
```

> **Note :** Actuellement, l'authentification est simulée côté Flutter (mock). Le rôle est déduit du préfixe email : `doctor@...` → docteur, `nurse@...` → infirmier, etc. L'intégration réelle avec `POST /auth/login-professionnel` est documentée mais pas encore câblée.

---

## Modèles de Données (Dart)

### `Patient`
| Champ | Type | Mapping API | Notes |
|-------|------|-------------|-------|
| `id` | `String` | `id_patient` | UUID |
| `nom` | `String` | `nom` | |
| `prenom` | `String` | `prenom` | |
| `dateNaissance` | `DateTime` | `date_naissance` | |
| `genre` | `String` | `genre` | M/F |
| `groupeSanguin` | `String?` | `groupe_sanguin` | A+, O-, etc. |
| `telephone` | `String?` | `telephone` | |
| `creeLe` | `DateTime` | `cree_le` | |

### `PersonnelMedical`
| Champ | Type | Mapping API | Notes |
|-------|------|-------------|-------|
| `id` | `int` | `id_personnel` | |
| `idHopital` | `int?` | `id_hopital` | FK vers hopital |
| `nom` | `String` | `nom` | |
| `prenom` | `String` | `prenom` | |
| `role` | `String` | `role` | doctor, nurse, lab_tech, pharmacist, agent |
| `identifiantPro` | `String?` | `identifiant_pro` | Matricule |
| `login` | `String?` | `login` | |
| `estActif` | `bool` | `est_actif` | Défaut: true |

### `PassageMedical`
| Champ | Type | Mapping API | Notes |
|-------|------|-------------|-------|
| `id` | `String` | `id_passage` | UUID |
| `idPatient` | `String` | `id_patient` | FK |
| `idHopital` | `int` | `id_hopital` | FK |
| `idCreateur` | `int` | `id_createur` | FK personnel |
| `dateAdmission` | `DateTime` | `date_admission` | |
| `dateCloture` | `DateTime?` | `date_cloture` | Null tant que ouvert |
| `motifVisite` | `String` | `motif_visite` | |
| `constantesVitales` | `Map?` | `constantes_vitales` | JSON: {temp, tension, pouls...} |
| `diagnostic` | `String?` | `diagnostic` | |
| `prescriptionOrdonnance` | `String?` | `prescription_ordonnance` | |
| `statutPassage` | `String` | `statut_passage` | en_cours, cloture |

### `ExamenLaboratoire`
| Champ | Type | Mapping API | Notes |
|-------|------|-------------|-------|
| `id` | `int` | `id_examen` | PK auto |
| `idPassage` | `String` | `id_passage` | FK |
| `idLaborantin` | `int` | `id_laborantin` | FK personnel |
| `typeExamen` | `String` | `type_examen` | NFS, CRP, etc. |
| `resultats` | `String` | `resultats` | Texte libre |
| `dateResultat` | `DateTime` | `date_resultat` | |

### `User` (scellé)
```
User (sealed)
 ├── PatientUser → contient Patient
 └── PersonnelUser → contient PersonnelMedical
```
Le `authProvider` expose un `AsyncValue<User?>` qui contient l'un ou l'autre selon le type de connexion.

---

## Écrans et Endpoints API

### 1. `AuthScreen` — `/login`
- **Rôle** : Patient, Médecin, Infirmier, Laborantin, Pharmacien
- **UI** : Fond dégradé rose, sélecteur de rôle (5 chips), champs email/mot de passe arrondis, hint biométrique patient
- **Données** : Mock (2s delay, rôle déduit de l'email)
- **Endpoint** : `POST /auth/login-professionnel` → `{ identifiantPro, motDePasse }` → `200 { token, userData }`

| Test Email | Rôle | Route |
|------------|------|-------|
| `patient@...` | Patient | `/patient` |
| `doctor@...` | Médecin | `/doctor` |
| `nurse@...` | Infirmier | `/nurse` |
| `lab@...` | Laborantin | `/lab` |
| `pharm@...` | Pharmacien | `/pharmacist` |
| *autre* | Agent admission | `/home` |

### 2. `HomeScreen` — Agent d'Admission — `/home`
- **Rôle** : Agent d'accueil
- **UI** : Bouton Géant "Scanner QR" (pulse animation) → bottom sheet scanneur, barre de recherche (filtre mock local), résultats + Admission récentes
- **Données** : Mock local `_PatientResult`
- **Endpoints associés** :
  - `POST /admission/scan-carte` → `{ qrData }` → `200 PatientDTO`
  - `POST /admission/creer-passage` → `{ idPatient, motifVisite, idHopital, idCreateur }` → `201 PassageDTO`

### 3. `PatientScreen` — Patient — `/patient`
- **Rôle** : Patient
- **UI** : En-tête avec date strip, carte "Score de cohérence" (barres 7 jours), activités favorites (3 pills : Mind Detox, Gratitude Notes, Conscious Breath), historique des passages médicaux
- **Données** : Mock local `_Passage` (4 entrées)
- **Endpoint** : `GET /patients/{id}/historique` → `HistoriqueDTO { passages, examens }`

### 4. `DoctorScreen` — Médecin — `/doctor`
- **Rôle** : Médecin
- **UI** : 2 tabs segmentés : "Passages en cours" (liste numérotée) / "Consultation" (carte patient gradient, antécédents, stats, formulaire diagnostic + ordonnance + clôture)
- **Données** : Mock local `_DossierPatient` (3 entrées)
- **Endpoints associés** :
  - `GET /patients/{id}/historique` → historique complet avec examens
  - `PUT /passages/{id}/consultation` → `{ diagnostic }` ou `{ prescriptionOrdonnance }` ou `{ statut: "CLOTURE" }`

### 5. `NurseScreen` — Infirmier — `/nurse`
- **Rôle** : Infirmier
- **UI** : Stats (en attente / complétés), liste de passages expansibles, formulaire constantes vitales (2-colonnes : température, tension, pouls, SpO2, poids, taille) avec sauvegarde
- **Données** : Mock local `_PassageNurse` (3 entrées)
- **Endpoint** : `PUT /passages/{id}/constantes` → `{ constantesVitales: { temp, tension, pouls, poids, taille, spo2 } }`

### 6. `LabScreen` — Laborantin — `/lab`
- **Rôle** : Laborantin
- **UI** : Liste des examens en attente (avec bords rouges pour urgences), formulaire résultats de laboratoire (textarea)
- **Données** : Mock local `_ExamenAttente` (3 entrées)
- **Endpoint** : `POST /laboratoire/ajouter-examen` → `{ idPassage, idLaborantin, typeExamen, resultats }` → `201 { idExamen }`

### 7. `PharmacistScreen` — Pharmacien — `/pharmacist`
- **Rôle** : Pharmacien
- **UI** : Liste des ordonnances à délivrer, détail prescription (liste médicaments + posologie), bouton valider délivrance
- **Données** : Mock local `_Ordonnance` (2 entrées)
- **Endpoint** : `PUT /passages/{id}/consultation` → `{ statutDelivrance: "delivre" }`

### 8. `SettingsScreen` — Paramètres — `/settings`
- **Rôle** : Tous
- **UI** : Carte profil, mode sombre (switch), langue, sécurité/biométrie, notifications, bouton déconnexion (danger)
- **Données** : `authProvider` + `themeProvider`
- **Action** : `AuthNotifier.logout()` → `SharedPreferences.clear()` → `context.go('/login')`

---

## API REST — Tableau de Correspondance

| Méthode | Endpoint | Rôle | Body | Réponse | Status |
|:--------|:---------|:-----|:-----|:--------|:-------|
| `POST` | `/auth/login-professionnel` | Tous | `{ identifiantPro, motDePasse }` | `{ token, userData }` | 🔒 JWT |
| `POST` | `/auth/login-biometrique` | Patient | `{ clePublique, defiSigne }` | `{ token, userData }` | 🔒 |
| `POST` | `/auth/enregistrer-biometrie` | Patient | `{ clePublique }` | `{ statut: OK }` | 🔒 |
| `POST` | `/admission/scan-carte` | Agent | `{ qrData }` | `PatientDTO` | 🔒 |
| `POST` | `/admission/creer-passage` | Agent | `{ idPatient, motifVisite, idHopital, idCreateur }` | `PassageDTO` (201) | 🔒 |
| `GET` | `/patients/{id}/historique` | Patient, Médecin, Infirmier | — | `HistoriqueDTO { passages[], examens[] }` | 🔒 |
| `PUT` | `/passages/{id}/constantes` | Infirmier | `{ constantesVitales: {...} }` | `PassageDTO` | 🔒 |
| `PUT` | `/passages/{id}/consultation` | Médecin, Pharmacien | `{ diagnostic? / prescriptionOrdonnance? / statut? }` | `PassageDTO` | 🔒 |
| `POST` | `/laboratoire/ajouter-examen` | Laborantin | `{ idPassage, idLaborantin, typeExamen, resultats }` | `ExamenDTO` (201) | 🔒 |

Tous les endpoints protégés nécessitent un header `Authorization: Bearer <JWT>`.

---

## Flux de Données Complet (ex. Consultation Médecin)

```
1. AUTH
   Médecin → AuthScreen → login(doctor@..., mdp)
   → AuthNotifier.login() [simulé: 2s delay]
   → GoRouter redirige → /doctor

2. CHARGEMENT DOSSIERS
   DoctorScreen.initState() → _tabCtrl = TabController(length: 2)
   → Mock data affichée dans Tab 1 (Passages en cours)

3. SÉLECTION PATIENT
   Médecin tape sur un dossier → setState(_selectedPatient)
   → _tabCtrl.animateTo(1) → Tab 2 (Consultation)

4. SAISIE DIAGNOSTIC
   Médecin remplit _diagCtrl / _ordoCtrl
   → Appuie "Clôturer le passage"
   → _cloture() → Future.delayed(1s) [simulé]
   → SnackBar "Passage cloturé"

5. VERS BACKEND (future intégration)
   ˆ PUT /passages/{id}/consultation
   Authorization: Bearer <JWT>
   Body: { diagnostic: "...", prescriptionOrdonnance: "...", statut: "CLOTURE" }
```

---

## Diagrammes UML (25 fichiers)

Tous les diagrammes sont dans `diagrams/` au format PlantUML (.puml) + PNG.

| Catégorie | Fichiers | Description |
|-----------|----------|-------------|
| **Cas d'utilisation** | `01_cas_utilisation` | 15 UC, 7 acteurs, relations UML 2.0, groupes logiques |
| **Classes** | `02_diagramme_classes` | 3 packages : Flutter models, Spring Boot controllers, JPA entities |
| **Séquence** | `03_sequence_01` à `13` | 13 séquences : scan QR, création passage, connexion biométrique, enregistrement biométrie, historique, diagnostic, ordonnance, clôture, constantes, labo, pharmacie, carnet patient, admin |
| **Activité** | `04_activite_global` | Parcours patient global (arrivée → clôture) |
| **Activité** | `04_activite_01` | Authentification (mdp + biométrique) avec flux décisionnel Spring Security |
| **Activité** | `04_activite_02` | Admission patient (scan QR + création passage) |
| **Activité** | `04_activite_03` | Consultation médicale complète (diagnostic → prescription → clôture) |
| **Activité** | `04_activite_04` | Laboratoire (prélèvement → analyse → résultats) |
| **Activité** | `04_activite_05` | Pharmacie (validation ordonnance → délivrance) |
| **Activité** | `04_activite_06` | Biométrie (enregistrement + réutilisation connexion) |
| **C4** | `05_c4_contexte` | Vue contextuelle : acteurs + système |
| **C4** | `05_c4_conteneurs` | Vue conteneurs : 2 apps + API + DB |
| **C4** | `05_c4_composants` | Vue composants : controllers, services, repos |

---

## Routes GoRouter

| Path | Screen | Rôle requis |
|------|--------|-------------|
| `/login` | `AuthScreen` | Tout le monde |
| `/patient` | `PatientScreen` | Patient |
| `/home` | `HomeScreen` | Agent d'admission |
| `/doctor` | `DoctorScreen` | Médecin |
| `/nurse` | `NurseScreen` | Infirmier |
| `/lab` | `LabScreen` | Laborantin |
| `/pharmacist` | `PharmacistScreen` | Pharmacien |
| `/settings` | `SettingsScreen` | Tous les rôles connectés |

---

## Dépendances

| Package | Version | Utilisation |
|---------|---------|-------------|
| `flutter_riverpod` | ^2.5.1 | State management |
| `go_router` | ^14.1.4 | Navigation déclarative |
| `shared_preferences` | ^2.2.3 | Stockage local (token, thème, langue) |
| `google_fonts` | ^6.2.1 | Typographie (DM Sans + DM Serif Display) |
| `hugeicons` | ^1.1.7 | Icônes |

---

## État du Développement

- [x] Modèles de données (5 modèles Dart)
- [x] Composants UI partagés (MindCareCard, MindCareHeader, MindCareButton, MindCarePill, MindCareBadge, MindCareGlassButton)
- [x] Tous les écrans (8 screens, UI complète)
- [x] State management Riverpod (auth, theme, settings)
- [x] Navigation GoRouter avec guard d'authentification
- [x] Thème personnalisé (AppTheme avec DM Sans/DM Serif Display, palette complète)
- [x] Diagrammes UML (25 fichiers .puml + .png)
- [x] Authentification mockée (rôle déduit de l'email)
- [ ] Intégration API Spring Boot réelle (POST/GET/PUT)
- [ ] Scan QR réel (caméra)
- [ ] Connexion biométrique réelle (capteur appareil)
- [ ] Notifications push
- [ ] Tests unitaires et d'intégration

---

## Commandes

```bash
flutter run                    # Lancer l'application
flutter analyze                # Vérifier le code
java -jar diagrams/plantuml.jar -tpng diagrams/*.puml  # Générer les diagrammes
```

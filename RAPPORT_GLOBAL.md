# Rapport Global — MindCare (Carnet de Santé Numérique)

> **Date** : Juin 2026  
> **Projet** : MindCare — Application mobile de gestion des soins de santé  
> **Stack** : Flutter 3.x (Riverpod) ←→ Spring Boot 4.0.6 (Java 21/Kotlin) ←→ PostgreSQL (care_db)  
> **Dépôts** : `medicare/` (frontend Flutter), `numsante-main/` (backend Spring Boot)

---

## Table des Matières

1. [Vue d'Ensemble du Projet](#1-vue-densemble-du-projet)
2. [Architecture Justifiée](#2-architecture-justifiée)
3. [Acteurs et Rôles](#3-acteurs-et-rôles)
4. [Règles de Gestion](#4-règles-de-gestion)
5. [Flux Métier Complets](#5-flux-métier-complets)
6. [Correspondance Frontend ↔ Backend](#6-correspondance-frontend--backend)
7. [Base de Données](#7-base-de-données)
8. [Sécurité](#8-sécurité)
9. [État du Développement et Actions Prioritaires](#9-état-du-développement-et-actions-prioritaires)
10. [Diagrammes UML](#10-diagrammes-uml)

---

## 1. Vue d'Ensemble du Projet

### 1.1 Objectif

MindCare est une application mobile de **carnet de santé numérique** permettant la gestion complète du parcours de soins d'un patient dans un établissement hospitalier : admission, consultation médicale, constantes vitales (infirmier), examens de laboratoire, délivrance de médicaments (pharmacie), et suivi patient.

### 1.2 Périmètre Fonctionnel

| Domaine | Fonctionnalités |
|---------|-----------------|
| **Admission** | Scan de carte QR patient, création de passage médical, recherche de patient |
| **Soins infirmiers** | Saisie des constantes vitales (température, tension, pouls, SpO2, poids, taille) |
| **Consultation médicale** | Diagnostic, prescription d'ordonnance, clôture de passage |
| **Laboratoire** | Saisie des résultats d'examens (NFS, CRP, etc.) |
| **Pharmacie** | Validation et délivrance d'ordonnances |
| **Patient** | Consultation de l'historique médical, score de cohérence, activités |
| **Administration** | Gestion des hôpitaux, du personnel, rapports statistiques |

### 1.3 Technologies

| Couche | Technologie | Version | Justification |
|--------|-------------|---------|---------------|
| **Frontend mobile** | Flutter | 3.x (Dart 3.11) | Cross-platform (iOS/Android/Desktop/Web), hot reload, typage fort, écosystème riche |
| **State management** | Riverpod | ^2.5.1 | Type-safe, testable, pas de `BuildContext` nécessaire, providers composables |
| **Navigation** | GoRouter | ^14.1.4 | Déclaratif, redirect auth intégré, deep linking |
| **Backend API** | Spring Boot | 4.0.6 (Java 21) | Mature, Spring Security intégré, JPA/Hibernate, transactionnel, vaste écosystème |
| **Base de données** | PostgreSQL | 16+ | JSONB pour données médicales flexibles, UUID PK, ACID, maturité |
| **Authentification** | JWT (jjwt 0.12.6) | 24h expiration | Sans état (stateless), adaptable cluster |
| **QR Code** | ZXing | — | Génération et scan de QR codes pour identification patient |
| **Documentation API** | Swagger/OpenAPI (springdoc 3.0.2) | — | Auto-documentation des endpoints |
| **Tests backend** | JUnit 4 + Mockito + Cucumber | — | Tests unitaires, intégration, BDD |
| **Design system** | DESIGN.md (1480 lignes) | — | Palettes, typographie DM Sans/DM Serif Display, composants, animations |

### 1.4 Structure des Dépôts

```
📁 medicare/ (Flutter Frontend)
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── router/app_router.dart          (GoRouter, 8 routes, guard auth)
│   │   └── theme/
│   │       ├── app_theme.dart               (couleurs, typographie, radius)
│   │       └── components/                  (4 composants partagés)
│   ├── features/
│   │   ├── auth/application/auth_provider.dart (login/logout mocké)
│   │   ├── auth/presentation/auth_screen.dart
│   │   ├── dashboard/presentation/home_screen.dart (agent admission)
│   │   ├── patient/presentation/patient_screen.dart
│   │   ├── doctor/presentation/doctor_screen.dart
│   │   ├── nurse/presentation/nurse_screen.dart
│   │   ├── lab/presentation/lab_screen.dart
│   │   ├── pharmacist/presentation/pharmacist_screen.dart
│   │   └── settings/presentation/settings_screen.dart
│   └── shared/
│       ├── models/    (5 modèles : Patient, PersonnelMedical, PassageMedical, ExamenLaboratoire, User)
│       └── providers/ (settings, theme)

📁 numsante-main/ (Backend Spring Boot)
├── src/main/java/com/bank/numsante/
│   ├── controller/    (10 contrôleurs REST)
│   ├── service/       (8 services métier + LogService)
│   ├── entity/        (8 entités JPA)
│   ├── repository/    (8 repositories Spring Data)
│   ├── dto/           (18+ DTOs)
│   ├── security/      (2 UserDetailsService + config JWT)
│   └── config/        (Spring Security + JwtTokenProvider)
└── build.gradle.kts   (Gradle Kotlin, Java 21, Spring Boot 4.0.6)
```

---

## 2. Architecture Justifiée

### 2.1 Architecture 3-Tiers

```
┌─────────────────────────────────────────────────────────────────────┐
│  TIER 1 — PRÉSENTATION (Flutter)                                    │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  • 8 écrans avec UI réactive (Riverpod StateNotifier)          │  │
│  │  • Navigation GoRouter avec guard d'authentification           │  │
│  │  • Stockage local SharedPreferences (token, thème, langue)     │  │
│  │  • Composants réutilisables (MindCareCard, Button, Pill...)    │  │
│  └───────────────────────────────────────────────────────────────┘  │
└────────────────────────────────┬────────────────────────────────────┘
                                 │ HTTP/HTTPS — JSON — JWT Bearer
┌────────────────────────────────▼────────────────────────────────────┐
│  TIER 2 — LOGIQUE MÉTIER (Spring Boot 4.0.6 — :8081)                │
│  ┌────────────┐  ┌────────────┐  ┌───────────┐  ┌───────────────┐  │
│  │ Controllers│→│ Services   │→│ JPA Repos  │  │ Spring Sec    │  │
│  │ (10)       │  │ (8 + Log)  │  │ (8)        │  │ JWT Filter    │  │
│  └────────────┘  └────────────┘  └───────────┘  └───────────────┘  │
│  • Swagger/OpenAPI (springdoc)                                      │
│  • Validation Jakarta (@Valid, @NotNull...)                          │
│  • Gestion transactionnelle (@Transactional)                         │
│  • Traçabilité complète (LogService → LogTracabilite)               │
└────────────────────────────────┬────────────────────────────────────┘
                                 │ JDBC :5432
┌────────────────────────────────▼────────────────────────────────────┐
│  TIER 3 — PERSISTANCE (PostgreSQL — care_db)                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │ patients │  │ personnel│  │ passages │  │ examens_labo     │   │
│  │ (UUID)   │  │ (SERIAL) │  │ (UUID)   │  │ (SERIAL)         │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────────┘   │
│  + hopitaux, cartes_numeriques, prescriptions_medicaments,          │
│    logs_tracabilite                                                 │
│  • JSONB pour constantes_vitales (flexibilité données médicales)    │
│  • UUID pour patients/passages (conformité RGPD, non-séquentiel)    │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 Pourquoi ce choix d'architecture ?

| Critère | 3-Tiers (choisi) | Monolithique | Microservices |
|---------|------------------|--------------|---------------|
| **Complexité du projet** | Adapté (1 app, 1 API, 1 DB) | Sous-dimensionné | Sur-dimensionné |
| **Évolutivité** | Chaque tier scalable | Difficile | Naturelle (mais cher) |
| **Maintenance** | Indépendance UI/métier | Couplage fort | Complexité orchestration |
| **Sécurité** | JWT, API non-exposée directe | DB accessible | Surface d'attaque + grande |
| **Coût développement** | Raisonnable | Rapide au début | Très élevé |
| **Multi-plateforme** | API unique pour tous les clients | Monolithe = app seule | OK mais overkill |

### 2.3 Justifications détaillées

**Pourquoi Flutter et pas React Native / Natif ?**
- **Cross-platform réel** : iOS, Android, Web, Desktop (Windows/macOS/Linux) — un seul codebase
- **Performance** : Compilation native (pas de bridge JS), 60 FPS garanti
- **Productivité** : Hot reload < 1s, écosystème packages riche
- **Riverpod > Bloc/Provider** : Typage fort, providers composables, testable sans BuildContext
- **Design system centralisé** : `AppTheme` + composants `MindCare*` réutilisables

**Pourquoi Spring Boot et pas Node.js / FastAPI ?**
- **Spring Security mature** : JWT, BCrypt, filtre chaîne configurable
- **JPA/Hibernate** : Mapping objet-relationnel transactionnel, gestion de cache L2
- **Validation intégrée** : Jakarta Bean Validation (@Valid, @NotNull, @Email...)
- **Traçabilité** : AOP/intercepteurs pour logs d'audit
- **Écosystème médical** : Hibernate Envers (audit historique), support JSONB natif
- **Testabilité** : JUnit + Mockito + Cucumber (BDD)
- **Java 21** : Virtual Threads, Records, Pattern Matching

**Pourquoi PostgreSQL et pas MySQL / MongoDB ?**
- **JSONB** : Stockage flexible des constantes vitales (structure variable selon contexte)
- **UUID natif** : Primary keys non-séquentielles pour conformité RGPD
- **ACID** : Transactions fiables pour données médicales critiques
- **PostGIS** (extensible) : Pour géolocalisation hôpitaux
- **Hibernate dialecte** : Support PostgreSQL complet avec fonctionnalités avancées

---

## 3. Acteurs et Rôles

### 3.1 Tableau des Acteurs

| Acteur | Rôle système | Route Flutter | Identifié par | Peut faire |
|--------|-------------|---------------|---------------|------------|
| **Agent d'admission** | `agent` | `/home` | `identifiantPro` | Scanner QR, créer passage, rechercher patient |
| **Patient** | `patient` (via email/mdp) ou `PATIENT` (via JWT) | `/patient` | Email + mot de passe OU biométrie | Consulter historique, score cohérence |
| **Médecin** | `doctor` | `/doctor` | `identifiantPro` + MDP | Voir passages, diagnostiquer, prescrire, clôturer |
| **Infirmier** | `nurse` | `/nurse` | `identifiantPro` + MDP | Saisir constantes vitales |
| **Laborantin** | `lab_tech` | `/lab` | `identifiantPro` + MDP | Ajouter résultats d'examens |
| **Pharmacien** | `pharmacist` | `/pharmacist` | `identifiantPro` + MDP | Valider/délivrer ordonnances |
| **Administrateur** | `admin` | — | `identifiantPro` + MDP | Gérer hôpitaux, personnel, reset passwords |

### 3.2 Types d'authentification

| Méthode | Cible | Endpoint | Flux |
|---------|-------|----------|------|
| **Login mot de passe** | Personnel médical | `POST /auth/login-professionnel` | `{ identifiantPro, motDePasse }` → JWT |
| **Login email/mdp** | Patient | `POST /auth/login-patient` | `{ email, motDePasse }` → JWT |
| **Login biométrique** | Patient & Personnel | `POST /auth/login-biometrique` | `{ idUtilisateur, signatureDefi }` → JWT |
| **Enregistrement biométrie** | Patient & Personnel | `POST /auth/enregistrer-biometrie` | `{ idUtilisateur, typeUtilisateur, clePubliqueAppareil }` |
| **Inscription patient** | Patient | `POST /auth/register-patient` | `{ nom, prenom, email, motDePasse... }` → `{ idPatient, qrCodeToken }` |

### 3.3 Mapping des rôles (email → rôle, mock actuel)

| Email | Rôle Flutter (mock) | Rôle Backend | Route |
|-------|---------------------|-------------|-------|
| `patient@...` | Patient | patient | `/patient` |
| `doctor@...` | Médecin | doctor | `/doctor` |
| `nurse@...` | Infirmier | nurse | `/nurse` |
| `lab@...` | Laborantin | lab_tech | `/lab` |
| `pharm@...` | Pharmacien | pharmacist | `/pharmacist` |
| *autre* | Agent admission | agent | `/home` |

---

## 4. Règles de Gestion

### 4.1 Règles d'Authentification et Sécurité

| ID | Règle | Explication | Implémentation |
|----|-------|-------------|----------------|
| **RG-AUTH-01** | Le personnel médical s'authentifie avec son identifiant professionnel (matricule) et mot de passe | Pas d'email pour le personnel, utilisation du matricule unique | `AuthService.loginProfessionnel()` → `personnelRepo.findByIdentifiantPro()` |
| **RG-AUTH-02** | Le patient s'authentifie avec son email et mot de passe | Le patient a un email unique, pas d'identifiant professionnel | `AuthService.loginPatient()` → `patientRepo.findByEmail()` |
| **RG-AUTH-03** | Le mot de passe est stocké hashé (BCrypt), jamais en clair | Conformité RGPD, sécurité des données | `PasswordEncoder.encode()` côté backend |
| **RG-AUTH-04** | Le JWT expire après 24h (86400000ms) | Session limitée, sécurité renouvelée quotidiennement | `jwt.expiration=86400000` dans `application.properties` |
| **RG-AUTH-05** | La biométrie peut être enregistrée par patient OU personnel médical | Clé publique stockée pour vérification ultérieure | `AuthService.enregistrerBiometrie()` — champ `clePubliqueAppareil` ou `clePubliqueBiometrique` |
| **RG-AUTH-06** | L'inscription patient crée automatiquement une carte numérique QR (valide 2 ans) | Tout patient enregistré a une carte d'identité numérique | `PatientService.registerPatient()` → `CarteNumerique.expireLe = now + 2 years` |

### 4.2 Règles de Gestion des Patients

| ID | Règle | Explication | Implémentation |
|----|-------|-------------|----------------|
| **RG-PAT-01** | Un email patient est unique dans le système | Évite les doublons, identifiant unique | `patientRepository.findByEmail()` + contrainte `@Column(unique=true)` |
| **RG-PAT-02** | Un patient peut avoir plusieurs passages médicaux | Un patient revient plusieurs fois à l'hôpital | `@OneToMany(mappedBy="patient") List<PassageMedical> passages` |
| **RG-PAT-03** | Le groupe sanguin est optionnel | Tous les patients ne connaissent pas leur groupe | `@Column(length=3) String groupeSanguin` nullable |
| **RG-PAT-04** | La carte QR peut être renouvelée (l'ancienne passe en statut "remplacee") | Perte/vol de carte | `PatientService.renouvelerCarte()` → nouvelle `CarteNumerique` avec statut "remplacee" |
| **RG-PAT-05** | La carte QR peut être suspendue (perte, vol) | Sécurité, empêche utilisation frauduleuse | `PatientService.suspendreCarte()` → `carte.setStatut(motif)` |

### 4.3 Règles de Gestion des Passages Médicaux

| ID | Règle | Explication | Implémentation |
|----|-------|-------------|----------------|
| **RG-PASS-01** | Un passage est créé par un agent d'admission après scan QR | Le scan QR identifie le patient, puis l'agent crée le passage | `AdmissionService.creerPassage()` après `AdmissionService.scanCarte()` |
| **RG-PASS-02** | Le statut initial d'un passage est "en_cours" | Début du parcours de soins | `PassageMedical.statutPassage = "en_cours"` (défaut) |
| **RG-PASS-03** | Les constantes vitales sont saisies par l'infirmier dans un champ JSONB flexible | Pas de structure fixe (variables selon contexte médical) | `@JdbcTypeCode(SqlTypes.JSON) Map<String, Object> constantesVitales` |
| **RG-PASS-04** | Un médecin peut poser un diagnostic ET/OU prescrire une ordonnance | Actions indépendantes possibles | `PassageService.ajouterConsultation()` → `setDiagnostic()` ET/OU `setPrescriptionOrdonnance()` |
| **RG-PASS-05** | La clôture d'un passage met le statut à "termine" | Fin du parcours de soins | `request.isCloturerPassage()` → `passage.setStatutPassage("termine")` |
| **RG-PASS-06** | Un passage peut être annulé (par un agent autorisé) | Erreur d'admission, désistement | `PassageService.annulerPassage()` → `statutPassage = "annule"` |
| **RG-PASS-07** | Un passage est lié à un hôpital spécifique | Traçabilité du lieu de soins | `@ManyToOne Hopital hopital` dans `PassageMedical` |
| **RG-PASS-08** | Un passage a UN créateur (agent qui a admis le patient) | Responsabilité de l'admission | `@ManyToOne PersonnelMedical createur` |

### 4.4 Règles de Gestion des Examens de Laboratoire

| ID | Règle | Explication | Implémentation |
|----|-------|-------------|----------------|
| **RG-LAB-01** | Un examen est lié à un passage médical (pas directement à un patient) | L'examen fait partie du parcours de soins | `@ManyToOne PassageMedical passage` dans `ExamenLaboratoire` |
| **RG-LAB-02** | Un examen est créé par un laborantin identifié | Traçabilité du responsable | `@ManyToOne PersonnelMedical laborantin` + `authentication.getName()` |
| **RG-LAB-03** | Les résultats d'examen sont en texte libre (TEXT) | Format variable selon type d'examen | `@Column(columnDefinition = "TEXT") String resultats` |
| **RG-LAB-04** | La date de résultat est automatique (horodatage création) | Intégrité de la donnée | `@CreationTimestamp LocalDateTime dateResultat` |

### 4.5 Règles de Gestion des Prescriptions / Pharmacie

| ID | Règle | Explication | Implémentation |
|----|-------|-------------|----------------|
| **RG-PHARM-01** | L'ordonnance est rédigée en texte libre par le médecin sur le passage | Prescription textuelle complète | `passage.setPrescriptionOrdonnance()` dans `PassageService` |
| **RG-PHARM-02** | Chaque prescription délivrée crée une entrée `PrescriptionMedicament` | Traçabilité de la délivrance | `PharmacieService.validerPrescription()` crée `PrescriptionMedicament` |
| **RG-PHARM-03** | Le pharmacien peut valider OU refuser une prescription | Pouvoir de vérification pharmaceutique | `request.isDelivre()` → true = délivré, false = refusé |
| **RG-PHARM-04** | Une prescription refusée conserve la trace du refus et du commentaire | Audit trail | `PrescriptionMedicament.commentaire` + `delivre = false` |
| **RG-PHARM-05** | Le pharmacien est lié à la prescription lors de la validation | Traçabilité du délivrant | `prescription.setPharmacien(pharmacien)` dans `PharmacieService` |

### 4.6 Règles de Gestion des Hôpitaux et Personnel

| ID | Règle | Explication | Implémentation |
|----|-------|-------------|----------------|
| **RG-HOSP-01** | Un hôpital a un code unique | Identifiant métier simple | `@Column(unique=true) String codeUnique` |
| **RG-HOSP-02** | Un personnel médical appartient à un hôpital | Rattachement géographique | `@ManyToOne Hopital hopital` dans `PersonnelMedical` |
| **RG-HOSP-03** | L'identifiant professionnel (matricule) est unique | Pas de doublon dans le personnel | `personnelRepo.findByIdentifiantPro()` + `@Column(unique=true)` |
| **RG-HOSP-04** | La désactivation d'un personnel est logique (soft delete), pas physique | Conservation de l'audit trail | `personnel.setEstActif(false)` dans `deletePersonnel()` |
| **RG-HOSP-05** | Seul un ADMIN peut créer/modifier/désactiver du personnel | Séparation des pouvoirs | Vérification ADMIN avant tous les endpoints `PersonnelController` |
| **RG-HOSP-06** | Un ADMIN peut réinitialiser le mot de passe d'un personnel | Gestion des mots de passe oubliés | `PersonnelService.resetPassword()` |

### 4.7 Règles de Traçabilité (Audit)

| ID | Règle | Explication | Implémentation |
|----|-------|-------------|----------------|
| **RG-TRACE-01** | Toute action médicale importante est tracée dans `logs_tracabilite` | Conformité RGPD, auditabilité | `LogService.logAction()` appelé dans chaque service |
| **RG-TRACE-02** | Les logs contiennent : utilisateur, patient, action, dossier, IP, date | Identification complète de l'action | `LogTracabilite` avec tous ces champs |
| **RG-TRACE-03** | L'adresse IP est capturée automatiquement depuis la requête HTTP | Traçabilité réseau | `httpServletRequest.getRemoteAddr()` dans `LogService` |

### 4.8 Règles Métiers Transverses

| ID | Règle | Explication |
|----|-------|-------------|
| **RG-TRANS-01** | Un passage peut avoir plusieurs examens de laboratoire | Plusieurs analyses durant un même séjour |
| **RG-TRANS-02** | Un passage "terminé" ne peut plus être modifié | Intégrité des données médicales closes |
| **RG-TRANS-03** | Les données médicales sont horodatées automatiquement à chaque étape | `@CreationTimestamp` sur date_admission, date_resultat |
| **RG-TRANS-04** | L'historique patient regroupe tous ses passages et examens | Vision globale du parcours de soins | `PatientService.getHistorique()` → `HistoriquePassageDto` |

---

## 5. Flux Métier Complets

### 5.1 Parcours Patient Complet

```
Arrivée patient à l'hôpital
  ↓
[1] SCAN QR + ADMISSION (Agent)
    → Scan de la carte QR du patient → identification
    → Création d'un passage médical avec motif de visite
    → Statut: "en_cours"
  ↓
[2] CONSTANTES VITALES (Infirmier)
    → Saisie: température, tension, pouls, SpO2, poids, taille
    → Enregistrement dans constantes_vitales (JSONB)
  ↓
[3] CONSULTATION MÉDICALE (Médecin)
    → Visualisation antécédents et constantes
    → Diagnostic
    → Prescription d'ordonnance (si nécessaire)
    → Clôture du passage (statut: "termine")
  ↓
[4a] EXAMENS LABORATOIRE (Laborantin) [optionnel]
    → Saisie des résultats d'examens
    → Lié au passage médical
  ↓
[4b] DÉLIVRANCE MÉDICAMENTS (Pharmacien) [optionnel]
    → Validation de l'ordonnance
    → Délivrance ou refus motivé
  ↓
[5] SUIVI (Patient)
    → Consultation de l'historique des passages
    → Visualisation des diagnostics et examens
```

### 5.2 Flux d'Authentification

```
┌───────────────────────────────────────────────────────────┐
│ PERSONNEL MÉDICAL                                         │
├───────────────────────────────────────────────────────────┤
│ LoginScreen → saisit identifiantPro + motDePasse          │
│  → POST /auth/login-professionnel                         │
│  → Vérification BCrypt du mot de passe                    │
│  → Génération JWT (24h) avec rôle dans les claims         │
│  → Redirection vers l'écran du rôle                       │
└───────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────┐
│ PATIENT                                                   │
├───────────────────────────────────────────────────────────┤
│ LoginScreen → saisit email + motDePasse                   │
│  → POST /auth/login-patient                               │
│  → Vérification BCrypt du mot de passe                    │
│  → Génération JWT (24h) avec rôle PATIENT                 │
│  → Redirection vers /patient                              │
│                                                            │
│ OU (biométrie):                                           │
│  → POST /auth/login-biometrique                           │
│  → Vérification clé publique + signature                  │
│  → Génération JWT                                         │
└───────────────────────────────────────────────────────────┘
```

### 5.3 Flux de Données (Consultation Médecin)

```
1. AUTH
   Médecin → AuthScreen → login(doctor@..., mdp)
   → AuthNotifier.login() [SIMULÉ: 2s delay]
   → GoRouter redirige → /doctor

2. CHARGEMENT PASSAGES EN COURS
   DoctorScreen.initState() → mock data (3 dossiers)
   Tab 1: "Passages en cours" → liste avec statuts

3. SÉLECTION PATIENT
   Tap sur dossier → setState(_selectedPatient)
   → Tab 2: "Consultation"
   → Affichage carte patient gradient + antécédents + constantes

4. SAISIE MÉDICALE
   Diagnostic → _diagCtrl.text
   Ordonnance → _ordoCtrl.text
   → "Clôturer le passage"
   → [SIMULÉ: Future.delayed(1s)]
   → SnackBar "Passage cloturé"

5. VERS BACKEND (futur → remplacer mock par appels HTTP)
   PUT /passages/{id}/consultation
   Authorization: Bearer <JWT>
   Body: {
     "diagnostic": "Lombalgie aiguë",
     "prescriptionOrdonnance": "Paracetamol 1g x3/jour pendant 5 jours",
     "cloturerPassage": true
   }
   → 200 { message: "Dossier de consultation enregistré et archivé" }
```

---

## 6. Correspondance Frontend ↔ Backend

### 6.1 Modèles de Données

| Modèle Flutter | Entité JPA Backend | Correspondance |
|---------------|-------------------|----------------|
| `Patient` | `Patient.java` | ✅ Complète (champ pour champ) |
| `PersonnelMedical` | `PersonnelMedical.java` | ✅ Complète |
| `PassageMedical` | `PassageMedical.java` | ✅ Complète (sauf type UUID en String côté Flutter) |
| `ExamenLaboratoire` | `ExamenLaboratoire.java` | ✅ Complète |
| `User` (sealed) | — | ❌ Concept Flutter uniquement (union PatientUser/PersonnelUser) |
| — | `CarteNumerique` | ❌ **Manquant** côté Flutter |
| — | `Hopital` | ❌ **Manquant** côté Flutter |
| — | `LogTracabilite` | ❌ **Manquant** côté Flutter (back-office uniquement) |
| — | `PrescriptionMedicament` | ❌ **Manquant** côté Flutter (ordonnance gérée en texte libre) |

### 6.2 Endpoints API vs Écrans Flutter

| Méthode | Endpoint | Contrôleur | Screen Flutter associé | Statut |
|:--------|:---------|:-----------|:----------------------|:-------|
| `POST` | `/auth/login-professionnel` | AuthController | AuthScreen | ⚠️ Mocké |
| `POST` | `/auth/login-patient` | AuthController | AuthScreen | ❌ Non implémenté |
| `POST` | `/auth/register-patient` | AuthController | — | ❌ Non implémenté |
| `POST` | `/auth/enregistrer-biometrie` | AuthController | SettingsScreen | ❌ Non implémenté |
| `POST` | `/auth/login-biometrique` | AuthController | AuthScreen | ❌ Non implémenté |
| `POST` | `/admission/scan-carte` | AdmissionController | HomeScreen | ❌ Non implémenté |
| `POST` | `/admission/creer-passage` | AdmissionController | HomeScreen | ❌ Non implémenté |
| `GET` | `/patients/{id}/historique` | PatientController | PatientScreen, DoctorScreen | ❌ Non implémenté |
| `GET` | `/patients/{id}/qr-code` | PatientController | HomeScreen (scan) | ❌ Non implémenté |
| `GET` | `/patients/search?query=` | PatientController | HomeScreen | ❌ Non implémenté |
| `PUT` | `/passages/{id}/constantes` | PassageController | NurseScreen | ❌ Non implémenté |
| `PUT` | `/passages/{id}/consultation` | PassageController | DoctorScreen | ❌ Non implémenté |
| `GET` | `/passages/en-cours/{hopital}` | PassageController | DoctorScreen | ❌ Non implémenté |
| `POST` | `/laboratoire/ajouter-examen` | LaboratoireController | LabScreen | ❌ Non implémenté |
| `POST` | `/pharmacie/valider-prescription` | PharmacieController | PharmacistScreen | ❌ Non implémenté |
| `GET` | `/pharmacie/prescriptions/{passage}` | PharmacieController | PharmacistScreen | ❌ Non implémenté |
| `GET` | `/pharmacie/en-attente` | PharmacieController | PharmacistScreen | ❌ Non implémenté |
| `GET` | `/rapports/dashboard` | RapportController | — | ❌ Non implémenté |
| `POST` | `/personnel` | PersonnelController | — (admin) | ❌ Non implémenté |
| `POST` | `/hopitaux` | HopitalController | — (admin) | ❌ Non implémenté |

### 6.3 Écarts Identifiés

| # | Écart | Côté | Problème |
|---|-------|------|----------|
| 1 | **Auth mockée** | Flutter | `AuthNotifier.login()` utilise `Future.delayed(2s)` au lieu d'appeler `POST /auth/login-professionnel` |
| 2 | **Pas de distinction login personnel vs patient** | Flutter | Un seul endpoint `login-professionnel` documenté ; `login-patient` pas implémenté |
| 3 | **Pas de layer API/HTTP** | Flutter | Aucun service Dart ne fait d'appels HTTP (package `http` ou `dio` non installé) |
| 4 | **Pas de modèle `Hopital`** | Flutter | Les écrans utilisent `id_hopital` en `int` mais pas de structure dédiée |
| 5 | **Pas de modèle `CarteNumerique`** | Flutter | `qrCodeToken` géré côté backend uniquement |
| 6 | **Pas de modèle `PrescriptionMedicament`** | Flutter | L'ordonnance est un champ texte `prescriptionOrdonnance` ; le backend a une entité séparée |
| 7 | **Biométrie non câblée** | Flutter | L'UI montre des hints (AuthScreen, SettingsScreen) mais rien n'est connecté au capteur |
| 8 | **Scan QR non réel** | Flutter | `HomeScreen` a un UI de scanneur mais pas d'appel caméra réel |
| 9 | **Données mockées partout** | Flutter | Tous les écrans utilisent des listes mockées en dur (pas d'appels API) |

---

## 7. Base de Données

### 7.1 Schéma Entité-Relation

```
┌─────────────────────┐       ┌──────────────────────────────┐
│      patients       │       │     passages_medicaux         │
├─────────────────────┤       ├──────────────────────────────┤
│ PK  id_patient (UUID)│◄──────│ PK  id_passage (UUID)        │
│     nom             │ 1   N │ FK  id_patient (NOT NULL)     │
│     prenom          │───────│ FK  id_hopital (NOT NULL)     │
│     date_naissance  │       │ FK  id_createur (NOT NULL)    │
│     genre (CHAR 1)  │       │     date_admission (auto)     │
│     groupe_sanguin  │       │     motif_visite              │
│     telephone       │       │     constantes_vitales (JSONB)│
│     email (UNIQUE)  │       │     diagnostic (TEXT)         │
│     mot_de_passe_hash│      │     prescription_ordonnance   │
│     cle_publique_.. │       │     statut_passage (défaut:   │
│     cree_le (auto)  │       │       "en_cours")              │
└─────────┬───────────┘       └──────────────────────────────┘
          │ 1:1                     │
          │                         │ 1   N
┌─────────▼───────────┐       ┌────▼─────────────────────────┐
│  cartes_numeriques   │       │   examens_laboratoire        │
├─────────────────────┤       ├──────────────────────────────┤
│ PK  id_carte (SERIAL)│      │ PK  id_examen (SERIAL)        │
│ FK  id_patient (UQ)  │       │ FK  id_passage (NOT NULL)    │
│     qr_code_token(UQ)│       │ FK  id_laborantin (NOT NULL) │
│     statut (actif)   │       │     type_examen              │
│     expire_le        │       │     resultats (TEXT)         │
└─────────────────────┘       │     date_resultat (auto)      │
                              └──────────────────────────────┘
┌─────────────────────┐       ┌──────────────────────────────┐
│      hopitaux       │       │  prescriptions_medicaments    │
├─────────────────────┤       ├──────────────────────────────┤
│ PK  id_hopital(SERIAL)│     │ PK  id (SERIAL)              │
│     nom             │       │ FK  id_passage (NOT NULL)     │
│     adresse         │       │ FK  id_pharmacien             │
│     code_unique(UQ) │       │     medicament                │
└─────────┬───────────┘       │     posologie                 │
          │                   │     duree                     │
┌─────────▼───────────┐       │     delivre (false)           │
│  personnel_medical   │       │     date_validation (auto)   │
├─────────────────────┤       │     commentaire (TEXT)        │
│ PK  id_personnel     │       └──────────────────────────────┘
│     (SERIAL)         │
│ FK  id_hopital       │       ┌──────────────────────────────┐
│     nom              │       │    logs_tracabilite           │
│     prenom           │       ├──────────────────────────────┤
│     role             │       │ PK  id_log (SERIAL)           │
│     identifiant_pro  │       │     id_utilisateur            │
│       (UNIQUE)       │       │     id_patient (UUID)         │
│     mot_de_passe_hash│       │     action_effectuee          │
│     cle_publique_..  │       │     id_dossier_concerne(UUID)│
│     est_actif (true) │       │     adresse_ip                │
└─────────────────────┘       │     horodatage (auto)         │
                              └──────────────────────────────┘
```

### 7.2 Types de Données Particuliers

| Champ | Type PostgreSQL | Justification |
|-------|----------------|---------------|
| `id_patient` | `UUID` | Non-séquentiel (RGPD), pas d'inférence sur le nombre de patients |
| `id_passage` | `UUID` | Généré automatiquement par Hibernate |
| `constantes_vitales` | `jsonb` | Structure flexible (pas toujours les mêmes mesures) |
| `diagnostic` | `TEXT` | Contenu long et libre |
| `mot_de_passe_hash` | `VARCHAR(255)` | Hash BCrypt (60 chars min) |
| `id_personnel` | `SERIAL` (INT auto-incrément) | Usage interne, pas exposé au patient |

---

## 8. Sécurité

### 8.1 Authentification et JWT

```
┌──────────────────────────────────────────────────────────────────┐
│                  SPRING SECURITY FILTER CHAIN                      │
│                                                                    │
│  Requête HTTP                                                     │
│    ↓                                                              │
│  [1] JwtAuthenticationFilter (extends OncePerRequestFilter)       │
│    → Extrait le header "Authorization: Bearer <token>"             │
│    → Valide la signature JWT (HMAC-SHA256 avec secret base64)      │
│    → Extrait les claims (identité, rôle)                           │
│    → Crée UsernamePasswordAuthenticationToken dans SecurityContext │
│    → Continue la chaîne de filtres                                 │
│    ↓                                                              │
│  [2] Endpoint sécurisé (ex: /patients/{id}/historique)            │
│    → @SecurityRequirement(name = "BearerAuth")                     │
│    → Authentication authentication (injecté par Spring)            │
│    → authentication.getName() = identifiantPro de l'utilisateur    │
│    ↓                                                              │
│  [3] Service métier                                                │
│    → Vérifie les droits (rôle, existence entité)                   │
│    → Modifie les données                                           │
│    → LogService.logAction() → trace dans logs_tracabilite         │
└──────────────────────────────────────────────────────────────────┘
```

### 8.2 Sécurité des Mots de Passe

- Hash: **BCrypt** (via `PasswordEncoder` Spring Security)
- Force: Pas de validation de complexité côté backend (à implémenter)
- Réinitialisation: Endpoint `PUT /personnel/reset-password` (réservé ADMIN)

### 8.3 Sécurité des Données

- **Données sensibles**: `motDePasseHash` annoté `@JsonIgnore` → jamais sérialisé
- **Clés biométriques**: `clePubliqueBiometrique` et `clePubliqueAppareil` en `TEXT` (jamais exposées)
- **QR Token**: Encodé Base64 (non-chiffré — à améliorer en production)
- **CORS**: À configurer côté backend (non visible dans le code actuel)

### 8.4 Conformité RGPD

| Exigence RGPD | Implémentation |
|--------------|----------------|
| Pseudonymisation | UUID pour patients/passages (pas de séquentiel) |
| Traçabilité des accès | LogTracabilite enregistre toute action |
| Droit d'accès | `GET /patients/{id}/historique` |
| Droit à l'effacement | Non implémenté (suppression logique seulement) |
| Consentement | Non implémenté (checkbox/cgu à ajouter) |

---

## 9. État du Développement et Actions Prioritaires

### 9.1 État Actuel (Frontend Flutter)

| Catégorie | Statut | Détails |
|-----------|--------|---------|
| **UI/UX complète** | ✅ Terminé | 8 écrans, composants, thème, DESIGN.md |
| **Navigation** | ✅ Terminé | GoRouter 8 routes + guard auth |
| **State management** | ✅ Terminé | 3 providers Riverpod |
| **Modèles Dart** | ✅ Terminé | 5 modèles avec fromJson/toJson |
| **Diagrammes UML** | ✅ Terminé | 25 diagrammes (cas d'utilisation, classes, séquences, activités, C4) |
| **Documentation** | ✅ Terminé | README.md, DESIGN.md, GEMINI.md, RAPPORT_GLOBAL.md |
| **Authentification** | ⚠️ Mocké | `Future.delayed(2s)`, rôle déduit de l'email |
| **Intégration API** | ❌ Non fait | Aucun appel HTTP réel |
| **Données réelles** | ❌ Non fait | Tous les écrans utilisent des listes mockées en dur |
| **Scan QR réel** | ❌ Non fait | UI simulée sans caméra |
| **Biométrie** | ❌ Non fait | Hints UI seulement, pas de capteur |
| **Tests** | ❌ Non fait | Aucun test Flutter |

### 9.2 État Actuel (Backend Spring Boot)

| Catégorie | Statut | Détails |
|-----------|--------|---------|
| **Entités JPA** | ✅ Terminé | 8 entités avec relations et contraintes |
| **Contrôleurs REST** | ✅ Terminé | 10 contrôleurs avec Swagger |
| **Services métier** | ✅ Terminé | 9 services avec règles de gestion |
| **Sécurité JWT** | ✅ Terminé | Spring Security + JWT filter |
| **Traçabilité** | ✅ Terminé | LogService + LogTracabilite |
| **QR Code** | ✅ Terminé | ZXing génération + scan |
| **Pagination** | ✅ Terminé | PageResponse pour listes |
| **Tests** | ⚠️ Partiel | JUnit + Cucumber configurés |
| **application.properties** | ⚠️ Template | Fichier example à copier/configurer |
| **AdminController** | ⚠️ Vide | Classe créée mais pas encore implémentée |

### 9.3 Actions Prioritaires

#### 🔴 Priorité Haute (Intégration API Flutter ↔ Backend)

| # | Action | Impact | Effort | Fichiers concernés |
|---|--------|--------|--------|-------------------|
| 1 | **Ajouter dépendance HTTP** (`dio` ou `http`) | Prérequis API | Faible | `pubspec.yaml` |
| 2 | **Créer `ApiClient`** (singleton, intercepteur JWT) | Tous les appels API | Moyen | Nouveau fichier |
| 3 | **Câbler auth réel** : remplacer mock par `POST /auth/login-professionnel` et `POST /auth/login-patient` | Connexion réelle | Moyen | `auth_provider.dart` |
| 4 | **Créer service admission** : `POST /admission/scan-carte`, `POST /admission/creer-passage` | Admission réelle | Moyen | Nouveau fichier + `home_screen.dart` |
| 5 | **Créer service passage** : `PUT /passages/{id}/constantes`, `PUT /passages/{id}/consultation` | Constantes + consultation réelles | Moyen | Nouveau fichier + `nurse_screen.dart`, `doctor_screen.dart` |
| 6 | **Créer service laboratoire** : `POST /laboratoire/ajouter-examen` | Examens réels | Faible | Nouveau fichier + `lab_screen.dart` |
| 7 | **Créer service pharmacie** : `POST /pharmacie/valider-prescription`, `GET /pharmacie/en-attente` | Pharmacie réelle | Faible | Nouveau fichier + `pharmacist_screen.dart` |
| 8 | **Créer service patient** : `GET /patients/{id}/historique`, `GET /patients/search` | Historique + recherche | Faible | Nouveau fichier + `patient_screen.dart` |

#### 🟡 Priorité Moyenne (Fonctionnalités Manquantes)

| # | Action | Impact | Effort |
|---|--------|--------|--------|
| 9 | **Ajouter modèle `Hopital` côté Flutter** | Cohérence API | Faible |
| 10 | **Ajouter modèle `PrescriptionMedicament` côté Flutter** | Pharmacie complète | Faible |
| 11 | **Ajouter modèle `CarteNumerique` côté Flutter** | Gestion QR patient | Faible |
| 12 | **Implémenter scan QR réel** (package `mobile_scanner`) | Admission fluide | Moyen |
| 13 | **Implémenter biométrie réelle** (package `local_auth`) | Connexion rapide patient | Moyen |
| 14 | **Ajouter écran d'inscription patient** (`POST /auth/register-patient`) | Autonomie patient | Moyen |
| 15 | **Ajouter gestion des erreurs API** (timeout, 401 → relogin, 500 → message) | Robustesse | Moyen |

#### 🟢 Priorité Faible (Améliorations)

| # | Action | Effort |
|---|--------|--------|
| 16 | Ajouter refresh token (au lieu de login à 24h) | Élevé |
| 17 | Ajouter notifications push (Firebase Messaging) | Élevé |
| 18 | Ajouter tests unitaires Flutter (package `riverpod` testing) | Moyen |
| 19 | Ajouter tests d'intégration Flutter | Moyen |
| 20 | Ajouter chiffrement des tokens en local (flutter_secure_storage) | Faible |
| 21 | Ajuler déploiement Docker (docker-compose avec API + DB) | Faible |
| 22 | Implementer AdminController backend | Faible |
| 23 | Ajouter validation complexité mot de passe | Faible |

### 9.4 Recommandation Immédiate

La priorité #1 est de créer le **layer de services API** côté Flutter :

```
lib/
└── core/
    └── network/
        ├── api_client.dart          # Dio + intercepteur JWT
        ├── api_exceptions.dart      # Gestion d'erreurs centralisée
        └── endpoints.dart           # Constantes des URLs
```

Puis de remplacer chaque mock écran par écran, en commençant par l'authentification (flux critique).

---

## 10. Diagrammes UML

25 diagrammes disponibles dans `diagrams/` au format PlantUML (.puml) + PNG.

### 10.1 Cas d'Utilisation

| Fichier | Contenu |
|---------|---------|
| `01_cas_utilisation.puml` | 15 use cases, 7 acteurs, relations UML 2.0, groupes logiques |

**Acteurs :** Patient, Agent d'Admission, Médecin, Infirmier, Laborantin, Pharmacien, Admin  
**UC clés :** S'authentifier, Scanner QR, Créer passage, Saisir constantes, Consulter, Diagnostiquer, Prescrire, Clôturer, Analyser, Délivrer, Gérer personnel, Gérer hôpitaux, Voir rapports

### 10.2 Diagramme de Classes

| Fichier | Contenu |
|---------|---------|
| `02_diagramme_classes.puml` | 3 packages : Modèles Flutter, Contrôleurs Spring Boot, Entités JPA |

### 10.3 Diagrammes de Séquence (13)

| Fichier | Scénario |
|---------|----------|
| `03_sequence_01` | Scan QR et identification patient |
| `03_sequence_02` | Création d'un passage médical |
| `03_sequence_03` | Connexion par biométrie |
| `03_sequence_04` | Enregistrement biométrique |
| `03_sequence_05` | Consultation historique patient |
| `03_sequence_06` | Diagnostic médical |
| `03_sequence_07` | Prescription d'ordonnance |
| `03_sequence_08` | Clôture d'un passage |
| `03_sequence_09` | Saisie constantes vitales |
| `03_sequence_10` | Ajout résultats de laboratoire |
| `03_sequence_11` | Délivrance médicaments pharmacie |
| `03_sequence_12` | Consultation carnet patient |
| `03_sequence_13` | Administration (gestion personnel/hôpitaux) |

### 10.4 Diagrammes d'Activité (7)

| Fichier | Parcours |
|---------|----------|
| `04_activite_global` | Parcours patient global (arrivée → clôture) |
| `04_activite_01` | Authentification (mot de passe + biométrique) |
| `04_activite_02` | Admission patient (scan QR → création passage) |
| `04_activite_03` | Consultation médicale complète |
| `04_activite_04` | Laboratoire (prélèvement → analyse → résultats) |
| `04_activite_05` | Pharmacie (validation ordonnance → délivrance) |
| `04_activite_06` | Biométrie (enregistrement + réutilisation connexion) |

### 10.5 Diagrammes C4 (3)

| Fichier | Niveau |
|---------|--------|
| `05_c4_contexte` | Contexte système : acteurs + MindCare |
| `05_c4_conteneurs` | Conteneurs : 2 apps mobiles + API + DB |
| `05_c4_composants` | Composants : contrôleurs, services, repositories |

---

## Annexes

### A. Commandes Utiles

```bash
# Flutter
flutter run                           # Lancer l'application
flutter analyze                       # Vérifier le code Dart
flutter test                          # Lancer les tests

# Backend
./gradlew bootRun                     # Démarrer Spring Boot sur :8081
./gradlew test                        # Lancer les tests backend
./gradlew jacocoTestReport            # Rapport de couverture

# Diagrammes
java -jar diagrams/plantuml.jar -tpng diagrams/*.puml

# Base de données
psql -U postgres -d care_db           # Connexion PostgreSQL
```

### B. Dépendances Clés

| Package Flutter | Version | Rôle |
|----------------|---------|------|
| `flutter_riverpod` | ^2.5.1 | State management |
| `go_router` | ^14.1.4 | Navigation déclarative |
| `shared_preferences` | ^2.2.3 | Stockage local |
| `google_fonts` | ^6.2.1 | Typographie |
| `hugeicons` | ^1.1.7 | Icônes |
| `dio` | **À ajouter** | HTTP client |
| `mobile_scanner` | **À ajouter** | Scan QR caméra |
| `local_auth` | **À ajouter** | Biométrie |
| `flutter_secure_storage` | **À ajouter** | Stockage sécurisé tokens |

### C. Écrans de Test (Emails Mock)

| Email | Rôle | Route |
|-------|------|-------|
| `patient@mindcare.com` | Patient | `/patient` |
| `doctor@mindcare.com` | Médecin | `/doctor` |
| `nurse@mindcare.com` | Infirmier | `/nurse` |
| `lab@mindcare.com` | Laborantin | `/lab` |
| `pharm@mindcare.com` | Pharmacien | `/pharmacist` |
| `agent@mindcare.com` | Agent admission | `/home` |

---

*Document généré le 12/06/2026 — MindCare v1.0.0*

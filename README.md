# 🇹🇩 E-Santé Tchad

Application mobile et web de santé numérique dédiée au Tchad, facilitant l'accès aux soins et la gestion de la santé pour tous les Tchadiens.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 📋 Table des matières

- [À propos](#-à-propos)
- [Fonctionnalités](#-fonctionnalités)
- [Captures d'écran](#-captures-d'écran)
- [Technologies](#-technologies)
- [Installation](#-installation)
- [Utilisation](#-utilisation)
- [Structure du projet](️-structure-du-projet)
- [Contribution](#-contribution)
- [Licence](#-licence)

## 🌍 À propos

E-Santé Tchad est une application de santé numérique conçue spécifiquement pour répondre aux besoins de la population tchadienne. Elle offre une suite complète d'outils pour la gestion de la santé personnelle, l'accès aux informations médicales, et la prévention des maladies courantes dans la région.

**Objectifs :**
- Améliorer l'accès aux informations de santé
- Faciliter la gestion des dossiers médicaux
- Promouvoir la prévention des maladies
- Assister les populations rurales et urbaines

## ✨ Fonctionnalités

### 📋 Dossier Médical Personnel
- Gestion complète des dossiers médicaux
- Historique des consultations et traitements
- Stockage sécurisé des informations de santé
- Export et partage des données médicales

### 🤖 Assistant IA de Symptômes
- Analyse intelligente des symptômes
- Suggestions de premiers soins
- Orientation vers les structures de santé appropriées
- Base de connaissances adaptée au contexte tchadien

### 💊 Rappel de Médicaments
- Programmation des prises de médicaments
- Notifications personnalisées
- Suivi de l'observance thérapeutique
- Gestion des stocks de médicaments
- Profils familiaux multiples

### 🗺️ Carte des Structures de Santé
- Cartographie interactive des centres de santé
- Informations détaillées (horaires, services, contacts)
- Itinéraires vers les structures les plus proches
- Filtrage par type de structure
- Couverture de N'Djamena, Abéché et autres villes

### 👶 Suivi Maternel & Infantile
- Suivi des grossesses (dates importantes, visites prénatales)
- Calendrier de vaccination des enfants
- Suivi de la croissance et du développement
- Alertes et rappels automatiques
- Graphiques de progression

### 🏥 Maladies Chroniques
- Gestion du diabète, hypertension, etc.
- Suivi des paramètres vitaux
- Historique des traitements
- Rapports de suivi pour les médecins

### 🛡️ Prévention & Conseils
- Conseils de prévention pour les maladies courantes au Tchad
- Maladies couvertes : Choléra, Typhoïde, Diarrhées, Paludisme, Dengue, Méningite, Tuberculose, VIH/SIDA
- Conseils par catégorie : Nutrition, Hygiène, Exercice, Santé mentale, Environnement
- Recherche et filtrage par catégorie
- Favoris pour un accès rapide

## 📸 Captures d'écran

*(Ajouter des captures d'écran de l'application)*

## 🛠️ Technologies

- **Framework** : Flutter 3.x
- **Langage** : Dart 3.x
- **Base de données locale** : Hive (NoSQL)
- **Architecture** : MVVM avec Hive
- **Design** : Material Design 3
- **Plateformes** : Web, Android, iOS

## 📦 Installation

### Prérequis

- Flutter SDK 3.0 ou supérieur
- Dart SDK 3.0 ou supérieur
- Android Studio / VS Code
- Git

### Étapes d'installation

1. **Cloner le dépôt**
```bash
git clone https://github.com/votre-username/e-sante.git
cd e-sante
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Générer les adapters Hive**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🚀 Utilisation

### Exécution sur Chrome (Web)
```bash
flutter run -d chrome
```

### Exécution sur Android
```bash
flutter run -d android
```

### Exécution sur iOS
```bash
flutter run -d ios
```

### Build APK pour Android
```bash
flutter build apk --release
```

L'APK sera généré dans : `build/app/outputs/flutter-apk/app-release.apk`

## 📁 Structure du projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── models/                   # Modèles de données Hive
│   ├── user_model.dart
│   ├── dossier_model.dart
│   ├── medicament_model.dart
│   ├── sante_maternelle_model.dart
│   └── prevention_model.dart
├── screens/                  # Écrans d'authentification et home
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── home/
│       └── home_screen.dart
├── pages/                    # Pages principales de l'application
│   ├── dossier_medical_page.dart
│   ├── ia_symptomes_page.dart
│   ├── rappel_medicaments_page.dart
│   ├── carte_structures_page.dart
│   ├── sante_maternelle_page.dart
│   ├── maladies_chroniques_page.dart
│   └── prevention_conseils_page.dart
├── utils/                    # Utilitaires et configurations
│   ├── colors.dart
│   └── ...
└── services/                 # Services et logique métier
```

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📝 Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👩‍💻 Auteure
**Achta** — Développeuse principale  
licencie  — abeche, Tchad 🇹🇩  
almasssousou4@gmail.com

## 🙏 Remerciements

- À la communauté Flutter pour l'excellent framework
- À tous les contributeurs qui ont rendu ce projet possible

## 📞 Contact

Pour toute question ou suggestion, n'hésitez pas à nous contacter :
- 📧 Email : almasssousou4@gmail.com
- 🐙 GitHub : github.com/achtou/e_sante-tchad
---

**Développé avec ❤️ pour le Tchad**

# مُلّاك (Mullak)

An AI-supported Android mobile application that connects business owners with commercial property owners in Riyadh. Business owners can find suitable commercial properties and land based on their business requirements, and property owners can list their properties and estimate suitable rental prices.

**IT 496 Graduation Project, King Saud University, College of Computer and Information Sciences, IT Department**
Group 26, supervised by Dr. Lama Alsudias

| Team member | Student ID |
|---|---|
| Alhanouf Almusnad | 445202268 |
| Latifah Almousa | 445200360 |
| Ghala Almshegheh | 445202218 |
| Salam Alqahtani | 445202246 |

---

## Features

Completed in Release 1:
- User registration and logout
- Exploring and filtering commercial properties
- Property details, saving, and side-by-side comparison
- Interactive map and heat map with filtering options
- Live chat between business owners and property owners
- Adding, editing, and deleting property listings (property owners)
- Reviews and issue reporting

Planned for Release 2:
- Login with OTP verification (in progress)
- Property recommendations ranked by a Location Suitability Score
- AI-based rental price estimation
- Smart alerts and notifications

---

## Technology stack

| Component | Technology |
|---|---|
| Mobile app | Flutter (Dart SDK ^3.11.1), Android |
| Authentication | Firebase Authentication |
| Main database | PostgreSQL (Cloud SQL) accessed through Firebase SQL Connect |
| Chat | Cloud Firestore |
| Images | Cloud Storage for Firebase |
| Maps | flutter_map with OpenStreetMap tiles |
| Data preparation and AI models | Python, Google Colab |

---

## Repository structure

```
2026-GP1-26/
├── QI_Neighborhood_Data.xlsx     Neighborhood dataset used for model development
└── mullak/                       Flutter application
    ├── lib/
    │   ├── main.dart             App entry point
    │   ├── screens/              UI screens (authentication, chat, map,
    │   │                         notifications, property_discovery,
    │   │                         property_management)
    │   ├── services/             Business logic and Firebase services
    │   ├── repositories/         Data access layer
    │   ├── models/               Data models
    │   ├── dataconnect_generated/  Generated SQL Connect SDK
    │   ├── widgets/, theme/, constants/, utils/, data/
    ├── dataconnect/              SQL Connect schema, queries, and seed data
    ├── firestore.rules           Security rules for the chat collections
    ├── assets/                   Images and heat map data
    └── test/                     Unit tests
```

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) with Dart 3.11.1 or later
- Android Studio with the Android SDK, and an Android emulator or a physical Android device
- [Firebase CLI](https://firebase.google.com/docs/cli) (only needed to deploy schema or rules, or to run the emulators)
- Visual Studio Code with the Firebase SQL Connect extension (optional, for editing the database schema)

---

## Setup and running

1. **Clone the repository**
   ```bash
   git clone https://github.com/AlhanoufIB/2026-GP1-26.git
   cd 2026-GP1-26/mullak
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase configuration**
   The app is already connected to the team's Firebase project (`mullak-gp26`) through `lib/firebase_options.dart` and `android/app/google-services.json`, so no extra configuration is needed to run it.

4. **Start an emulator or connect a device**, then check it is detected:
   ```bash
   flutter devices
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

6. **Run the tests**
   ```bash
   flutter test
   ```

### Database (optional)

The PostgreSQL schema and queries are in `mullak/dataconnect/`. To regenerate the Dart SDK after changing the schema or queries:
```bash
firebase dataconnect:sdk:generate
```
To deploy the schema, queries, and Firestore rules (team members with project access only):
```bash
firebase deploy --only dataconnect,firestore
```

---

## Data sources

- **Suhail:** real estate market and rental data for selected Riyadh neighborhoods, provided at the team's request for academic use
- **RCRC Open Data Portal:** commercial activity and land-use data for Riyadh

The data is used for academic, non-commercial purposes only.

# GymLife v2

> A fitness gym membership app built with Flutter and Firebase — browse gym news, order Silver / Gold / Platinum memberships, and manage your membership status.

GymLife v2 is a clean rewrite of the original UAS project. It uses **Firebase Authentication** and **Firebase Realtime Database** with a professional folder structure, security rules, and dummy seed data.

## Screenshots

_(Screenshots will be added here.)_

---

## Features

- **Authentication** — sign up, sign in, and password reset with role-based access (admin / customer)
- **Gym News** — browse the latest news (Promo, Acara, Jadwal Kelas, Info Umum) on the home page
- **Membership Plans** — order Silver, Gold, or Platinum memberships with full benefits details
- **Cart & QR Payment** — add a plan to the cart, generate a QR invoice, and confirm cash payment at the front desk
- **Membership Status** — view your active membership type, expiry date, and status (active / expired)
- **Workout Guides** — watch exercise tutorial videos (push up, sit up, pull up) via embedded YouTube player
- **Gym Locations** — find branch locations with address, opening hours, phone, and a "Open in Google Maps" shortcut
- **Profile** — edit name, bio, and gender; set a profile photo from gallery/camera; change password
- **Admin Panel** — add/edit/delete gym news, view all members with membership type, upgrade/downgrade levels, and cancel memberships

---

## Built With

- **Flutter** — cross-platform UI framework (Dart)
- **Firebase** — Authentication (Email/Password) and Realtime Database
- **image_picker** — profile photo from gallery/camera
- **qr_flutter** — QR invoice generation
- **youtube_player_iframe** — embedded workout videos

---

## Demo Accounts

| Role | Email | Password | Access |
|---|---|---|---|
| Admin | `admin@gymlife.app` | _(set during setup)_ | Manage news, view & manage all members |
| Customer | create your own via **Register** | — | Order memberships, view status, profile |

> The admin account is **not** created through the app. See [Firebase setup](#firebase-setup) to seed it.

---

## Getting Started

### Prerequisites

- Flutter 3.38+ (Dart 3.10+)
- A Firebase project with **Authentication (Email/Password)** and **Realtime Database** enabled

### 1. Create a new Firebase project in the [Firebase console](https://console.firebase.google.com):

   - Add a **Web app** and register it (for the web build).
   - Add an **Android app** with package `com.codemelvin.gymlife_v2` (and your debug SHA-1 for local builds).
   - Add an **iOS app** with bundle id `com.codemelvin.gymlifeV2`.
   - Enable **Authentication → Sign-in method → Email/Password**.
   - Create a **Realtime Database** (region `asia-southeast1` for Indonesia).

2. The Firebase credentials are **not committed** to this repository (same approach as Lingua). They are injected at build time via `--dart-define`. Get the values from **Project settings → Your apps**, then build/run with:

   ```sh
   flutter run \
     --dart-define=FIREBASE_WEB_API_KEY=... \
     --dart-define=FIREBASE_WEB_APP_ID=... \
     --dart-define=FIREBASE_ANDROID_API_KEY=... \
     --dart-define=FIREBASE_ANDROID_APP_ID=... \
     --dart-define=FIREBASE_IOS_API_KEY=... \
     --dart-define=FIREBASE_IOS_APP_ID=... \
     --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
     --dart-define=FIREBASE_PROJECT_ID=... \
     --dart-define=FIREBASE_AUTH_DOMAIN=... \
     --dart-define=FIREBASE_DATABASE_URL=... \
     --dart-define=FIREBASE_STORAGE_BUCKET=... \
     --dart-define=FIREBASE_WEB_MEASUREMENT_ID=...
   ```

   > Without these defines the app compiles but cannot connect to Firebase.

### 2. Deploy database rules

```sh
npm install -g firebase-tools
firebase login
firebase deploy --only database
```

Or copy the contents of `firebase.rules.json` into **Realtime Database → Rules** in the console.

### 3. Seed dummy data

Import `seed_data.json` from the console (**Realtime Database → Data → "import JSON"**, merge mode), or:

```sh
firebase database:update / --data seed_data.json
```

### 4. Seed the admin account

1. In **Authentication → Users**, add the admin manually (email + password).
2. Open **Realtime Database**, add a node:

```
accounts
  └─ <admin-uid>
       ├─ email: "<admin-email>"
       ├─ username: "Admin GymLife"
       └─ role: "admin"
```

Replace `<admin-uid>` with the uid from Authentication → Users.

### 5. Run the app

```sh
flutter run            # device / emulator
flutter run -d chrome  # web
```

---

## Deployment (Vercel)

Build the web app **with your Firebase config injected**, then upload `build/web` to Vercel (framework preset: **Other**). The included `vercel.json` rewrites all routes to `index.html` for client-side routing.

```sh
flutter build web --release \
  --dart-define=FIREBASE_WEB_API_KEY=... \
  --dart-define=FIREBASE_WEB_APP_ID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_PROJECT_ID=... \
  --dart-define=FIREBASE_AUTH_DOMAIN=... \
  --dart-define=FIREBASE_DATABASE_URL=... \
  --dart-define=FIREBASE_STORAGE_BUCKET=... \
  --dart-define=FIREBASE_WEB_MEASUREMENT_ID=...
```

---

## Project Structure

```
lib/
├── main.dart                  # app entry, routes, theme
├── constants.dart             # shared constants
├── firebase_options.dart      # per-platform Firebase config
├── models/                    # MembershipPlan, NewsItem, UserProfile, GymLocation
├── services/                  # AuthService, DatabaseService, CartManager
├── screens/
│   ├── auth/                  # login, register, forgot password
│   ├── home/                  # home, membership, cart, invoice, exercise, location, profile
│   └── admin/                 # dashboard, manage news, manage members
└── widgets/                   # shared UI (CustomField)
```

---

## Realtime Database Structure

```
accounts/{uid}                { email, username, role, createdAt }
users/{uid}                   { name, email, description, gender, profileImage,
                                activeMembership, membershipId, membershipExpiry, createdAt }
gym_news/{key}                { title, content, category, date }
membership_plans/{id}         { id, name, price, durationDays, benefits[], image }
gym_locations/{id}            { id, name, address, phone, hours, imageUrl }
```

---

## License

This project is created for academic and portfolio purposes. UI/UX references are listed in the original UAS report.

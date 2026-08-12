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

### 1. Clone & configure Firebase

```sh
git clone https://github.com/CodeMelvin/GymLife-v2.git
cd GymLife-v2
flutter pub get
```

Create a new Firebase project in the [Firebase console](https://console.firebase.google.com):

1. Add a **Web app** and register it (for the web build).
2. Add an **Android app** with package `com.codemelvin.gymlife_v2` (and your debug SHA-1 for local builds).
3. Add an **iOS app** with bundle id `com.codemelvin.gymlifeV2`.
4. Enable **Authentication → Sign-in method → Email/Password**.
5. Create a **Realtime Database** (region `asia-southeast1` for Indonesia).
6. Generate the config file:

```sh
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-project-id>
```

This writes the real values into `lib/firebase_options.dart`.

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

```sh
flutter build web --release
```

Then upload the `build/web` folder to Vercel (framework preset: **Other**). The included `vercel.json` rewrites all routes to `index.html` for client-side routing.

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

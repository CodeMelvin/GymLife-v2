# 💪 GymLife v2

> A fitness gym membership app built with Flutter and Firebase — browse gym news, order Silver / Gold / Platinum memberships, and manage your membership status.

## 📸 Screenshots

_(Screenshots will be added here.)_

---

## ✨ Features

- 🔐 **Authentication** — sign up, sign in, and password reset with role-based access (admin / customer)
- 📰 **Gym News** — browse the latest news (Promo, Acara, Jadwal Kelas, Info Umum) on the home page
- 🏷️ **Membership Plans** — order Silver, Gold, or Platinum memberships with full benefits details
- 🛒 **Cart & QR Payment** — add a plan to the cart, generate a QR invoice, and confirm cash payment at the front desk
- 📅 **Membership Status** — view your active membership type, expiry date, and status (active / expired)
- 🏋️ **Workout Guides** — watch exercise tutorial videos (push up, sit up, pull up) via embedded YouTube player
- 📍 **Gym Locations** — find branch locations with address, opening hours, phone, and a "Open in Google Maps" shortcut
- 👤 **Profile** — edit name, bio, and gender; set a profile photo from gallery/camera; change password
- ⚙️ **Admin Panel** — add/edit/delete gym news, view all members with membership type, upgrade/downgrade levels, and cancel memberships

---

## 🛠️ Built With

- 🟣 **Flutter** — cross-platform UI framework (Dart)
- 🔥 **Firebase** — Authentication (Email/Password) and Realtime Database
- 📷 **image_picker** — profile photo from gallery/camera
- 📱 **qr_flutter** — QR invoice generation
- ▶️ **youtube_player_iframe** — embedded workout videos

---

## 🔑 Demo Accounts

| Role | Email | Password | Access |
|---|---|---|---|
| Admin | `admin@gymlife.app` | `GymAdmin@2026` | Manage news, view & manage all members |
| Customer | `demo@gymlife.app` | `Demo123456!` | Order memberships, view status, profile |

You can also register a new account from the **Register** screen (role: customer).

---

## 🚀 Getting Started

### Option A - Try it online (fastest)

Open the live web demo: **[https://gymlife-v2.vercel.app](https://gymlife-v2.vercel.app)** — no install needed.

### Option B - Install the APK

Build the APK (see **Option D**), or grab a release APK from the [Releases](../../releases) section and install it on any Android device (Android 8.0+). The app connects to the project's Firebase backend.

### Option C - Run with VS Code

1. Install [Flutter](https://docs.flutter.dev/get-started/install) and the **Flutter** extension in VS Code
2. Open the project folder in VS Code: `File → Open Folder`
3. Connect an Android device (USB debugging) or start an Android emulator
4. Press `F5` (or the **Run ▸ Start Debugging** menu) with `lib/main.dart` open
5. Alternatively, run `flutter run` in the terminal
6. Log in with a demo account, or create a new account from the **Register** screen (role: customer)

> 💡 GymLife v2 is cross-platform: Firebase is configured for **Android**, **Web**, **iOS**, and **macOS** (single project). On Android use an emulator/device; for the web version pick Chrome/Edge in VS Code (`flutter run -d chrome`).

### Option D - Build from the command line

```bash
flutter pub get
flutter run                       # run on a connected device/emulator
flutter build apk --release       # build the release APK
```

> ⚠️ To build against **your own** Firebase backend, add the `--dart-define` flags shown in the next section. A plain build uses placeholder values and will not connect.

---

## 🗄️ Using Your Own Firebase Database

The app's Firebase credentials are **not committed** to this repository — they are injected at build time via `--dart-define` (see `lib/firebase_options.dart`). To point the app at **your own** Firebase backend:

**Option A — recommended (FlutterFire CLI):**

1. Install the CLI: `dart pub global activate flutterfire_cli` (or use the bundled `flutterfire_cli` dev dependency)
2. Create a project at [Firebase Console](https://console.firebase.google.com/) and add an **Android app** with package name `com.codemelvin.gymlife_v2`
3. Run `flutterfire configure` from the project root and select your project — this regenerates `lib/firebase_options.dart` and `android/app/google-services.json` with your values
4. In **Authentication → Sign-in method**, enable **Email/Password**
5. In **Realtime Database**, create a database (region `asia-southeast1` for Indonesia) and apply the security rules from [`firebase.rules.json`](firebase.rules.json)
6. Optionally import the seed data from [`seed_data.json`](seed_data.json) (nodes: `membership_plans`, `gym_locations`, `gym_news`)

**Option B — build-time environment variables:**

Pass your own project values when building:

```
flutter build web --release \
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

(Web builds use `FIREBASE_WEB_API_KEY` / `FIREBASE_WEB_APP_ID` / `FIREBASE_WEB_MEASUREMENT_ID`.) This keeps credentials out of the source tree entirely — convenient for CI or hosting platforms like Vercel, where secrets live in environment variables.

> **Note:** `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `macos/Runner/GoogleService-Info.plist`, and `firebase.json` are git-ignored and never pushed.

The security rules live in **`firebase.rules.json`** at the project root. They keep user data isolated: a user can only read and write their own account and membership records, while the admin role is assigned manually in the Firebase Console (Authentication → Users, then add `accounts/{uid}` → `role: "admin"`). Users cannot promote themselves.

### Seeding the admin account

The admin is **not** created through the app. In the Firebase Console:

1. **Authentication → Users**, add the admin manually (email + password).
2. Open **Realtime Database**, add a node:

```
accounts
  └─ <admin-uid>
       ├─ email: "<admin-email>"
       ├─ username: "Admin GymLife"
       └─ role: "admin"
```

Replace `<admin-uid>` with the uid from Authentication → Users.

---

## 📁 Project Structure

```
gymlife_v2/
├── lib/
│   ├── constants.dart               # App constants (identifier, membership levels, news categories)
│   ├── firebase_options.dart        # Firebase project configuration
│   ├── main.dart                    # Entry point & routes
│   ├── models/                      # MembershipPlan, NewsItem, UserProfile, GymLocation
│   ├── services/                    # AuthService, DatabaseService, CartManager
│   ├── screens/
│   │   ├── auth/                    # Slider, login, register, forgot password
│   │   ├── home/                    # Home, membership, cart, invoice, exercise, location, profile
│   │   └── admin/                   # Dashboard, manage news, manage members
│   └── widgets/                     # Shared UI (CustomField)
├── seed_data.json                   # Dummy data for membership plans, locations, and news
└── firebase.rules.json              # Realtime Database security rules
```

---

## 🗃️ Realtime Database Structure

```
accounts/{uid}                { email, username, role, createdAt }
users/{uid}                   { name, email, description, gender, profileImage,
                                activeMembership, membershipId, membershipExpiry, createdAt }
gym_news/{key}                { title, content, category, date }
membership_plans/{id}         { id, name, price, durationDays, benefits[], image }
gym_locations/{id}            { id, name, address, phone, hours, imageUrl }
```

---

## 📝 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Melvin** ([@CodeMelvin](https://github.com/CodeMelvin))

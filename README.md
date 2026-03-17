# Superset Firebase Project

##**Webiste**
https://fih-superset-dev.web.app/

## Overview

Superset Firebase is a full-stack Flutter application integrated with Firebase to support real-time data operations, user authentication, and cross-platform functionality. The project is tailored for Android, iOS, and Web platforms with seamless integration of Firebase Realtime Database.

This repository contains everything needed to run and modify the project.

---

## Features

- **Authentication**: Secure sign-up and login functionality.
- **Real-Time Database**: Dynamic data synchronization using Firebase Realtime Database.
- **Cross-Platform Support**:
  - Android
  - iOS
  - Web
- **Web Integration**:
  - Responsive UI for web deployment.
  - Firebase Hosting for live web applications.
- **Scalability**: Built to easily adapt additional Firebase services.

---

## Prerequisites

To work with this project, ensure you have the following:

1. **Flutter SDK**: Installed and configured. Download [here](https://flutter.dev/docs/get-started/install).
2. **Firebase Project**: Set up a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
3. **Firebase Configuration Files**:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)
   - Web Firebase configuration snippet.
4. **Git**: Installed for version control.

---

## Installation and Setup

### 1. Clone the Repository

```bash
git clone https://github.com/Pujithakallu/supersetfirebase.git
cd supersetfirebase
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Firebase Configuration

#### Android:

Place `google-services.json` in the `android/app` directory.

#### iOS:

Place `GoogleService-Info.plist` in the `ios/Runner` directory.

#### Web:

Add the Firebase config snippet to `web/index.html`:

```javascript
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_AUTH_DOMAIN",
  databaseURL: "YOUR_DATABASE_URL",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_STORAGE_BUCKET",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID",
  measurementId: "YOUR_MEASUREMENT_ID",
};
```

### 4. Run the Application

#### For Mobile (Android/iOS):

```bash
flutter run
```

#### For Web:

```bash
flutter run -d chrome
```

---

## Firebase Hosting (Web Deployment)

### Initialize Firebase Hosting:

```bash
firebase init hosting
```

Follow the prompts to configure the hosting service.

### Deploy the Web App:

```bash
firebase deploy
```

Access the deployed app via the provided Firebase Hosting URL.

---

## Folder Structure

Here's a breakdown of the project's folder structure:

- `android`: Contains Android-specific configurations.
- `ios`: Contains iOS-specific configurations.
- `lib`:
  - Main Flutter application code.
  - `screens/`: Includes UI screens such as Login and Signup.
  - `services/`: Business logic and Firebase interactions.
- `web`: Contains the web platform files, including `index.html`.
- `assets`: Stores images and other static files.
- `test`: Unit and widget tests.

---

## Key Files

- `pubspec.yaml`: Manages dependencies and assets.
- `google-services.json`: Firebase configuration for Android.
- `GoogleService-Info.plist`: Firebase configuration for iOS.
- `index.html`: Web platform's entry point.

---

## Troubleshooting

### Common Issues

1. **Firebase API Key Missing**:

   Ensure the Firebase configuration is properly added in respective platform files.

2. **Flutter Dependencies Not Installed**:

   Run:

   ```bash
   flutter pub get
   ```

3. **Error in Web Deployment**:

   Verify Firebase Hosting setup with:

   ```bash
   firebase init hosting
   ```

---

## Contributing

1. Fork the repository.
2. Create a feature branch:

   ```bash
   git checkout -b feature/your-feature
   ```

3. Commit changes:

   ```bash
   git commit -m "Add your message here"
   ```

4. Push the branch:

   ```bash
   git push origin feature/your-feature
   ```

5. Open a pull request.

---

## License

This project is licensed under the MIT License. See the LICENSE file for details.

---

## Contact

For any inquiries or contributions, reach out to pujithakallu.21@gmail.com, prasannapsand@gmail.com, maddurisriram09@gmail.com.

---

## Author
Pujitha Kallu, Prasanna Sand, Sriram Madduri


# 📱 KajjaFisio Mobile App

**KajjaFisio Mobile App** is an Android application built with **Flutter** and **Firebase**.  
This app is designed to help users book **home physiotherapy (home therapy)** services easily through their mobile devices.

The project is lightweight, clean, and simple to modify — perfect for developers who want to use or extend it.

---

## 🚀 Features

- 📅 Book home physiotherapy sessions  
- 👤 User authentication (Login & Register) using Firebase  
- 🔥 Firebase Realtime Database / Firestore for storing booking data  
- 📍 Real-time updates  
- 🎨 Modern and clean UI  
- ⚡ Fast performance (built with Flutter)

---

## 🛠️ Technologies Used

- **Flutter (Dart)**
- **Firebase Authentication**
- **Firebase Firestore / Realtime Database**
- **Firebase Storage** (if used for images)
- **Material Design Components**

---

## 📁 Project Structure

```
KajjaFisioApp/
│
├── lib/
│ ├── screens/ # App pages (login, booking, dashboard, etc.)
│ ├── widgets/ # Reusable UI components
│ ├── services/ # Firebase services
│ ├── models/ # Data models
│ └── main.dart # Entry point of the app
│
├── android/ # Android native configuration
├── ios/ # iOS native configuration
├── assets/ # Images, fonts
├── pubspec.yaml # Flutter dependencies & configurations
```

## 📘 How to Use This Project (For Other Developers)

Follow these steps to run this project on your device or emulator.

---

## 1️⃣ Requirements

Make sure you have installed:

- Flutter SDK → https://docs.flutter.dev/get-started/install  
- Android Studio (for emulator + platform tools)  
- VS Code (optional but recommended)  
- Git  

Check your Flutter setup:
flutter doctor

---

## 2️⃣ Clone the Repository
git clone https://github.com/realarik/MobileApp-KajjaFisio.git
cd MobileApp-KajjaFisio


---

## 3️⃣ Install Dependencies
flutter pub get

---

## 4️⃣ Setup Firebase (IMPORTANT)

This project uses Firebase.  
To connect your own Firebase project, follow these steps:

### **Step 1 — Create Firebase project**
https://console.firebase.google.com/

### **Step 2 — Add Android app**
You will need:

- Android package name  
- `google-services.json`

### **Step 3 — Download the `google-services.json`**
Place it inside:
android/app/google-services.json


### **Step 4 — Enable required Firebase services**

- Firebase Authentication  
- Firestore Database / Realtime Database  
- Firebase Storage (optional)

### **Step 5 — Add FlutterFire packages**

Already included in `pubspec.yaml`, but you can check with:
flutter pub get
flutterfire configure

---

## 5️⃣ Run the Application

Start an Android emulator or connect a real device.

Then run:
flutter run


The app should launch successfully.

---

## 6️⃣ Build APK

### Debug APK:
flutter build apk

### Release APK:
flutter build apk --release

Find the APK here:
build/app/outputs/flutter-apk/

---


## 🤝 Contributing

This project is private.  
External contributions are not accepted unless approved by the owner.

---

## 📄 License

This project is fully created and owned by realarik.
All rights reserved.

No part of this project may be copied, modified, distributed, or used commercially
without explicit permission from the owner.

---


## 💬 Contact

Developer: **realarik**  
Email: **candrikakalandra@gmail.com**

Feel free to reach out for collaboration or business inquiries.

# 🛒 MarketBridge – Flutter & Firebase App

MarketBridge is a Flutter-based mobile application that connects farmers and buyers through a simple, clean, and responsive marketplace interface.

This project is developed as part of **Kalvium – Sprint 2 (Flutter Widget Basics)** and focuses on Flutter UI fundamentals, navigation, and scalable project structure.

---

## 📱 App Overview

MarketBridge enables users to:
- View agricultural products
- Track market prices
- View product details
- Add or sell products
- Navigate seamlessly using a clean mobile-first UI

The app is designed to be responsive and works well across different screen sizes.

---

## 🧭 App Flow (According to UI Design)

```

App Launch
↓
Splash Screen
↓
Login Screen
↓
Marketplace Dashboard
↓
Product Listing
↓
Product Details
↓
Add / Sell Product

```

---

## 🖥️ Screen-wise Explanation

### 1. Splash Screen
- Entry point of the application
- Displays the app name (MarketBridge)
- Navigates to the Login Screen

### 2. Login Screen
- User authentication screen
- Acts as a gateway to the application

### 3. Marketplace Dashboard
- Displays market prices
- Shows trending products
- Provides quick actions

### 4. Product Listing Screen
- Displays all available products
- Each product is shown using a reusable product card

### 5. Product Detail Screen
- Shows detailed information about a product
- Includes price, quantity, and seller details

### 6. Add / Sell Product Screen
- Allows users to add new products to the marketplace
- Uses form inputs for product details

---

## 📂 Project Folder Structure

```

lib/
├── main.dart                  # Entry point of the application
│
├── screens/                   # All UI screens
│   ├── splash_screen.dart     # Splash screen
│   ├── login_screen.dart      # Login screen       
│   └── responsive_home.dart   # NEW – Responsive home screen
├── widgets/                   # Reusable UI components
│   ├── primary_button.dart    # Custom reusable button
│   └── product_card.dart      # Product card UI component
│
├── models/                    # Data models
│   └── product.dart           # Product data structure
│
├── services/                  # Business logic & Firebase services
│   └── firebase_service.dart  # Firebase integration 

````

---

## 🚀 Technologies Used

- Flutter
- Dart
- Firebase 

---

## ✅ Key Flutter Concepts Used

- StatelessWidget & StatefulWidget
- MaterialApp & Scaffold
- Named route navigation
- Reusable widgets
- Clean folder architecture
- Responsive UI basics

--

# 📱 **Responsive UI – Sprint 2 Assignment Add-on**

This section is added for the **Responsive Layout task** in Sprint-2.

---

## 🎯 What This Responsive Screen Demonstrates

* Fully responsive UI using **MediaQuery** and **LayoutBuilder**
* Phone → Tablet adaptation
* Portrait → Landscape changes
* Adaptive grid layout for market prices
* Flexible spacing, padding, and text scaling
* Matches the MarketBridge Figma-inspired home screen

---

## 🔧 Key Code Snippet – Detecting Screen Width

```dart
final screenWidth = MediaQuery.of(context).size.width;
final isTablet = screenWidth > 600;
```

---

## 🔧 Key Code Snippet – Using LayoutBuilder Breakpoints

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final width = constraints.maxWidth;
    final gridCount = width > 900 ? 4 : (width > 600 ? 2 : 1);
    return ...;
  },
);
```

---

## 🧩 What Was Implemented in `responsive_home.dart`

* Header (menu + title + notifications)
* Location card
* “Today’s Market Prices” grid — responsive
* Quick Actions section
* Trending Demand card
* View Market Details + See Buyer Demand buttons
* Bottom Navigation Bar
* Smooth scrolling + SafeArea support

---

## 🧠 Reflection (Required for Assignment)

**Challenges faced:**

* Managing layout overflow in landscape mode
* Ensuring grid responsiveness for multiple breakpoints
* Scaling fonts and padding for tablets

**What I learned:**

* `MediaQuery` helps detect device size dynamically
* `LayoutBuilder` is perfect for adaptive grid designs
* Flexible widgets (`Expanded`, `Wrap`, `GridView`) prevent UI breaking
* Responsive UI improves usability across all devices

---

# Market Bridge 

MarketBridge is a Flutter-based mobile application that connects farmers and buyers through a simple, clean, and responsive marketplace interface.

# [Concept-2] Firebase Authentication & Firestore Integration – MarketBridge App

This section of the MarketBridge project demonstrates Firebase integration with Flutter, focusing on:
- Firebase Authentication (Signup / Login / Logout)
- Firestore Database (CRUD operations & real-time sync)
- Firebase setup & configuration inside a Flutter application

This concept is part of **Kalvium – Sprint 2 (Firebase Integration)** and showcases how Firebase enables secure user login and cloud-based data storage while improving scalability and collaboration.

---

## Concept Overview

This Firebase-powered module allows users to:
- Sign up & log in securely using Firebase Authentication
- Store and retrieve user details in Firestore
- View instantly updated realtime data using listeners
- Understand Firebase setup within a scalable Flutter project architecture

---

## Task Workflow (Implementation Flow)

```

Firebase Setup
↓
Add Authentication & Firestore packages
↓
Create Auth Service
↓
Signup & Login UI
↓
Firestore CRUD operations
↓
Real-time UI updates using StreamBuilder

```

---

## Firebase Setup Instructions

### 1. Create Firebase Project
- Open Firebase Console
- Create a new project → enable Google Analytics (optional)

### 2. Add Android / iOS App
Register app using the package name (example):

com.example.firebase_setup

Download config files and place into the project:

google-services.json → android/app/
GoogleService-Info.plist → ios/Runner/


### 3. Install Dependencies

Run:

flutterfire configure

Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
```

Then run: 

flutter pub get

### 4. Initialize Firebase inside main.dart

void main() async {
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp();
runApp(MyApp());
}

### Firebase Authentication Implementation

Created service file:

lib/services/auth_service.dart

### Core Authentication Logic

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
Future<User?> signUp(String email, String password) async {
try {
final credential = await FirebaseAuth.instance
.createUserWithEmailAndPassword(email: email, password: password);
return credential.user;
} catch (e) {
print(e);
return null;
}
}

Future<User?> signIn(String email, String password) async {
try {
final credential = await FirebaseAuth.instance
.signInWithEmailAndPassword(email: email, password: password);
return credential.user;
} catch (e) {
print(e);
return null;
}
}

Future<void> logout() async {
await FirebaseAuth.instance.signOut();
}
}

### UI Screens Implemented

lib/screens/signup_screen.dart
lib/screens/login_screen.dart

Includes input fields for:

- Email
- Password
- Navigation between screens
- Redirect to dashboard after login

### Firestore Integration

Created Firestore service:

lib/services/firestore_service.dart

## Testing Done

| Test                    | Status                     |
| ----------------------- | -------------------------- |
| Signup account          | ✔ Successful               |
| Login                   | ✔ Success & redirected     |
| Write data to Firestore | ✔ Stored in cloud database |
| Update / Delete data    | ✔ Working                  |
| Real-time sync          | ✔ Auto updates             |


### Reflection

Successfully integrated:

- Firebase Authentication
- Firestore real-time database
- Login and Signup UI
- CRUD operations & realtime updates

Future extensions:

- Image upload using Firebase Storage
- Role based access for Farmers & Buyers
- Full marketplace product CRUD
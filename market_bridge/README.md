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

dart
LayoutBuilder(
  builder: (context, constraints) {
    final width = constraints.maxWidth;
    final gridCount = width > 900 ? 4 : (width > 600 ? 2 : 1);
    return ...;
  },
);


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


## ⚙️ Flutter Environment Setup & First Emulator Run

### ✅ Steps Followed

**1. Flutter SDK Installation**

* Downloaded Flutter SDK from the official Flutter website
* Extracted and added `flutter/bin` to system PATH
* Verified installation using:

```bash
flutter doctor
```

**2. Android Studio Setup**

* Installed Android Studio
* Installed Flutter & Dart plugins
* Ensured Android SDK, Platform Tools, and AVD Manager were configured

**3. Emulator Configuration**

* Created an Android Virtual Device (Pixel, Android 13+)
* Successfully launched the emulator
* Verified device detection using:

```bash
flutter devices
```

**4. First Flutter App Run**

* Created a new Flutter project
* Ran the default Flutter counter app using:

```bash
flutter run
```

* App launched successfully on the emulator

---

### 🧠 Reflection

**Challenges faced:**

* Initial Flutter SDK path configuration
* Emulator setup and device compatibility

**What I learned:**

* `flutter doctor` helps identify missing dependencies quickly
* Proper setup ensures smooth Flutter & Firebase development
* Emulator testing is essential before real device deployment

---

# 🧩 Flutter Widget Tree & Reactive UI Demo

This demo application is built using **Flutter** to demonstrate the core concepts of:
- Widget Tree hierarchy
- Flutter’s reactive UI model
- Efficient UI rebuilding using the widget tree

This project focuses on understanding how Flutter builds, updates, and optimizes the UI using widgets rather than traditional imperative UI updates.

---

## 📱 Demo App Overview

The app demonstrates a simple interactive UI where:
- Widgets are structured in a clear hierarchy
- UI updates occur automatically when state changes
- Only affected parts of the widget tree are rebuilt

This helps in understanding **how Flutter manages UI efficiently**.

---


### Key Points:
- `MaterialApp` is the root widget
- `Scaffold` provides basic UI structure
- UI elements are composed using nested widgets
- Each widget is immutable and describes part of the UI

---


## 📖 Concept Explanation

### ✅ What is a Widget Tree?

A **Widget Tree** is a hierarchical structure that represents the entire UI of a Flutter application.

- Every UI element in Flutter is a widget
- Widgets are nested inside other widgets
- The widget tree defines **how UI components are laid out and related**

Flutter uses this tree to understand:
- What to display
- How widgets are connected
- Which parts need rebuilding

---

### Key Learnings

- Flutter UI is built entirely using widgets
- The widget tree defines structure and layout
- Flutter’s reactive model simplifies UI updates
- Partial rebuilds improve performance
- Understanding widget hierarchy is critical for clean UI design

---

# Flutter Stateless & Stateful Widgets – Demo Application

This demo app showcases the difference between **Stateless** and **Stateful** widgets in Flutter, explaining how they work, when to use them, and how they help build dynamic and responsive user interfaces.

The app demonstrates a simple counter UI where the static and dynamic parts of the screen are clearly separated to highlight Flutter’s reactive capabilities.

---

## Demo Overview

This concept demonstrates:
- The structure and purpose of Stateless widgets
- The behavior and reactivity of Stateful widgets
- How Flutter rebuilds UI based on state changes
- Clean separation between static UI and dynamic UI components

---

## Understanding Widgets in Flutter

### 🔹 **Stateless Widget**
A **StatelessWidget** is a widget that **does not change** once it is built.

- Contains **fixed UI**
- Does not store data that changes
- Used for:
    - Static text
    - Icons
    - Buttons without dynamic content
    - Layout or design components

### 🔹 **Stateful Widget**
- A StatefulWidget is a widget that changes over time based on interaction or data updates.
- Stores data in State object
- Rebuilds only the affected UI parts
- Used for:
    - Buttons that trigger UI changes
    - Forms and text fields
    - Animations
    - Dynamic lists

## Reflection

### How do Stateful widgets make Flutter apps dynamic?

Stateful widgets allow apps to react to user interactions, such as button presses, form updates, and animations.

When state changes, Flutter intelligently rebuilds only the affected widgets, making the UI fast, flexible, and responsive.

### Why separate static and reactive parts of UI?

 stateless_stateful
- Makes code cleaner and easier to maintain
- Improves performance by reducing unnecessary rebuilds
- Ensures UI updates happen only where needed
- Encourages separation of concerns between layout and logic
=======
## Market Bridge – Multi-Screen Navigation (Sprint-2)

This project demonstrates **multi-screen navigation in Flutter** using `Navigator`, named routes, and dynamic route arguments. The app includes authentication screens, profile completion, and a responsive home screen inspired by the Market-Bridge use case.

---

## 🚀 Features Implemented

### ✅ **1. Splash Screen → Phone Login → OTP → Profile → Home**

Navigation flow implemented using:

* `Navigator.pushNamed()`
* `Navigator.pushReplacementNamed()`
* `onGenerateRoute` for screens that require arguments
* Centralized `routes.dart` file

### ✅ **2. Firebase Phone Authentication**

* Sends OTP using `FirebaseAuth.verifyPhoneNumber`
* Auto-verification supported
* Manual OTP entry and validation
* Routes forward necessary data (phone, role, verificationId)

### ✅ **3. Profile Completion Page**

* Saves data to Firestore
* Collects: Name, Email, Location, Language, Farm Size
* Shows a success popup and routes to Home screen

### ✅ **4. Responsive Farmer Home UI**

* Grid layout adapts to screen width (mobile/tablet)
* Shows sample produce cards and quick actions

---

## 🧭 Navigation Structure

| Route Name  | Screen                                   |
| ----------- | ---------------------------------------- |
| `/`         | SplashScreen                             |
| `/phone`    | PhoneLoginScreen                         |
| `/otp`      | OtpVerifyScreen *(with arguments)*       |
| `/complete` | CompleteProfileScreen *(with arguments)* |
| `/home`     | ResponsiveHome                           |

---

## 📂 Project Files (Key Screens)

* `lib/main.dart` → App entry + route configuration
* `lib/routes.dart` → All route constants
* `lib/screens/splash_screen.dart`
* `lib/screens/phone_login_screen.dart`
* `lib/screens/otp_verify_screen.dart`
* `lib/screens/complete_profile_screen.dart`
* `lib/screens/responsive_home.dart`
* `lib/services/auth_service.dart` → Handles OTP login

---


## Reflection 

Using named routes improved readability and organization of the navigation system.
`onGenerateRoute` was helpful for passing dynamic data like `verificationId` and `phoneNumber` to OTP and profile screens.
This structure scales well as the project grows.

# 📘 Concept – Responsive Layout Using Rows, Columns & Containers (Sprint-2 Task 2.17)

This task focuses on designing a responsive screen using Flutter’s basic layout widgets such as **Container**, **Row**, and **Column**. The goal was to create a layout that adapts smoothly to different screen sizes, including mobile and tablet devices.

## 🔹 What the Layout Includes

* A top header section
* Two content panels arranged **side-by-side on tablets**
* The same panels **stack vertically on mobile screens**
* Clean spacing and balanced structure using Rows, Columns, and padding
* Fully responsive behavior with screen size adjustments

## 🔹 What I Learned

* How Rows and Columns help structure UI
* How Containers help with spacing, alignment, and design
* How to make layouts adapt to screen width using responsive principles
* Importance of testing UI on different devices and orientations

## 🔹 Challenges Faced

* Managing layout proportions across devices
* Preventing overflow in landscape mode
* Ensuring panels resize smoothly

## 🔹 Final Output

A clean, responsive screen that adjusts automatically for:

* 📱 Mobile
* 📲 Tablets
* ↔ Portrait & Landscape modes

This completes the Sprint-2 responsive layout assignment using fundamental Flutter layout widgets.

---

# Scrollable Views in Flutter — ListView & GridView Demo

This assignment demonstrates how to build scrollable layouts in Flutter using **ListView**, **GridView**, and their builder constructors. The app displays both scrolling lists and grid tiles inside a single screen, showing how Flutter handles vertical and horizontal scrolling efficiently.

---

## Project Overview

This demo contains:
- A **horizontal ListView.builder** displaying scrollable cards
- A **GridView.builder** showing a 2-column grid
- A combined UI using **SingleChildScrollView + Column**
- Smooth scrolling behavior across different device sizes

The goal is to understand when to use ListView, GridView, and their builder variations for efficient UI rendering.

---

## Combined Scrollable Views — Full Example Used in This Project

```dart
class ScrollableViews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scrollable Views')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              child: Text('ListView Example', style: TextStyle(fontSize: 18)),
            ),
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    width: 150,
                    margin: EdgeInsets.all(8),
                    color: Colors.teal[100 * (index + 2)],
                    child: Center(child: Text('Card $index')),
                  );
                },
              ),
            ),

            Divider(thickness: 2),

            Container(
              padding: EdgeInsets.all(8),
              child: Text('GridView Example', style: TextStyle(fontSize: 18)),
            ),
            Container(
              height: 400,
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.primaries[index % Colors.primaries.length],
                    child: Center(
                      child: Text(
                        'Tile $index',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```


## Reflection

### **🔹 How do ListView and GridView improve UI efficiency?**
Both widgets load items **lazily**, meaning they only render what's visible on the screen. This improves performance and reduces memory usage, especially when large lists or grids are involved.

### **🔹 Why are builder constructors recommended?**
`ListView.builder` and `GridView.builder`:
- Render items on-demand
- Avoid loading hundreds of widgets at once
- Improve performance for dynamic data
- Work perfectly with Firebase/real-time lists

### **🔹 Common performance pitfalls to avoid**
❌ Using ListView inside a Column without constraints  
❌ Rendering hundreds of items manually instead of using builder  
❌ Not using shrinkWrap / proper physics when embedding scrollables

---

## Conclusion

This project demonstrates how ListView and GridView make Flutter apps scalable, smooth, and visually organized. Understanding scrollable layouts is essential for building dashboards, catalogs, lists, and gallery-based mobile applications.

# Market Bridge - Scrollable Views Implementation

## 📱 Project Overview
A Flutter-based scrollable catalog screen implementing **ListView** and **GridView** widgets to display market products, categories, and orders. This demonstrates efficient data presentation with smooth scrolling performance.

---

## 🎯 Features Implemented

### 1. **Horizontal ListView** - Featured Products
Displays scrollable product cards horizontally with images, prices, and stock status.

### 2. **GridView** - Browse Categories
Shows market categories in a 2-column grid layout with icons and item counts.

### 3. **Vertical ListView** - Recent Orders
Lists recent orders with order details and delivery status.

---

## 💻 Code Snippets

### ListView.builder - Horizontal Scrolling
```
dart
SizedBox(
  height: 220,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: produceItems.length,
    itemBuilder: (context, index) {
      final item = produceItems[index];
      return Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Product image and details
          ],
        ),
      );
    },
  ),
)
```

### GridView.builder - Category Grid
```
dart
GridView.builder(
  physics: const NeverScrollableScrollPhysics(),
  shrinkWrap: true,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 1.1,
  ),
  itemCount: marketCategories.length,
  itemBuilder: (context, index) {
    final category = marketCategories[index];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(category['icon'], size: 36),
          Text(category['title']),
          Text(category['count']),
        ],
      ),
    );
  },
)
```

### Vertical ListView - Recent Orders
```
dart
ListView.builder(
  physics: const NeverScrollableScrollPhysics(),
  shrinkWrap: true,
  itemCount: 5,
  itemBuilder: (context, index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.receipt_long),
          Expanded(
            child: Column(
              children: [
                Text('Order #${1000 + index}'),
                Text('${index + 2} items • ₹${(index + 1) * 250}'),
              ],
            ),
          ),
          // Status badge
        ],
      ),
    );
  },
)
```

---

### 📸 Screenshots
* Added Screenshot inside the CodeSnippets folder which shows Featured Products (horizontal scroll), Browse Categories (grid), and Recent Orders (vertical list)*

---

## 🤔 Reflection

### **How does ListView differ from GridView in design use cases?**

- **ListView**: Best for **linear, single-column** layouts like chat messages, news feeds, or product lists. Items flow vertically (or horizontally) in a single direction.

- **GridView**: Ideal for **multi-column** layouts like photo galleries, product catalogs, or app icons. Displays items in a structured grid pattern for better space utilization.

**Example**: Use ListView for a contact list, GridView for a photo gallery.

---

### **Why is `ListView.builder()` more efficient for large lists?**

`ListView.builder()` uses **lazy loading** - it only builds widgets that are currently visible on screen, not all items at once.

**Benefits:**
- ✅ Saves memory by creating items on-demand
- ✅ Faster initial load time
- ✅ Smooth scrolling even with 1000+ items
- ✅ Better performance than regular `ListView(children: [...])`

**Example**: For 1000 items, regular ListView creates all 1000 widgets immediately. Builder creates only ~10-15 visible widgets and rebuilds as you scroll.

---

### **What can you do to prevent lag or overflow errors in scrollable views?**

**To Prevent Lag:**
1. ✅ Use `.builder()` constructors instead of static lists
2. ✅ Set `physics: const NeverScrollableScrollPhysics()` for nested scrollables
3. ✅ Use `shrinkWrap: true` for GridView/ListView inside SingleChildScrollView
4. ✅ Optimize image loading with `CachedNetworkImage`
5. ✅ Keep widget trees shallow, avoid deep nesting

**To Prevent Overflow:**
1. ✅ Wrap content in `SingleChildScrollView`
2. ✅ Use `Expanded` or `Flexible` for dynamic sizing
3. ✅ Set fixed heights for horizontal lists
4. ✅ Use `MainAxisSize.min` for Columns inside scrollables
5. ✅ Test on different screen sizes

---

## 🚀 Running the App

```bash
# Navigate to project directory
cd market_bridge

# Get dependencies
flutter pub get

# Run the app
flutter run
```

Navigate to the Scrollable Views screen from:
- Login Screen → "Skip & Open Scrollable Views" button
- Home Screen → "Open Scrollable Views" button

---

feat/user-authentication
# Persistent User Session with Firebase Auth

## Project Overview

This project demonstrates how to maintain persistent user sessions in a Flutter app using Firebase Authentication. Users remain logged in even after closing or restarting the app, providing a seamless experience.

## Auto-Login Flow

* App detects if a user is already logged in.
* Authenticated users are redirected to the Home screen automatically.
* Users are sent to the Login screen only when not authenticated or after logout.
* Session persists across app restarts without manual storage.

## Features

* Persistent login after app restart
* Automatic screen navigation based on authentication state
* Clean logout handling
* Optional splash/loading screen during session verification

## Testing Steps

1. Login → App navigates to Home screen.
2. Close and reopen the app → App auto-redirects to Home screen.
3. Logout → App redirects to Login screen.
4. Reopen → App stays on Login screen.

## Reflection

* Persistent login enhances user experience by avoiding repeated logins.
* Firebase handles token persistence and auto-refresh, simplifying session management.
* Testing confirmed reliable auto-login behavior and smooth transitions between screens.

---
main

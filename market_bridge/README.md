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

# Post Produce Screen - Development Documentation

---

## 🎯 Objective

I implemented a fully functional **Post Produce Screen** that allows farmers to create and publish their produce listings on the Market Bridge platform. The screen was designed to match the Figma design specifications exactly while maintaining responsiveness and user-friendly interactions across different device sizes.

---

## ✅ Tasks Completed

### 1. **Post Produce Screen Development** (`post_produce_screen.dart`)

I created a complete form-based screen with multiple input components working together seamlessly.

**Form Fields I Implemented:**
- **Crop Name Dropdown** - I built a dropdown menu containing 8 pre-populated crop options including Tomato, Onion, Potato, Wheat, Rice, Carrot, Cabbage, and Spinach. The dropdown features custom styling to match the design system and includes required field validation.

- **Quantity & Unit Input** - I designed a side-by-side layout where farmers can enter the quantity of their produce and select the appropriate unit of measurement. The quantity field accepts only numeric values, while the unit dropdown offers three options: Kg, Quintal, and Ton.

- **Price Input** - I implemented a price input field with a rupee (₹) symbol prefix to clearly indicate the currency. The field uses a numeric keyboard for easier data entry and includes validation to ensure only valid numbers are accepted.

- **Price Negotiable Checkbox** - I created a custom-styled checkbox that allows farmers to indicate if their price is negotiable. The checkbox features the brand's green accent color and provides visual feedback when toggled.

- **Photo Upload** - I integrated dual photo upload options allowing farmers to either capture a new photo using their camera or select an existing image from their gallery. The selected image appears as a preview with the option to remove and choose a different photo. All images are automatically compressed to optimize storage and upload speeds.

- **Location Input** - I added a text field where farmers can enter their city or district location, making it easier for buyers to find nearby produce listings.

**UI/UX Features I Built:**
- I styled the app bar with the brand's signature green color (#11823F) to maintain visual consistency throughout the application.
- I added a back button for easy navigation and a notifications icon in the header for future feature integration.
- I implemented proper spacing and padding that adjusts based on device size, using 16px for phones and 24px for tablets.
- I applied rounded corners throughout the interface to create a modern, friendly appearance.
- I built comprehensive form validation that displays clear error messages when users miss required fields or enter invalid data.
- I created a success dialog with an animated check icon that appears after successful form submission.
- I ensured the design works beautifully on both phone and tablet screen sizes.

---

### 2. **Navigation Integration**

I integrated the Post Produce screen into the existing application navigation system to ensure smooth user flow.

**Files I Updated:**
- In `responsive_home.dart`, I connected the "Post Produce" button to navigate users to the new screen when tapped.
- In `routes.dart`, I added the `routePostProduce` constant to maintain consistent route naming across the application.
- I configured the main route system to recognize and handle navigation to the Post Produce screen.

**Navigation Flow I Implemented:**
When users tap the "Post Produce" button on the home screen, they're taken to the Post Produce screen where they can fill out the form. After submitting, they see a success confirmation dialog, and upon tapping OK, they're automatically returned to the home screen.

---

### 3. **Package Integration**

I added the necessary package dependencies to enable photo upload functionality.

**Dependency I Added:**
I integrated the `image_picker` package version 1.0.4, which provides reliable access to the device camera and photo gallery across both Android and iOS platforms.

**Required Imports:**
I ensured all necessary Flutter imports are included, such as Material design components, platform services for input formatting, file handling for image display, and the image picker package for photo selection functionality.

---

## 📁 Files Created/Modified

**New Files I Created:**
I built the complete `post_produce_screen.dart` file from scratch, writing approximately 470 lines of well-structured, documented code that handles all form functionality, validation, and user interactions.

**Existing Files I Modified:**
I updated the `responsive_home.dart` file to add navigation logic for the Post Produce button. I modified the `routes.dart` file to include the new route constant. I also updated the `pubspec.yaml` file to include the image_picker dependency required for photo upload functionality.

---

## 🎨 Design Implementation

**Color Scheme I Applied:**
I used the primary green color (#11823F) for the app bar, buttons, and interactive elements to maintain brand consistency. The screen background uses a light gray (#F5F5F5) to reduce eye strain, while input fields and containers feature clean white backgrounds. Text colors range from dark gray for headings to lighter grays for hints and secondary information.

**Typography Decisions I Made:**
I set the app bar title at 20px with semi-bold weight for clear hierarchy. Section labels use 14px semi-bold text to distinguish them from input content. Input text appears at 15px regular weight for comfortable reading. Button text is displayed at 16px bold to emphasize interactivity.

**Spacing System I Implemented:**
I applied 16px padding on phone screens and increased it to 24px on tablets for better use of available space. Sections are separated by 20-24px to create clear visual groupings. Labels appear 8px above their corresponding input fields for tight association. Both input fields and buttons maintain a consistent 54px height for comfortable tapping.

---

## 🔧 Technical Implementation

**Form Validation Logic I Built:**
I implemented comprehensive validation for the quantity field that checks if a value has been entered and verifies it's a valid number. The price field validation ensures users enter a value and confirms it's a legitimate numeric price. Location validation checks that the field isn't empty. For crop selection, I added validation that displays a helpful message if users try to submit without selecting a crop.

**Image Picker Implementation I Created:**
I built an async function that handles image selection from either camera or gallery sources. The function includes error handling to manage cases where users cancel the selection or if the picker fails. I configured automatic image compression to a maximum of 1800x1800 pixels at 85% quality to balance image clarity with file size.

**Success Dialog I Designed:**
I created a custom dialog that appears after successful form submission, featuring a green check icon and a congratulatory message. The dialog includes an OK button that, when tapped, automatically navigates users back to the home screen, completing the post creation flow.

---

## 📱 Responsive Breakpoints

**Phone Layout I Optimized:**
For devices with screens smaller than 600px wide, I used a single-column form layout with 16px padding throughout. Font sizes are optimized for readability on smaller screens, and photo upload buttons are set to 100px height for easy tapping.

**Tablet Layout I Enhanced:**
For tablets with screens 600px or wider, I maintained the same overall layout but increased padding to 24px to better utilize the larger screen space. Touch targets are slightly enlarged for more comfortable interaction on bigger devices.

---

## ✨ Key Features

**Form Validation System:**
I implemented real-time validation that triggers when users attempt to submit the form. Each field displays its own specific error message to guide users in correcting issues. Required fields are clearly indicated, and numeric fields include type checking to prevent invalid data entry.

**Image Handling Capabilities:**
I built functionality for users to capture photos directly with their camera or browse their existing photo gallery. Selected images display as previews with a remove option if users want to choose a different photo. All images are automatically compressed to optimize performance without significantly reducing quality.

**User Experience Enhancements:**
I created a clear visual hierarchy that guides users through the form naturally. Field labels are intuitive and descriptive. Placeholder text provides helpful examples of what to enter. Success confirmation gives users confidence their listing was created. The navigation flow is smooth and predictable throughout the entire process.

---

## 🔄 Data Flow

I designed the data flow so that user input moves through form fields, undergoes validation checks, and upon successful validation, triggers the success dialog before navigating users back home. The image picker flow operates independently, allowing users to select from camera or gallery, which then updates the preview and stores the file in the component's state.

---

## 🧪 Testing Scenarios

**Manual Tests I Completed:**
I thoroughly tested form submission with all valid data to ensure successful posting. I verified validation by attempting submission with missing required fields. I tested numeric validation by entering invalid characters in number fields. I checked both camera capture and gallery selection for image upload. I confirmed the image removal feature works correctly. I tested checkbox toggling for the price negotiable option. I verified all dropdown selections work as expected. I tested the back button navigation. I confirmed the success dialog displays correctly and navigates properly. I verified responsive layout behavior on different screen sizes.

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
---

## 📦 Installation Instructions

**Step 1 - Adding the Dependency:**
I added the image_picker package to the pubspec.yaml file under dependencies with version 1.0.4, then ran flutter pub get to install it.

**Step 2 - Creating the Screen File:**
I created a new file at lib/screens/post_produce_screen.dart and wrote the complete implementation with all form fields, validation logic, and image handling functionality.

**Step 3 - Updating Routes:**
I modified the routes.dart file to add the routePostProduce constant, then updated the main route configuration to recognize and handle navigation to the Post Produce screen.

**Step 4 - Connecting Navigation:**
I updated the responsive_home.dart file to connect the "Post Produce" button's onPressed handler to navigate to the new screen using the defined route.

**Step 5 - Platform-Specific Configuration:**
For Android, I added camera and storage permissions to the AndroidManifest.xml file. For iOS, I added usage description strings to the Info.plist file explaining why the app needs camera and photo library access.

---

# Farmer Dashboard - Simple Documentation

## What We Built Today

Today we created a Farmer Dashboard screen where farmers can see and manage their produce listings. This screen shows important information like total sales, number of active listings, and recent activity from buyers.

---

## ✅ Main Features

### Dashboard Screen
We built a complete dashboard with these parts:

*Statistics Section*
- Shows sales for this month (₹45,000)
- Shows how many listings are active
- Both displayed in nice white cards with icons

*Recent Activity*
- Shows buyer interest in crops (like "2 new" buyers interested in tomatoes)
- Shows how many people viewed listings
- Uses colored badges to highlight new activity

*My Listings*
- Shows all crops the farmer has posted
- Each listing shows crop name, quantity, price, views, and inquiries
- Has "Edit" and "Delete" buttons for each listing
- "Add New" button to post more crops

*Empty State*
- When farmer has no listings, shows a friendly message
- Gives a button to add their first listing

*Bottom Navigation*
- Three buttons: Home, Marketplace, Dashboard
- Active page is highlighted in green
- Easy to switch between screens

---

## 🔧 How It Works

### Navigation Setup
We connected the dashboard to other screens in two ways:

1. *From Home Screen:*
    - Click "My Listings" button → Goes to Dashboard
    - Click "Dashboard" in bottom navigation → Goes to Dashboard

2. *From Dashboard:*
    - Click "Add New" → Goes to Post Produce screen
    - Click bottom navigation → Goes to Home or Marketplace
    - Click back button → Returns to previous screen

### Delete Function
When you click "Delete" on a listing:
1. A popup asks "Are you sure?"
2. If you click "Delete" → Listing is removed
3. If you click "Cancel" → Nothing happens
4. After delete, you see a success message

### Edit Function
When you click "Edit" on a listing:
- Currently shows "Coming soon" message
- Ready to add full edit feature later

---

## Files We Created/Changed

### New File:
- lib/screens/farmer_dashboard_screen.dart - The complete dashboard screen

### Files We Updated:
- lib/screens/responsive_home.dart - Added navigation to dashboard
- lib/routes.dart - Added dashboard route
- Route configuration in main.dart - Connected route to screen

---

## Design Colors Used

- *Green (#11823F)* - Main color for buttons and headers
- *Light Gray (#F5F5F5)* - Screen background
- *White (#FFFFFF)* - Cards and containers
- *Dark Gray (#333333)* - Main text
- *Medium Gray (#666666)* - Supporting text
- *Light Gray (#999999)* - Hint text

---

## 📝 Quick Summary

We built a complete Farmer Dashboard where farmers can:
- See their sales and listing statistics
- View recent activity from buyers
- Manage all their produce listings
- Edit or delete listings easily
- Add new listings quickly
- Navigate smoothly between screens

The dashboard looks professional, works smoothly, and is ready to connect to a real database when needed.

---

# Role-Based Navigation Implementation Guide

## 🎯 Overview
This implementation adds role-based navigation and theming to your Market Bridge app, ensuring buyers and farmers see appropriate screens and UI colors.

## 📋 Changes Made

### 1. **Complete Profile Screen** (Updated)
- ✅ Single unified screen for both farmers and buyers
- ✅ Dynamic theming based on role (Green for Farmer, Blue for Buyer)
- ✅ Shows farm size field only for farmers
- ✅ Role-appropriate icons and colors
- ✅ Navigates to correct home screen after registration

### 2. **OTP Verify Screen** (Updated)
- ✅ Dynamic theming based on selected role
- ✅ Maintains role information throughout verification flow
- ✅ Passes role to profile completion screen

### 3. **Role Home Router** (New)
- ✅ Fetches user role from Firestore
- ✅ Routes to `BuyerHomeScreen` for buyers
- ✅ Routes to `ResponsiveHome` (farmer home) for farmers
- ✅ Shows loading state while fetching role
- ✅ Handles errors gracefully

### 4. **Dashboard Router** (New)
- ✅ Fetches user role from Firestore
- ✅ Routes to `BuyerDashboardScreen` for buyers
- ✅ Routes to `FarmerDashboardScreen` for farmers
- ✅ Shows loading state while determining role

### 5. **Main.dart Configuration** (Updated)
- ✅ Updated route generation to use new routers
- ✅ Proper argument passing between screens
- ✅ Clean navigation flow

## 🚀 How It Works

### User Flow:

#### **Farmer Flow:**
1. Splash Screen → Phone Login → Select "Farmer"
2. Send OTP (Green theme maintained)
3. Verify OTP (Green theme)
4. Complete Profile with farm size field (Green theme)
5. **Navigate to ResponsiveHome (Farmer Home)**
6. Click Dashboard → **FarmerDashboardScreen**

#### **Buyer Flow:**
1. Splash Screen → Phone Login → Select "Buyer"
2. Send OTP (Blue theme maintained)
3. Verify OTP (Blue theme)
4. Complete Profile without farm size (Blue theme)
5. **Navigate to BuyerHomeScreen**
6. Click Dashboard → **BuyerDashboardScreen**

## 📦 Files to Create/Update

### New Files:
1. `lib/screens/role_home_router.dart` - Routes to correct home based on role

### Updated Files:
1. `lib/screens/complete_profile_screen.dart` - Unified with role theming
2. `lib/screens/otp_verify_screen.dart` - Role-based theming
3. `lib/main.dart` - Updated routing configuration

### Existing Files (No Changes Needed):
- `lib/screens/buyer_home_screen.dart`
- `lib/screens/responsive_home.dart` (Farmer home)
- `lib/screens/buyer_dashboard_screen.dart`
- `lib/screens/farmer_dashboard_screen.dart`

## 🎨 Color Scheme

### Farmer Theme:
- Primary Color: `#11823F` (Green)
- Icon Background: `#FFF3E0` (Light Orange)
- Icon: Agriculture (🧺/👨‍🌾)

### Buyer Theme:
- Primary Color: `#2196F3` (Blue)
- Icon Background: `#E3F2FD` (Light Blue)
- Icon: Shopping Bag (🛒)

## 📝 Notes

1. **Role is case-insensitive**: Code uses `.toLowerCase()` for comparisons
2. **Role persistence**: Role is stored in Firestore and fetched on app launch
3. **Navigation flow**: Uses `pushReplacementNamed` to prevent back navigation to login screens after registration
4. **Loading states**: Both routers show loading indicators while fetching role data
5. **Error handling**: Redirects to login if role can't be determined

## 🎉 Result

After implementation, you'll have a fully functional role-based app where:
- Farmers see green-themed UI and farmer-specific features
- Buyers see blue-themed UI and buyer-specific features
- Each role navigates to their appropriate home and dashboard screens
- The experience is seamless and consistent throughout the app
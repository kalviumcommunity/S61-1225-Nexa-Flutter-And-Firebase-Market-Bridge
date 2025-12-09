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
│   └── login_screen.dart      # Login screen
│
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
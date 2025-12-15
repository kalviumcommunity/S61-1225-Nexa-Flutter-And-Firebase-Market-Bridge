# Firebase Authentication (Email & Password) – Flutter Demo

This project demonstrates how to implement **Firebase Authentication using Email and Password** in a Flutter application. The app allows users to **sign up, log in, and manage authentication state** securely using Firebase’s backend services.

This implementation focuses on understanding authentication flow, Firebase setup, and handling login/signup logic in Flutter.

---

## Project Overview

The app provides:
- Email & Password **Signup**
- Email & Password **Login**
- Toggle between Login and Signup modes
- Firebase-backed authentication state
- Real-time sync with Firebase Console

Firebase Authentication handles all security, validation, and session management, allowing developers to focus on UI and user experience.

---

## What Is Firebase Authentication?

Firebase Authentication is a backend service that helps developers authenticate users easily and securely.

It supports multiple authentication methods:
- Email & Password
- Google Sign-In
- Phone Authentication
- Apple, GitHub, and more

In this project, **Email & Password authentication** is implemented, which is the foundation for most custom mobile applications.

---

## Enabling Firebase Authentication

Steps followed in Firebase Console:

1. Open **Firebase Console**
2. Go to **Authentication**
3. Navigate to **Sign-in Method**
4. Enable **Email/Password**
5. Click **Save**

This allows the app to perform signup and login operations through Firebase APIs.

---

## Dependencies Used

Added the following dependencies in `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
```

Installed packages using:

```bash
flutter pub get
```

---

## Firebase Initialization

Firebase is initialized in `main.dart` before the app starts:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

This ensures Firebase services are available throughout the app lifecycle.

---

## Authentication Screen Implementation

File created:
```
lib/screens/auth_screen.dart
```

### 🔹 Key Features
- Email and Password input fields
- Login and Signup toggle
- FirebaseAuth API integration
- Success and error feedback using SnackBar

### 🔹 Core Authentication Logic

```
dart
if (isLogin) {
  await _auth.signInWithEmailAndPassword(
    email: _emailController.text.trim(),
    password: _passwordController.text.trim(),
  );
} else {
  await _auth.createUserWithEmailAndPassword(
    email: _emailController.text.trim(),
    password: _passwordController.text.trim(),
  );
}
```

### 🔹 Switching Between Login & Signup

```
dart
TextButton(
  onPressed: () => setState(() => isLogin = !isLogin),
  child: Text(isLogin ? 'Create new account' : 'Already have an account? Login'),
)
```

This allows a single screen to manage both authentication flows.

---

## 🔄 Authentication State & Logout

### 🔹 Listening to Auth State Changes

```
dart
FirebaseAuth.instance.authStateChanges().listen((User? user) {
  if (user == null) {
    print('User is signed out');
  } else {
    print('User is signed in: ${user.email}');
  }
});
```

### 🔹 Logging Out

```
dart
await FirebaseAuth.instance.signOut();
```

This helps manage session-based navigation and protected routes.

---

## Reflection

### **How does Firebase simplify authentication?**
Firebase removes the need to build custom backend logic. It provides secure APIs, built-in validation, and session handling out of the box.

### **Security benefits over custom auth systems**
- Encrypted credential storage
- Automatic token handling
- Protection against common vulnerabilities
- Industry-grade security maintained by Google

### **Challenges faced**
- Correct Firebase setup and initialization
- Handling auth errors gracefully
- Managing login/signup state in a single screen

---

## Conclusion

This project demonstrates how Firebase Authentication enables secure, scalable, and easy-to-implement user authentication in Flutter apps. By using Firebase Auth, developers can focus on building features instead of managing backend security.


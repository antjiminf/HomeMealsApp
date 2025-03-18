# 🍽 HomeMealsApp

🌍 Disponible en: [Español](README.es.md)

**HomeMealsApp** is a mobile application for meal planning, recipe management, ingredient inventory control, and shopping list generation. It allows users to organize their daily meals, ensure they have the necessary ingredients, and simplify grocery shopping.

> ⚠️ **Note:** HomeMealsApp requires an API to function, which is currently not public for security reasons.

---

## 🛠️ System Requirements

- **iOS 17.5 or later**: The app is designed for devices running iOS 14.0 or later.
- **Xcode 15.4 or later**: Required to build and run the project.
- **Swift 5.10 or later**: The project is developed using the default Swift version in Xcode.

---

## 🚀 Features

- 📅 **Meal Planning**: Organize your daily meals in an interactive calendar.
- 📝 **Recipe Management**: Save, browse, and manage custom recipes.
- 🏠 **Ingredient Inventory**: Keep track of ingredients you have at home and organize your pantry.
- 🛒 **Smart Shopping Lists**: Generate shopping lists based on planned recipes and missing ingredients.
- 🔐 **User Authentication**: Sign up and log in with credentials or Sign in with Apple.
<!--- ☁️ **Cloud Synchronization**: Securely store data on the server.  -->

---

## 📱 Technologies Used

- **Swift** and **SwiftUI** for the user interface.
- **SwiftData** for local data persistence.
- **Vapor** (Swift Backend) for server and database management.
- **AuthenticationServices** for Sign in with Apple.
- **Async/Await** for asynchronous data handling and state management.

---

## 🔧 Installation & Setup

### 📦 Clone the Repository

```bash
git clone https://github.com/antjiminf/HomeMealsApp.git
cd HomeMealsApp
```

### 📲 Run the Application

1. Open `HomeMeals.xcodeproj` in Xcode.
2. Make sure to select a simulator or real device.
3. Build and run (`Cmd + R`).

---

## 🔑 Authentication Setup

To enable Sign in with Apple, ensure you:

1. Enable the **Sign in with Apple** capability in the project.
2. Configure **App IDs** in the Apple Developer portal.

---
